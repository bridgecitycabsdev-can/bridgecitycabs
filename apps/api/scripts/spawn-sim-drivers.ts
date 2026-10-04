/**
 * Programmatic Day 6 sim-driver: open N driver sockets in one process.
 *
 * Usage (API must already be running):
 *   pnpm exec tsx scripts/spawn-sim-drivers.ts --count 100 --branch <branchId> --behavior accept
 *
 * Upserts load-test drivers/vehicles, mints JWTs (skips OTP caps), starts shifts,
 * and keeps location pings flowing so matching hits Redis geo rather than NO_DRIVER_FOUND.
 * Also writes loadtest/passenger-tokens.json for the k6 booking script.
 */
import { createHmac } from 'node:crypto';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { io, type Socket } from 'socket.io-client';
import { SOCKET_EVENTS } from '@bridgecabs/shared-types';
import { PrismaClient } from '@prisma/client';
import { LOCATION_NOTICE_VERSION } from '../src/fleet/location-notice.js';
import { loadEnvFile } from './load-env.js';
import { api, apiOrigin, bearer, flag } from './sim-session.js';

loadEnvFile();

const BEHAVIORS = ['accept', 'decline', 'ignore'] as const;
type Behavior = (typeof BEHAVIORS)[number];

const count = readInt('count', 100);
const branchId = flag('branch');
if (!branchId) throw new Error('Pass --branch <branchId>');
const behavior = readBehavior();
const delaySeconds = readNumber('delay', 0);
const passengerCount = readInt('passengers', Math.max(60, Math.ceil(count / 2)));

const LOOP = [
  { lat: 49.6952, lng: -112.8334, heading: 0 },
  { lat: 49.6958, lng: -112.8334, heading: 0 },
  { lat: 49.6958, lng: -112.8326, heading: 90 },
  { lat: 49.6952, lng: -112.8326, heading: 180 },
];

const prisma = new PrismaClient();
const secret = process.env.JWT_ACCESS_SECRET?.trim();
if (!secret) throw new Error('JWT_ACCESS_SECRET is required');

const sockets: Socket[] = [];
const timers: ReturnType<typeof setInterval>[] = [];

try {
  const ctx = await prepareBranch(branchId);
  console.log(
    `spawning ${count} drivers on branch ${branchId} behavior=${behavior} delay=${delaySeconds}s`,
  );

  const drivers = await ensureDrivers(ctx, count);
  const passengers = await ensurePassengers(ctx.passengerRoleId, passengerCount);
  writePassengerTokens(passengers);

  await mapPool(drivers, 5, async (driver, index) => {
    await ensureConsent(driver.driverId, driver.userId);
    const token = mintAccessToken({
      sub: driver.userId,
      role: 'driver',
      branchId,
    });
    await startShiftWithRetry(token, driver.vehicleId);
    const socket = attachDriver(token, index, driver.phone);
    sockets.push(socket);
  });

  console.log(
    `ready: ${sockets.length} driver sockets; ${passengers.length} passenger tokens → loadtest/passenger-tokens.json`,
  );
  console.log('leave this process running while k6 hits passenger bookings');
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
  await shutdown(1);
}

process.on('SIGINT', () => {
  void shutdown(0);
});
process.on('SIGTERM', () => {
  void shutdown(0);
});

function attachDriver(accessToken: string, index: number, phone: string) {
  const socket = io(`${apiOrigin()}/driver`, {
    transports: ['websocket'],
    auth: { token: accessToken },
  });

  socket.on(SOCKET_EVENTS.offerNew, (offer: { offerId: string }) => {
    socket.emit(SOCKET_EVENTS.offerReceived, { offerId: offer.offerId });
    if (behavior === 'ignore') return;
    setTimeout(() => {
      void respond(accessToken, offer.offerId);
    }, delaySeconds * 1000);
  });

  socket.on('connect_error', (error: Error) => {
    console.error(`[${phone}] socket rejected: ${error.message}`);
  });

  let step = index % LOOP.length;
  const send = () => {
    const point = LOOP[step % LOOP.length]!;
    step += 1;
    socket.emit(SOCKET_EVENTS.driverLocation, {
      lat: point.lat,
      lng: point.lng,
      heading: point.heading,
      accuracyM: 12,
      recordedAt: new Date().toISOString(),
    });
  };

  socket.on('connect', () => {
    send();
    timers.push(setInterval(send, 5_000));
  });

  return socket;
}

async function respond(accessToken: string, offerId: string) {
  const path =
    behavior === 'accept'
      ? `/api/v1/driver/offers/${offerId}/accept`
      : `/api/v1/driver/offers/${offerId}/decline`;
  try {
    await api(path, {
      method: 'POST',
      headers: bearer(accessToken),
      body:
        behavior === 'decline'
          ? JSON.stringify({ reason: 'load-test decline' })
          : undefined,
    });
  } catch (error) {
    // Contended accept under load is expected; the Postgres unique indexes are the real pass check.
    if (process.env.SPAWN_VERBOSE === '1') {
      console.error(
        `${behavior} ${offerId}: ${error instanceof Error ? error.message : error}`,
      );
    }
  }
}

async function prepareBranch(id: string) {
  const branch = await prisma.branch.findUnique({ where: { id } });
  if (!branch) throw new Error(`Branch ${id} not found`);

  const driverRole = await prisma.role.findUnique({ where: { name: 'driver' } });
  const passengerRole = await prisma.role.findUnique({
    where: { name: 'passenger' },
  });
  if (!driverRole || !passengerRole) {
    throw new Error('Missing driver or passenger role — run prisma seed');
  }

  const approver = await prisma.user.findFirst({
    where: { role: { name: 'super_admin' }, isActive: true },
    select: { id: true },
  });
  if (!approver) throw new Error('No super_admin user to approve load drivers');

  const sedan = await prisma.vehicleType.findFirst({
    where: { name: 'Sedan', active: true },
  });
  if (!sedan) {
    throw new Error('No active Sedan vehicle type — run prisma seed');
  }
  const model = await prisma.vehicleModel.findFirst({
    where: { vehicleTypeId: sedan.id },
    select: { id: true, vehicleTypeId: true },
  });
  if (!model) {
    throw new Error('No Sedan vehicle model — run prisma seed');
  }

  return {
    branchId: branch.id,
    driverRoleId: driverRole.id,
    passengerRoleId: passengerRole.id,
    approvedById: approver.id,
    modelId: model.id,
    vehicleTypeId: model.vehicleTypeId,
  };
}

async function ensureDrivers(
  ctx: Awaited<ReturnType<typeof prepareBranch>>,
  n: number,
) {
  const out: { userId: string; driverId: string; vehicleId: string; phone: string }[] =
    [];
  for (let i = 0; i < n; i += 1) {
    const phone = `+1403555${String(2000 + i).padStart(4, '0')}`;
    const email = `load.driver.${i}@bridgecabs.local`;
    const plate = `LD${String(i).padStart(4, '0')}`;
    const unit = String(2000 + i);

    const account = await prisma.user.upsert({
      where: { email },
      update: {
        phone,
        roleId: ctx.driverRoleId,
        branchId: ctx.branchId,
        isActive: true,
        passwordHash: null,
      },
      create: {
        email,
        phone,
        roleId: ctx.driverRoleId,
        branchId: ctx.branchId,
        isActive: true,
      },
    });

    const driver = await prisma.driver.upsert({
      where: { userId: account.id },
      update: {
        branchId: ctx.branchId,
        firstName: 'Load',
        lastName: `Driver${i}`,
        phone,
        status: 'APPROVED',
        approvedAt: new Date(),
        approvedById: ctx.approvedById,
        suspensionReason: null,
      },
      create: {
        userId: account.id,
        branchId: ctx.branchId,
        firstName: 'Load',
        lastName: `Driver${i}`,
        phone,
        status: 'APPROVED',
        approvedAt: new Date(),
        approvedById: ctx.approvedById,
      },
    });

    const vehicle = await prisma.vehicle.upsert({
      where: {
        branchId_plateNumber: { branchId: ctx.branchId, plateNumber: plate },
      },
      update: {
        unitNumber: unit,
        year: 2022,
        color: 'Silver',
        seats: 4,
        modelId: ctx.modelId,
        vehicleTypeId: ctx.vehicleTypeId,
        active: true,
      },
      create: {
        branchId: ctx.branchId,
        plateNumber: plate,
        unitNumber: unit,
        year: 2022,
        color: 'Silver',
        seats: 4,
        modelId: ctx.modelId,
        vehicleTypeId: ctx.vehicleTypeId,
        active: true,
      },
    });

    const open = await prisma.driverVehicleAssignment.findFirst({
      where: { driverId: driver.id, endedAt: null },
    });
    if (!open) {
      const vehicleTaken = await prisma.driverVehicleAssignment.findFirst({
        where: { vehicleId: vehicle.id, endedAt: null },
      });
      if (vehicleTaken && vehicleTaken.driverId !== driver.id) {
        await prisma.driverVehicleAssignment.update({
          where: { id: vehicleTaken.id },
          data: { endedAt: new Date() },
        });
      }
      await prisma.driverVehicleAssignment.create({
        data: { driverId: driver.id, vehicleId: vehicle.id },
      });
    } else if (open.vehicleId !== vehicle.id) {
      await prisma.driverVehicleAssignment.update({
        where: { id: open.id },
        data: { endedAt: new Date() },
      });
      await prisma.driverVehicleAssignment.create({
        data: { driverId: driver.id, vehicleId: vehicle.id },
      });
    }

    await ensureDocuments(driver.id, vehicle.id);
    out.push({
      userId: account.id,
      driverId: driver.id,
      vehicleId: vehicle.id,
      phone,
    });
  }
  return out;
}

async function ensureDocuments(driverId: string, vehicleId: string) {
  const required = await prisma.documentType.findMany({ where: { required: true } });
  const expiresAt = new Date('2030-01-01T00:00:00.000Z');
  for (const documentType of required) {
    const dId = documentType.owner === 'DRIVER' ? driverId : null;
    const vId = documentType.owner === 'VEHICLE' ? vehicleId : null;
    const existing = await prisma.document.findFirst({
      where: {
        documentTypeId: documentType.id,
        driverId: dId,
        vehicleId: vId,
      },
    });
    if (existing) {
      if (existing.status !== 'APPROVED') {
        await prisma.document.update({
          where: { id: existing.id },
          data: { status: 'APPROVED', expiresAt },
        });
      }
      continue;
    }
    await prisma.document.create({
      data: {
        documentTypeId: documentType.id,
        driverId: dId,
        vehicleId: vId,
        status: 'APPROVED',
        storageKey: `loadtest/${driverId}/${documentType.code}`,
        expiresAt,
      },
    });
  }
}

async function ensureConsent(driverId: string, userId: string) {
  await prisma.driverLocationConsent.upsert({
    where: {
      driverId_noticeVersion: {
        driverId,
        noticeVersion: LOCATION_NOTICE_VERSION,
      },
    },
    create: { driverId, noticeVersion: LOCATION_NOTICE_VERSION },
    update: {},
  });
  const existing = await prisma.consentRecord.findFirst({
    where: {
      userId,
      type: 'LOCATION_TRACKING',
      version: LOCATION_NOTICE_VERSION,
    },
  });
  if (!existing) {
    await prisma.consentRecord.create({
      data: {
        userId,
        type: 'LOCATION_TRACKING',
        version: LOCATION_NOTICE_VERSION,
      },
    });
  }
}

async function ensurePassengers(roleId: string, n: number) {
  const tokens: { phone: string; accessToken: string }[] = [];
  for (let i = 0; i < n; i += 1) {
    const phone = `+1403556${String(1000 + i).padStart(4, '0')}`;
    const email = `load.passenger.${i}@bridgecabs.local`;
    const account = await prisma.user.upsert({
      where: { email },
      update: {
        phone,
        roleId,
        branchId: null,
        isActive: true,
        passwordHash: null,
      },
      create: {
        email,
        phone,
        roleId,
        isActive: true,
      },
    });
    await prisma.passenger.upsert({
      where: { userId: account.id },
      update: {
        firstName: 'Load',
        lastName: `Passenger${i}`,
        phone,
        email,
        blocked: false,
        blockReason: null,
        blockedAt: null,
        unblockReason: null,
      },
      create: {
        userId: account.id,
        firstName: 'Load',
        lastName: `Passenger${i}`,
        phone,
        email,
      },
    });
    tokens.push({
      phone,
      accessToken: mintAccessToken({
        sub: account.id,
        role: 'passenger',
        branchId: null,
      }),
    });
  }
  return tokens;
}

function writePassengerTokens(tokens: { phone: string; accessToken: string }[]) {
  const root = resolve(dirname(fileURLToPath(import.meta.url)), '../../..');
  const path = resolve(root, 'loadtest/passenger-tokens.json');
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(
    path,
    JSON.stringify(
      {
        branchId,
        generatedAt: new Date().toISOString(),
        tokens: tokens.map((row) => row.accessToken),
      },
      null,
      2,
    ),
  );
}

async function startShiftWithRetry(accessToken: string, vehicleId: string) {
  for (let attempt = 0; attempt < 8; attempt += 1) {
    try {
      await api('/api/v1/driver/shift/start', {
        method: 'POST',
        headers: bearer(accessToken),
        body: JSON.stringify({ vehicleId }),
      });
      return;
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      if (!message.includes('429') && !message.includes('Throttler')) throw error;
      await sleep(250 * (attempt + 1));
    }
  }
  throw new Error('shift/start exhausted retries (raise THROTTLE_LIMIT for spawn)');
}

function mintAccessToken(payload: {
  sub: string;
  role: string;
  branchId: string | null;
}) {
  const header = Buffer.from(
    JSON.stringify({ alg: 'HS256', typ: 'JWT' }),
  ).toString('base64url');
  const now = Math.floor(Date.now() / 1000);
  const body = Buffer.from(
    JSON.stringify({
      ...payload,
      iat: now,
      exp: now + 60 * 60 * 4,
    }),
  ).toString('base64url');
  const data = `${header}.${body}`;
  const sig = createHmac('sha256', secret!).update(data).digest('base64url');
  return `${data}.${sig}`;
}

async function mapPool<T>(
  items: T[],
  concurrency: number,
  fn: (item: T, index: number) => Promise<void>,
) {
  let next = 0;
  async function worker() {
    while (next < items.length) {
      const index = next;
      next += 1;
      await fn(items[index]!, index);
    }
  }
  await Promise.all(
    Array.from({ length: Math.min(concurrency, items.length) }, () => worker()),
  );
}

async function shutdown(code: number) {
  for (const timer of timers) clearInterval(timer);
  for (const socket of sockets) socket.disconnect();
  await prisma.$disconnect();
  process.exit(code);
}

function readBehavior(): Behavior {
  const raw = flag('behavior') ?? 'accept';
  if (!BEHAVIORS.includes(raw as Behavior)) {
    throw new Error('--behavior must be accept, decline, or ignore');
  }
  return raw as Behavior;
}

function readInt(name: string, fallback: number) {
  const raw = flag(name);
  if (raw === undefined) return fallback;
  const value = Number(raw);
  if (!Number.isInteger(value) || value < 1) {
    throw new Error(`--${name} must be a positive integer`);
  }
  return value;
}

function readNumber(name: string, fallback: number) {
  const raw = flag(name);
  if (raw === undefined) return fallback;
  const value = Number(raw);
  if (!Number.isFinite(value) || value < 0) {
    throw new Error(`--${name} must be a non-negative number`);
  }
  return value;
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
