import { io } from 'socket.io-client';
import { SOCKET_EVENTS } from '@bridgecabs/shared-types';
import { api, apiOrigin, loadEnvFile } from './load-env.js';

loadEnvFile();

const phone = flag('phone') ?? process.env.SIM_DRIVER_PHONE ?? '+14035551001';
const code = process.env.OTP_DEV_CODE;
if (!code || code.length !== 6) {
  throw new Error('Set OTP_DEV_CODE to the 6 digit development code');
}

const loop = [
  { lat: 49.6935, lng: -112.8418, heading: 0 },
  { lat: 49.6955, lng: -112.8418, heading: 0 },
  { lat: 49.6955, lng: -112.8388, heading: 90 },
  { lat: 49.6935, lng: -112.8388, heading: 180 },
];

const session = await login();
await acceptLocationNotice(session.accessToken);
const shift = await api('/api/v1/driver/shift/start', {
  method: 'POST',
  headers: { authorization: `Bearer ${session.accessToken}` },
  body: JSON.stringify(process.env.SIM_VEHICLE_ID ? { vehicleId: process.env.SIM_VEHICLE_ID } : {}),
});
console.log(`shift ${JSON.stringify(shift)}`);

const socket = io(`${apiOrigin()}/driver`, {
  transports: ['websocket'],
  auth: { token: session.accessToken },
});

socket.on(SOCKET_EVENTS.driverState, (snapshot) => {
  console.log(`driver:state ${JSON.stringify(snapshot)}`);
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

async function login() {
  const requested = await fetch(`${apiOrigin()}/api/v1/auth/otp/request`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ phone }),
  });
  if (requested.status !== 202 && requested.status !== 429) {
    throw new Error(`OTP request failed: ${requested.status} ${await requested.text()}`);
  }
  return (await api('/api/v1/auth/otp/verify', {
    method: 'POST',
    body: JSON.stringify({ phone, code }),
  })) as { accessToken: string };
}

function flag(name: string) {
  const index = process.argv.indexOf(`--${name}`);
  if (index === -1) return undefined;
  const value = process.argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`--${name} needs a value`);
  }
  return value;
}

async function acceptLocationNotice(accessToken: string) {
  const notice = (await api('/api/v1/driver/location-notice', {
    headers: { authorization: `Bearer ${accessToken}` },
  })) as { version: string };
  await api('/api/v1/driver/location-consent', {
    method: 'POST',
    headers: { authorization: `Bearer ${accessToken}` },
    body: JSON.stringify({ version: notice.version }),
  });
}
