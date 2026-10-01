import { io } from 'socket.io-client';
import { SOCKET_EVENTS } from '@bridgecabs/shared-types';
import { PrismaClient } from '@prisma/client';
import { loadEnvFile } from './load-env.js';
import { api, apiOrigin, bearer, flag, otpLogin } from './sim-session.js';

loadEnvFile();

const BEHAVIORS = ['accept', 'decline', 'ignore'] as const;
type Behavior = (typeof BEHAVIORS)[number];

const phone = flag('phone') ?? process.env.SIM_DRIVER_PHONE ?? '+14035550100';
const behavior = readBehavior();
const delaySeconds = readDelay();

/** Tight square around downtown Lethbridge so these drivers stay in one search band. */
const loop = [
  { lat: 49.6952, lng: -112.8334, heading: 0 },
  { lat: 49.6958, lng: -112.8334, heading: 0 },
  { lat: 49.6958, lng: -112.8326, heading: 90 },
  { lat: 49.6952, lng: -112.8326, heading: 180 },
];

const session = await otpLogin(phone);
await acceptLocationNotice(session.accessToken);
const vehicleId = await resolveVehicle(flag('vehicle') ?? process.env.SIM_VEHICLE_ID);
const shift = await api('/api/v1/driver/shift/start', {
  method: 'POST',
  headers: bearer(session.accessToken),
  body: JSON.stringify(vehicleId ? { vehicleId } : {}),
});
console.log(
  `driver ${phone} behavior=${behavior} delay=${delaySeconds}s shift ${JSON.stringify(shift)}`,
);

const socket = io(`${apiOrigin()}/driver`, {
  transports: ['websocket'],
  auth: { token: session.accessToken },
});

socket.on(SOCKET_EVENTS.driverState, (snapshot) => {
  console.log(`driver:state ${JSON.stringify(snapshot)}`);
});
socket.on(SOCKET_EVENTS.offerNew, (offer: { offerId: string }) => {
  console.log(`offer:new ${JSON.stringify(offer)}`);
  socket.emit(SOCKET_EVENTS.offerReceived, { offerId: offer.offerId });
  console.log(`offer:received ${offer.offerId}`);
  if (behavior === 'ignore') {
    console.log(`ignoring ${offer.offerId}`);
    return;
  }
  setTimeout(() => {
    void respond(offer.offerId);
  }, delaySeconds * 1000);
});
socket.on(SOCKET_EVENTS.offerExpired, (offer: { offerId: string }) => {
  console.log(`offer:expired ${JSON.stringify(offer)}`);
});
socket.on(SOCKET_EVENTS.offerCancelled, (offer: { offerId: string }) => {
  console.log(`offer:cancelled ${JSON.stringify(offer)}`);
});
socket.on('connect_error', (error: Error) => {
  console.error(`socket rejected: ${error.message}`);
});

let step = 0;
const send = () => {
  const point = loop[step % loop.length];
  step += 1;
  socket.emit(SOCKET_EVENTS.driverLocation, {
    lat: point.lat,
    lng: point.lng,
    heading: point.heading,
    accuracyM: 12,
    recordedAt: new Date().toISOString(),
  });
  console.log(`ping ${point.lat} ${point.lng}`);
};

socket.on('connect', () => {
  console.log(`connected socket=${socket.id}`);
  send();
  setInterval(send, 5_000);
});

async function respond(offerId: string) {
  const path =
    behavior === 'accept'
      ? `/api/v1/driver/offers/${offerId}/accept`
      : `/api/v1/driver/offers/${offerId}/decline`;
  try {
    const result = await api(path, {
      method: 'POST',
      headers: bearer(session.accessToken),
      body: behavior === 'decline' ? JSON.stringify({ reason: 'Not taking this one' }) : undefined,
    });
    console.log(`${behavior} ${offerId} ${JSON.stringify(result)}`);
  } catch (error) {
    console.error(
      `${behavior} ${offerId} failed: ${error instanceof Error ? error.message : 'unknown error'}`,
    );
  }
}

function readBehavior(): Behavior {
  const raw = flag('behavior') ?? 'ignore';
  if (!BEHAVIORS.includes(raw as Behavior)) {
    throw new Error('--behavior must be accept, decline, or ignore');
  }
  return raw as Behavior;
}

function readDelay() {
  const raw = flag('delay');
  if (raw === undefined) return 0;
  const value = Number(raw);
  if (!Number.isFinite(value) || value < 0) {
    throw new Error('--delay must be a number of seconds');
  }
  return value;
}

async function resolveVehicle(raw: string | undefined) {
  if (!raw) return undefined;
  if (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(raw)) {
    return raw;
  }
  const prisma = new PrismaClient();
  try {
    const vehicle = await prisma.vehicle.findFirst({
      where: { plateNumber: raw.trim().toUpperCase(), active: true },
      select: { id: true },
    });
    if (!vehicle) throw new Error(`No active vehicle with plate ${raw}`);
    return vehicle.id;
  } finally {
    await prisma.$disconnect();
  }
}

async function acceptLocationNotice(accessToken: string) {
  const notice = (await api('/api/v1/driver/location-notice', {
    headers: bearer(accessToken),
  })) as { version: string };
  await api('/api/v1/driver/location-consent', {
    method: 'POST',
    headers: bearer(accessToken),
    body: JSON.stringify({ version: notice.version }),
  });
}
