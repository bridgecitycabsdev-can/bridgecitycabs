import { io } from 'socket.io-client';
import { SOCKET_EVENTS } from '@bridgecabs/shared-types';
import { api, apiOrigin, loadEnvFile } from './load-env.js';

loadEnvFile();

const branchFlag = flag('branch');

const email = process.env.SEED_ADMIN_EMAIL;
const password = process.env.SEED_ADMIN_PASSWORD;
if (!email || !password) {
  throw new Error('SEED_ADMIN_EMAIL and SEED_ADMIN_PASSWORD must be set');
}

const session = (await api('/api/v1/auth/login', {
  method: 'POST',
  body: JSON.stringify({ email, password }),
})) as { accessToken: string };

const me = (await api('/api/v1/auth/me', {
  headers: { authorization: `Bearer ${session.accessToken}` },
})) as { role: { name: string }; branch: { id: string; city: string } | null };

const socket = io(`${apiOrigin()}/dispatch`, {
  transports: ['websocket'],
  auth: { token: session.accessToken },
});

for (const event of [
  SOCKET_EVENTS.fleetSnapshot,
  SOCKET_EVENTS.fleetDriverUpdated,
  SOCKET_EVENTS.bookingCreated,
  SOCKET_EVENTS.bookingStatusChanged,
  SOCKET_EVENTS.offerCreated,
  SOCKET_EVENTS.offerResolved,
]) {
  socket.on(event, (payload) => {
    console.log(`${event} ${JSON.stringify(payload)}`);
  });
}

socket.on('connect_error', (error: Error) => {
  console.error(`socket rejected: ${error.message}`);
});

socket.on('connect', async () => {
  console.log(`connected socket=${socket.id} role=${me.role.name}`);
  const branchId =
    branchFlag ??
    process.env.SIM_BRANCH_ID ??
    (me.role.name === 'super_admin' ? await lethbridgeBranchId(session.accessToken) : me.branch?.id);
  if (!branchId) return;
  if (!branchFlag && me.role.name !== 'super_admin' && me.branch) return;
  const result = await socket.timeout(5000).emitWithAck(SOCKET_EVENTS.fleetSubscribe, { branchId });
  console.log(`fleet:subscribe ${branchId} ${JSON.stringify(result)}`);
});

function flag(name: string) {
  const index = process.argv.indexOf(`--${name}`);
  if (index === -1) return undefined;
  const value = process.argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`--${name} needs a value`);
  }
  return value;
}

async function lethbridgeBranchId(accessToken: string) {
  const branches = (await api('/api/v1/branches', {
    headers: { authorization: `Bearer ${accessToken}` },
  })) as { id: string; name: string; city: string }[];
  const home =
    branches.find((branch) => branch.name === 'Lethbridge') ??
    branches.find((branch) => branch.city === 'Lethbridge');
  if (!home) throw new Error('No Lethbridge branch. Set SIM_BRANCH_ID.');
  return home.id;
}
