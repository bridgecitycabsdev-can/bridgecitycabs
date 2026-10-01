import { randomUUID } from 'node:crypto';
import { io } from 'socket.io-client';
import { loadEnvFile } from './load-env.js';
import { api, apiOrigin, bearer, flag, otpLogin } from './sim-session.js';

loadEnvFile();

const phone = flag('phone') ?? process.env.SIM_PASSENGER_PHONE ?? '+14035550199';

/** Downtown Lethbridge. Drivers in sim-driver.ts circle this block. */
const pickup = {
  address: 'Lethbridge City Hall',
  lat: 49.6946,
  lng: -112.8328,
};
const dropoff = {
  address: 'Galt Museum',
  lat: 49.6856,
  lng: -112.8297,
};

const session = await otpLogin(phone);
const branchId = flag('branch') ?? (await findBranchId());
const vehicleTypeId = flag('vehicle-type') ?? (await findSedanId());

const quote = await api('/api/v1/passenger/fares/quote', {
  method: 'POST',
  headers: bearer(session.accessToken),
  body: JSON.stringify({
    branchId,
    vehicleTypeId,
    zone: 'INSIDE_TOWN',
    stops: [
      { lat: pickup.lat, lng: pickup.lng },
      { lat: dropoff.lat, lng: dropoff.lng },
    ],
  }),
});
console.log(`quote ${JSON.stringify(quote)}`);

try {
  const booking = await api('/api/v1/passenger/bookings', {
    method: 'POST',
    headers: {
      ...bearer(session.accessToken),
      'idempotency-key': randomUUID(),
    },
    body: JSON.stringify({
      branchId,
      vehicleTypeId,
      zone: 'INSIDE_TOWN',
      stops: [pickup, dropoff],
    }),
  });
  console.log(`booking ${JSON.stringify(booking)}`);
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
  console.log('connecting anyway to print the active trip');
}

const socket = io(`${apiOrigin()}/passenger`, {
  transports: ['websocket'],
  auth: { token: session.accessToken },
});

socket.onAny((event, payload) => {
  console.log(`${event} ${JSON.stringify(payload)}`);
});
socket.on('connect', () => {
  console.log(`connected socket=${socket.id} room passenger`);
});
socket.on('connect_error', (error: Error) => {
  console.error(`socket rejected: ${error.message}`);
});

async function findBranchId() {
  const token = await staffToken();
  const branches = (await api('/api/v1/branches', {
    headers: bearer(token),
  })) as { id: string; name: string; city: string }[];
  const branch =
    branches.find((row) => row.city === 'Lethbridge' || row.name === 'Lethbridge') ??
    branches[0];
  if (!branch) throw new Error('No branch found. Pass --branch <id>.');
  console.log(`branch ${branch.name} ${branch.id}`);
  return branch.id;
}

async function findSedanId() {
  const token = await staffToken();
  const page = (await api('/api/v1/vehicle-types?pageSize=100', {
    headers: bearer(token),
  })) as { data: { id: string; name: string }[] };
  const sedan = page.data.find((row) => row.name === 'Sedan') ?? page.data[0];
  if (!sedan) throw new Error('No vehicle type found. Pass --vehicle-type <id>.');
  console.log(`vehicle type ${sedan.name} ${sedan.id}`);
  return sedan.id;
}

async function staffToken() {
  const email = process.env.SEED_ADMIN_EMAIL;
  const password = process.env.SEED_ADMIN_PASSWORD;
  if (!email || !password) {
    throw new Error('Pass --branch and --vehicle-type, or set SEED_ADMIN_EMAIL and SEED_ADMIN_PASSWORD');
  }
  const session = (await api('/api/v1/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  })) as { accessToken: string };
  return session.accessToken;
}
