import { resolve } from 'node:path';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import type { Redis } from 'ioredis';
import { io, type Socket as ClientSocket } from 'socket.io-client';
import { SOCKET_EVENTS } from '@bridgecabs/shared-types';
import { AppModule } from '../src/app.module.js';
import { FleetBroadcaster } from '../src/realtime/fleet-broadcaster.js';
import { grantLocationConsent } from './location-consent.js';
import { FleetStateService } from '../src/fleet/fleet-state.service.js';
import { RedisIoAdapter } from '../src/realtime/redis-io.adapter.js';
import { REDIS, REDIS_SUBSCRIBER } from '../src/redis/redis.constants.js';
import { loadEnvFile } from './load-env-file.js';
import {
  DRIVER_HASH_FIELDS,
  LOC_BUFFER_KEY,
  driverKey,
  geoAvailableKey,
  presenceKey,
  sessionKey,
} from '../src/redis/redis.keys.js';

loadEnvFile();

const prisma = new PrismaClient();
const stamp = Date.now();
const tail = String(stamp).slice(-6);
const driverPhone = `+1403${String(stamp).slice(-7)}`;
const lethbridge = { lat: 49.6935, lng: -112.8418 };
const calgary = { lat: 51.0447, lng: -114.0719 };
const nearby = { lat: 49.694, lng: -112.8418 };

describe('sockets (e2e)', () => {
  let app: INestApplication;
  let redis: Redis;
  let jwt: JwtService;
  let baseUrl = '';
  const clients: ClientSocket[] = [];
  const userIds: string[] = [];
  const branchIds: string[] = [];
  let homeBranchId: string;
  let driverId: string;
  let driverUserId: string;
  let vehicleId: string;
  let typeId: string;
  let makeId: string;
  let modelId: string;
  let driverToken = '';
  let dispatcherToken = '';
  let superToken = '';
  let passengerToken = '';

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    app.useWebSocketAdapter(
      new RedisIoAdapter(
        app.getHttpServer(),
        app.get(REDIS),
        app.get(REDIS_SUBSCRIBER),
        app.get(ConfigService),
      ),
    );
    await app.init();
    await app.listen(0);
    redis = app.get(REDIS);
    jwt = app.get(JwtService);
    const address = app.getHttpServer().address();
    const port = typeof address === 'object' && address ? address.port : 0;
    baseUrl = `http://127.0.0.1:${port}`;

    const home = await prisma.branch.create({
      data: { name: `E2E Socket ${stamp}`, city: 'Lethbridge' },
    });
    homeBranchId = home.id;
    branchIds.push(home.id);
    const vehicleType = await prisma.vehicleType.create({
      data: { name: `E2E Socket Type ${stamp}` },
    });
    typeId = vehicleType.id;
    const make = await prisma.vehicleMake.create({ data: { name: `E2E Socket Make ${stamp}` } });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: { makeId, vehicleTypeId: typeId, name: `E2E Socket Model ${stamp}` },
    });
    modelId = model.id;
    const vehicle = await prisma.vehicle.create({
      data: {
        branchId: homeBranchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: `SK${tail}`,
        unitNumber: '111',
        year: 2020,
      },
    });
    vehicleId = vehicle.id;

    const driverRole = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    const driverUser = await prisma.user.create({
      data: {
        email: `e2e-socket-driver-${stamp}@example.com`,
        phone: driverPhone,
        roleId: driverRole.id,
        branchId: homeBranchId,
      },
    });
    driverUserId = driverUser.id;
    userIds.push(driverUser.id);
    const driver = await prisma.driver.create({
      data: {
        userId: driverUser.id,
        branchId: homeBranchId,
        firstName: 'Priya',
        lastName: 'Nair',
        phone: driverPhone,
        status: 'APPROVED',
        approvedAt: new Date(),
      },
    });
    driverId = driver.id;
    await approveRequiredDocuments();
    await grantLocationConsent(prisma, driverId);

    const dispatcher = await createUser('dispatcher', homeBranchId);
    const superUser = await createUser('super_admin', null);
    const passenger = await createUser('passenger', null);
    driverToken = sign(driverUserId, 'driver', homeBranchId);
    dispatcherToken = sign(dispatcher, 'dispatcher', homeBranchId);
    superToken = sign(superUser, 'super_admin', null);
    passengerToken = sign(passenger, 'passenger', null);

    await app.get(FleetStateService).startShift(
      { userId: driverUserId, role: 'driver', branchId: homeBranchId },
      vehicleId,
    );
  });

  afterAll(async () => {
    for (const client of clients) client.disconnect();
    if (driverId) {
      const rows = redis ? await redis.lrange(LOC_BUFFER_KEY, 0, -1) : [];
      for (const row of rows) {
        if (row.includes(driverId)) await redis.lrem(LOC_BUFFER_KEY, 1, row);
      }
      await redis.del(driverKey(driverId), presenceKey(driverId), sessionKey(driverId));
      if (homeBranchId) await redis.zrem(geoAvailableKey(homeBranchId), driverId);
      await prisma.driverShift.deleteMany({ where: { driverId } });
      await prisma.document.deleteMany({ where: { OR: [{ driverId }, { vehicleId }] } });
      await prisma.driver.deleteMany({ where: { id: driverId } });
    }
    if (vehicleId) await prisma.vehicle.deleteMany({ where: { id: vehicleId } });
    if (modelId) await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    if (makeId) await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    if (typeId) await prisma.vehicleType.delete({ where: { id: typeId } }).catch(() => undefined);
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('rejects a missing token, a query-string token, the wrong role, and an inactive user', async () => {
    const missing = connect('/driver');
    expect((await once<Error>(missing, 'connect_error')).message).toBe('UNAUTHENTICATED');

    const fromQuery = io(`${baseUrl}/driver`, {
      transports: ['websocket'],
      reconnection: false,
      auth: {},
      query: { token: driverToken },
    });
    clients.push(fromQuery);
    expect((await once<Error>(fromQuery, 'connect_error')).message).toBe('UNAUTHENTICATED');

    const passenger = connect('/driver', passengerToken);
    expect((await once<Error>(passenger, 'connect_error')).message).toBe('FORBIDDEN');
    const onDispatch = connect('/dispatch', passengerToken);
    expect((await once<Error>(onDispatch, 'connect_error')).message).toBe('FORBIDDEN');

    await prisma.user.update({ where: { id: driverUserId }, data: { isActive: false } });
    const inactive = connect('/driver', driverToken);
    expect((await once<Error>(inactive, 'connect_error')).message).toBe('UNAUTHENTICATED');
    await prisma.user.update({ where: { id: driverUserId }, data: { isActive: true } });

    const expired = connect(
      '/driver',
      jwt.sign({
        sub: driverUserId,
        role: 'driver',
        branchId: homeBranchId,
        exp: Math.floor(Date.now() / 1000) - 30,
      }),
    );
    expect((await once<Error>(expired, 'connect_error')).message).toBe('UNAUTHENTICATED');
  });

  it('sends the snapshot, replaces the previous session, and leaves presence alone on disconnect', async () => {
    const first = connect('/driver', driverToken);
    const state = await once<{
      status: string;
      shift: { vehicle: { unitNumber: string } };
    }>(first, SOCKET_EVENTS.driverState);
    expect(state.status).toBe('AVAILABLE');
    expect(state.shift.vehicle.unitNumber).toBe('111');
    expect(JSON.stringify(state)).not.toContain(driverPhone);

    const replaced = once<{ at: string }>(first, SOCKET_EVENTS.sessionReplaced);
    const kicked = once(first, 'disconnect');
    const second = connect('/driver', driverToken);
    await once(second, SOCKET_EVENTS.driverState);
    expect((await replaced).at).toContain('T');
    await kicked;
    const secondId = second.id;
    expect(await redis.get(sessionKey(driverId))).toBe(secondId);

    const ended = once(second, 'disconnect');
    second.disconnect();
    await ended;
    expect(await redis.get(sessionKey(driverId))).toBe(secondId);
    expect(await redis.ttl(presenceKey(driverId))).toBeGreaterThan(0);
  });

  it('filters location pings and batches them onto the dispatch map', async () => {
    const driver = connect('/driver', driverToken);
    await once(driver, SOCKET_EVENTS.driverState);
    const dispatcher = connect('/dispatch', dispatcherToken);
    const snapshot = await once<{ drivers: { id: string; name: string }[] }>(
      dispatcher,
      SOCKET_EVENTS.fleetSnapshot,
    );
    expect(snapshot.drivers.some((row) => row.id === driverId && row.name === 'Priya Nair')).toBe(
      true,
    );
    expect(JSON.stringify(snapshot)).not.toContain(driverPhone);

    const admin = connect('/dispatch', superToken);
    await once(admin, 'connect');
    expect(await saw(admin, SOCKET_EVENTS.fleetSnapshot, 400)).toBe(false);
    const subscribed = once(admin, SOCKET_EVENTS.fleetSnapshot);
    const missing = await admin.timeout(3000).emitWithAck(SOCKET_EVENTS.fleetSubscribe, {
      branchId: '99999999-9999-4999-8999-999999999999',
    });
    expect(missing).toEqual({ error: 'NOT_FOUND' });
    const joined = await admin.timeout(3000).emitWithAck(SOCKET_EVENTS.fleetSubscribe, {
      branchId: homeBranchId,
    });
    expect(joined).toEqual({ ok: true });
    expect(
      (await subscribed) as { drivers: { id: string }[] },
    ).toMatchObject({ branchId: homeBranchId });

    const recordedAt = new Date(Date.now() - 1000).toISOString();
    driver.emit(SOCKET_EVENTS.driverLocation, {
      ...lethbridge,
      accuracyM: 12,
      recordedAt,
    });
    driver.emit(SOCKET_EVENTS.driverLocation, {
      lat: 49.6936,
      lng: -112.8418,
      accuracyM: 12,
      recordedAt: new Date().toISOString(),
    });
    await delay(200);
    expect(await position()).toEqual([
      expect.closeTo(lethbridge.lng, 3),
      expect.closeTo(lethbridge.lat, 3),
    ]);

    await delay(1100);
    driver.emit(SOCKET_EVENTS.driverLocation, {
      ...calgary,
      accuracyM: 12,
      recordedAt: new Date().toISOString(),
    });
    await delay(200);
    expect(await position()).toEqual([
      expect.closeTo(lethbridge.lng, 3),
      expect.closeTo(lethbridge.lat, 3),
    ]);

    await delay(1100);
    await redis.hset(driverKey(driverId), DRIVER_HASH_FIELDS.status, 'ON_TRIP');
    const updated = once<{ drivers: { id: string; lat: number; lng: number }[] }>(
      dispatcher,
      SOCKET_EVENTS.fleetDriverUpdated,
      4000,
    );
    driver.emit(SOCKET_EVENTS.driverLocation, {
      ...nearby,
      accuracyM: 12,
      recordedAt: new Date(Date.now() - 3_600_000).toISOString(),
    });
    const batch = await updated;
    const row = batch.drivers.find((driverRow) => driverRow.id === driverId);
    expect(row?.lat).toBeCloseTo(nearby.lat, 3);
    expect(row?.lng).toBeCloseTo(nearby.lng, 3);

    const rows = await redis.lrange(LOC_BUFFER_KEY, 0, -1);
    const mine = rows
      .filter((rowText) => rowText.includes(driverId))
      .map((rowText) => JSON.parse(rowText) as { lat: number; recordedAt: string });
    expect(mine.some((entry) => entry.recordedAt === recordedAt)).toBe(true);
    const skewed = mine.find((entry) => entry.lat === nearby.lat);
    expect(skewed?.recordedAt).not.toBe(new Date(Date.now() - 3_600_000).toISOString());
    expect(Math.abs(Date.parse(skewed?.recordedAt ?? '') - Date.now())).toBeLessThan(10_000);
  }, 15_000);

  it('ignores an offline or out-of-range ping and keeps a burst to one dispatch batch', async () => {
    await fleetMove(lethbridge);
    await redis.hset(driverKey(driverId), DRIVER_HASH_FIELDS.status, 'OFFLINE');
    const offline = connect('/driver', driverToken);
    await once(offline, SOCKET_EVENTS.driverState);
    const headingBefore = await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.heading);
    offline.emit(SOCKET_EVENTS.driverLocation, {
      ...lethbridge,
      heading: 270,
      accuracyM: 12,
      recordedAt: new Date().toISOString(),
    });
    await delay(200);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.heading)).toBe(headingBefore);

    await redis.hset(driverKey(driverId), DRIVER_HASH_FIELDS.status, 'AVAILABLE');
    await fleetMove(lethbridge);
    offline.emit(SOCKET_EVENTS.driverLocation, {
      lat: 95,
      lng: -112.8418,
      accuracyM: 12,
      recordedAt: new Date().toISOString(),
    });
    await delay(200);
    expect(Number(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.lat))).toBeCloseTo(
      lethbridge.lat,
      3,
    );

    const near = { lat: 49.7025, lng: -112.8418 };
    await fleetMove(near);
    const close = (await redis.call(
      'GEOSEARCH',
      geoAvailableKey(homeBranchId),
      'FROMLONLAT',
      String(lethbridge.lng),
      String(lethbridge.lat),
      'BYRADIUS',
      '2',
      'km',
    )) as string[];
    expect(close).toContain(driverId);
    await fleetMove(calgary);
    const far = (await redis.call(
      'GEOSEARCH',
      geoAvailableKey(homeBranchId),
      'FROMLONLAT',
      String(lethbridge.lng),
      String(lethbridge.lat),
      'BYRADIUS',
      '2',
      'km',
    )) as string[];
    expect(far).not.toContain(driverId);
    await fleetMove(lethbridge);

    const dispatcher = connect('/dispatch', dispatcherToken);
    await once(dispatcher, SOCKET_EVENTS.fleetSnapshot);
    await delay(1100);
    let batches = 0;
    dispatcher.on(SOCKET_EVENTS.fleetDriverUpdated, () => {
      batches += 1;
    });
    const recordedAt = new Date().toISOString();
    for (let ping = 0; ping < 50; ping += 1) {
      offline.emit(SOCKET_EVENTS.driverLocation, {
        ...lethbridge,
        accuracyM: 12,
        recordedAt,
      });
    }
    await delay(2500);
    expect(batches).toBeGreaterThanOrEqual(1);
    expect(batches).toBeLessThanOrEqual(2);
  }, 15_000);

  it('does not deliver another branch to a branch admin', async () => {
    const other = await prisma.branch.create({
      data: { name: `E2E Socket Other ${stamp}`, city: 'Calgary' },
    });
    branchIds.push(other.id);
    const adminUserId = await createUser('branch_admin', homeBranchId);
    const admin = connect('/dispatch', sign(adminUserId, 'branch_admin', homeBranchId));
    const home = await once<{ branchId: string }>(admin, SOCKET_EVENTS.fleetSnapshot);
    expect(home.branchId).toBe(homeBranchId);
    const forbidden = await admin.timeout(3000).emitWithAck(SOCKET_EVENTS.fleetSubscribe, {
      branchId: other.id,
    });
    expect(forbidden).toEqual({ error: 'FORBIDDEN' });

    const viewer = connect('/dispatch', superToken);
    await once(viewer, 'connect');
    await viewer.timeout(3000).emitWithAck(SOCKET_EVENTS.fleetSubscribe, { branchId: other.id });
    const heard = once(viewer, SOCKET_EVENTS.bookingCreated, 3000);
    let leaked = false;
    admin.on(SOCKET_EVENTS.bookingCreated, () => {
      leaked = true;
    });
    app.get(FleetBroadcaster).emitCreated(other.id, {
      id: '55555555-5555-4555-8555-555555555555',
      branchId: other.id,
      trackingId: `BC-SO${tail}`,
      status: 'SEARCHING_DRIVER',
      passengerName: 'Leila Hassan',
      scheduledAt: null,
      quotedFareCents: 1000,
      vehicleType: { id: typeId, name: 'SUV' },
      pickupAddress: 'Other city',
    });
    await heard;
    await delay(300);
    expect(leaked).toBe(false);
  });

  it('closes the socket at exp unless the client sends a new token', async () => {
    const expiringSocket = connect('/driver', sign(driverUserId, 'driver', homeBranchId, '8s'));
    await once(expiringSocket, SOCKET_EVENTS.authExpiring, 3000);
    await once(expiringSocket, 'disconnect', 10_000);

    const refreshing = connect('/driver', sign(driverUserId, 'driver', homeBranchId, '8s'));
    await once(refreshing, SOCKET_EVENTS.authExpiring, 2000);
    refreshing.emit(SOCKET_EVENTS.authToken, {
      token: sign(driverUserId, 'driver', homeBranchId, '15m'),
    });
    await delay(4000);
    expect(refreshing.connected).toBe(true);
    refreshing.disconnect();
  }, 15_000);

  function connect(namespace: string, token?: string) {
    const socket = io(`${baseUrl}${namespace}`, {
      transports: ['websocket'],
      reconnection: false,
      auth: token ? { token } : {},
    });
    clients.push(socket);
    return socket;
  }

  function sign(
    userId: string,
    role: string,
    branchId: string | null,
    expiresIn = '15m',
  ) {
    return jwt.sign(
      { sub: userId, role, branchId },
      { expiresIn: expiresIn as '15m' | '8s' },
    );
  }

  function fleetMove(point: { lat: number; lng: number }) {
    return app.get(FleetStateService).updateLocation(driverId, point);
  }

  async function position() {
    const point = (await redis.geopos(geoAvailableKey(homeBranchId), driverId))[0];
    return point ? [Number(point[0]), Number(point[1])] : null;
  }

  async function createUser(roleName: string, branchId: string | null) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-socket-${roleName}-${stamp}@example.com`,
        roleId: role.id,
        branchId,
      },
    });
    userIds.push(user.id);
    return user.id;
  }

  async function approveRequiredDocuments() {
    const required = await prisma.documentType.findMany({ where: { required: true } });
    for (const documentType of required) {
      await prisma.document.create({
        data: {
          documentTypeId: documentType.id,
          driverId: documentType.owner === 'DRIVER' ? driverId : null,
          vehicleId: documentType.owner === 'VEHICLE' ? vehicleId : null,
          storageKey: `e2e/socket/${stamp}/${documentType.code}`,
          status: 'APPROVED',
          expiresAt: new Date('2030-01-01T00:00:00.000Z'),
          reviewedAt: new Date(),
        },
      });
    }
  }
});

function once<T>(socket: ClientSocket, event: string, ms = 4000) {
  return new Promise<T>((resolve, reject) => {
    const timer = setTimeout(() => {
      socket.off(event, onEvent);
      reject(new Error(`timed out waiting for ${event}`));
    }, ms);
    const onEvent = (payload: T) => {
      clearTimeout(timer);
      resolve(payload);
    };
    socket.once(event, onEvent);
  });
}

function saw(socket: ClientSocket, event: string, ms: number) {
  return new Promise<boolean>((resolve) => {
    const onEvent = () => {
      clearTimeout(timer);
      resolve(true);
    };
    const timer = setTimeout(() => {
      socket.off(event, onEvent);
      resolve(false);
    }, ms);
    socket.once(event, onEvent);
  });
}

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

