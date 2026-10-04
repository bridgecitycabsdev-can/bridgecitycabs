import { randomUUID } from 'node:crypto';
import { resolve } from 'node:path';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import type { Redis } from 'ioredis';
import { io, type Socket as ClientSocket } from 'socket.io-client';
import request from 'supertest';
import { AppModule } from '../src/app.module.js';
import { FleetStateService } from '../src/fleet/fleet-state.service.js';
import { RedisIoAdapter } from '../src/realtime/redis-io.adapter.js';
import { SocketLimits } from '../src/realtime/socket-limits.js';
import { REDIS, REDIS_SUBSCRIBER } from '../src/redis/redis.constants.js';
import { LOC_BUFFER_KEY, driverKey, presenceKey, socketConnKey, socketRateKey } from '../src/redis/redis.keys.js';
import { grantLocationConsent } from './location-consent.js';
import { loadEnvFile } from './load-env-file.js';

loadEnvFile();

const prisma = new PrismaClient();
const stamp = Date.now();
const tail = String(stamp).slice(-6);
const driverPhone = `+1403${String(stamp).slice(-7)}`;
const passengerPhone = `+1587${String(stamp).slice(-7)}`;
const otherPassengerPhone = `+1780${String(stamp).slice(-7)}`;
const lethbridge = { lat: 49.6935, lng: -112.8418 };
const urlToken = 'url-token-must-not-leak';

describe('privacy (e2e)', () => {
  let app: INestApplication;
  let redis: Redis;
  let fleet: FleetStateService;
  let jwt: JwtService;
  let baseUrl = '';
  const clients: ClientSocket[] = [];
  const userIds: string[] = [];
  let homeBranchId: string;
  let otherBranchId: string;
  let driverId: string;
  let driverUserId: string;
  let vehicleId: string;
  let typeId: string;
  let makeId: string;
  let modelId: string;
  let bookingId = '';
  let dispatcherUserId: string;
  let adminUserId: string;
  let passengerToken = '';
  let otherPassengerToken = '';
  let dispatcherToken = '';
  let adminToken = '';
  let otherAdminToken = '';
  let superToken = '';

  beforeAll(async () => {
    process.env.SOCKET_MAX_CONNECTIONS_PER_USER = '2';
    process.env.SOCKET_EVENT_LIMIT = '2';
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
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
    fleet = app.get(FleetStateService);
    jwt = app.get(JwtService);
    const address = app.getHttpServer().address();
    const port = typeof address === 'object' && address ? address.port : 0;
    baseUrl = `http://127.0.0.1:${port}`;

    const home = await prisma.branch.create({
      data: { name: `E2E Privacy ${stamp}`, city: 'Lethbridge', timezone: 'America/Edmonton' },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Privacy Other ${stamp}`, city: 'Calgary' },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    const vehicleType = await prisma.vehicleType.create({ data: { name: `E2E Privacy Type ${stamp}` } });
    typeId = vehicleType.id;
    const make = await prisma.vehicleMake.create({ data: { name: `E2E Privacy Make ${stamp}` } });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: { makeId, vehicleTypeId: typeId, name: `E2E Privacy Model ${stamp}` },
    });
    modelId = model.id;
    const vehicle = await prisma.vehicle.create({
      data: {
        branchId: homeBranchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: `PV${tail}`,
        unitNumber: '11',
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
        email: `e2e-privacy-driver-${stamp}@example.com`,
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
    dispatcherUserId = await createUser('dispatcher', homeBranchId);
    adminUserId = await createUser('branch_admin', homeBranchId);
    const otherAdminUserId = await createUser('branch_admin', otherBranchId);
    const superUserId = await createUser('super_admin', null);
    dispatcherToken = sign(dispatcherUserId, 'dispatcher', homeBranchId);
    adminToken = sign(adminUserId, 'branch_admin', homeBranchId);
    otherAdminToken = sign(otherAdminUserId, 'branch_admin', otherBranchId);
    superToken = sign(superUserId, 'super_admin', null);
  });

  afterAll(async () => {
    for (const socket of clients) socket.disconnect();
    if (bookingId) {
      await prisma.$transaction(async (tx) => {
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" DISABLE TRIGGER booking_history_immutable',
        );
        await tx.bookingStatusHistory.deleteMany({ where: { bookingId } });
        await tx.bookingStop.deleteMany({ where: { bookingId } });
        await tx.booking.deleteMany({ where: { id: bookingId } });
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" ENABLE TRIGGER booking_history_immutable',
        );
      });
    }
    if (driverId) {
      await prisma.locationAccessLog.deleteMany({ where: { driverId } });
      await prisma.driverLocationLog.deleteMany({ where: { driverId } });
      await prisma.driverShift.deleteMany({ where: { driverId } });
      await prisma.driverVehicleAssignment.deleteMany({ where: { driverId } });
      await prisma.document.deleteMany({ where: { OR: [{ driverId }, { vehicleId }] } });
      await prisma.driver.deleteMany({ where: { id: driverId } });
    }
    const passengerUsers = await prisma.passenger.findMany({
      where: { userId: { in: userIds } },
      select: { id: true },
    });
    if (passengerUsers.length) {
      await prisma.passenger.deleteMany({ where: { id: { in: passengerUsers.map((row) => row.id) } } });
    }
    if (vehicleId) await prisma.vehicle.deleteMany({ where: { id: vehicleId } });
    if (modelId) await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    if (makeId) await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    if (typeId) await prisma.vehicleType.delete({ where: { id: typeId } }).catch(() => undefined);
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    if (homeBranchId) await prisma.branch.deleteMany({ where: { id: { in: [homeBranchId, otherBranchId] } } });
    if (redis && driverId) {
      await redis.del(driverKey(driverId), presenceKey(driverId), socketConnKey(dispatcherUserId), socketRateKey('rate-user'));
    }
    delete process.env.SOCKET_MAX_CONNECTIONS_PER_USER;
    delete process.env.SOCKET_EVENT_LIMIT;
    await prisma.$disconnect();
    if (app) await app.close();
  });

  it('refuses a token in the query string and does not echo it', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/fleet/drivers')
      .query({ token: urlToken })
      .expect(401);
    expect(JSON.stringify(response.body)).not.toContain(urlToken);
  });

  it('collects location only after the agreement and only during a shift', async () => {
    const user = { userId: driverUserId, role: 'driver', branchId: homeBranchId };
    expect(
      await fleet.recordDriverPing(driverId, {
        ...lethbridge,
        accuracyM: 8,
        recordedAt: new Date().toISOString(),
        receivedAtMs: Date.now(),
      }),
    ).toBeNull();

    await approveDocuments();
    await grantLocationConsent(prisma, driverId);
    await fleet.startShift(user, vehicleId);
    const buffered = await fleet.recordDriverPing(driverId, {
      ...lethbridge,
      accuracyM: 8,
      recordedAt: new Date().toISOString(),
      receivedAtMs: Date.now(),
    });
    expect(buffered).toBe(homeBranchId);
    const mine = (await redis.lrange(LOC_BUFFER_KEY, 0, -1)).filter((row) => row.includes(driverId));
    expect(mine.length).toBeGreaterThan(0);

    await fleet.endShift(user);
    expect(
      await fleet.recordDriverPing(driverId, {
        ...lethbridge,
        accuracyM: 8,
        recordedAt: new Date().toISOString(),
        receivedAtMs: Date.now(),
      }),
    ).toBeNull();
  });

  it('shows a driver position only to the passenger on that live trip', async () => {
    const user = { userId: driverUserId, role: 'driver', branchId: homeBranchId };
    await fleet.startShift(user, vehicleId);
    await fleet.updateLocation(driverId, lethbridge);
    const passenger = await createPassenger('Leila', passengerPhone);
    const stranger = await createPassenger('Noah', otherPassengerPhone);
    passengerToken = sign(passenger.userId, 'passenger', null);
    otherPassengerToken = sign(stranger.userId, 'passenger', null);
    const booking = await prisma.booking.create({
      data: {
        trackingId: `BC-PV${tail}`,
        branchId: homeBranchId,
        source: 'DISPATCH',
        status: 'TRIP_STARTED',
        passengerId: passenger.id,
        passengerName: 'Leila Hassan',
        passengerPhone,
        vehicleTypeId: typeId,
        distanceMeters: 1000,
        durationSeconds: 300,
        quotedFareCents: 2500,
        quotedTaxCents: 125,
        driverId,
        vehicleId,
        stops: {
          create: [
            { sequence: 0, type: 'PICKUP', address: 'City Hall', lat: lethbridge.lat, lng: lethbridge.lng },
          ],
        },
      },
    });
    bookingId = booking.id;

    const live = await request(app.getHttpServer())
      .get(`/api/v1/passenger/bookings/${bookingId}/driver-location`)
      .set('Authorization', `Bearer ${passengerToken}`)
      .expect(200);
    expect(live.body.lat).toBeCloseTo(lethbridge.lat, 3);
    expect(live.body.lng).toBeCloseTo(lethbridge.lng, 3);
    expect(live.body.phone).toBeUndefined();
    expect(JSON.stringify(live.body)).not.toContain(passengerPhone);

    await request(app.getHttpServer())
      .get(`/api/v1/passenger/bookings/${bookingId}/driver-location`)
      .set('Authorization', `Bearer ${otherPassengerToken}`)
      .expect(404);
    await request(app.getHttpServer())
      .get(`/api/v1/passenger/bookings/${bookingId}/driver-location`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .expect(403);

    await prisma.booking.update({ where: { id: bookingId }, data: { status: 'TRIP_COMPLETED' } });
    await request(app.getHttpServer())
      .get(`/api/v1/passenger/bookings/${bookingId}/driver-location`)
      .set('Authorization', `Bearer ${passengerToken}`)
      .expect(404);
  });

  it('limits location history to branch and super admins and logs the read', async () => {
    await prisma.driverLocationLog.create({
      data: { driverId, lat: lethbridge.lat, lng: lethbridge.lng, recordedAt: new Date() },
    });
    await request(app.getHttpServer())
      .get(`/api/v1/drivers/${driverId}/locations`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .expect(403);
    await request(app.getHttpServer())
      .get(`/api/v1/drivers/${driverId}/locations`)
      .set('Authorization', `Bearer ${otherAdminToken}`)
      .expect(404);

    const history = await request(app.getHttpServer())
      .get(`/api/v1/drivers/${driverId}/locations`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(history.body.data[0].lat).toBeCloseTo(lethbridge.lat, 3);
    expect(await prisma.locationAccessLog.count({ where: { driverId, actorUserId: adminUserId } })).toBe(1);

    await request(app.getHttpServer())
      .get(`/api/v1/drivers/${driverId}/locations`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(await prisma.locationAccessLog.count({ where: { driverId } })).toBe(2);
  });

  it('caps concurrent sockets and drops a token passed in the url', async () => {
    const limits = app.get(SocketLimits);
    expect(await limits.allowEvent('rate-user')).toBe(true);
    expect(await limits.allowEvent('rate-user')).toBe(true);
    expect(await limits.allowEvent('rate-user')).toBe(false);

    const first = connect('/dispatch', dispatcherToken);
    const second = connect('/dispatch', dispatcherToken);
    await once(first, 'connect', 8_000);
    await once(second, 'connect', 8_000);
    const third = connect('/dispatch', dispatcherToken);
    await once(third, 'disconnect', 8_000);
    expect(first.connected).toBe(true);
    expect(second.connected).toBe(true);

    const leaked = io(`${baseUrl}/dispatch`, {
      transports: ['websocket'],
      reconnection: false,
      auth: { token: dispatcherToken },
      query: { token: urlToken },
    });
    clients.push(leaked);
    await once(leaked, 'connect_error', 3000);
    expect(leaked.connected).toBe(false);
  });

  function connect(namespace: string, token: string) {
    const socket = io(`${baseUrl}${namespace}`, {
      transports: ['websocket'],
      reconnection: false,
      auth: { token },
    });
    clients.push(socket);
    return socket;
  }

  function sign(userId: string, role: string, branchId: string | null) {
    return jwt.sign({ sub: userId, role, branchId }, { expiresIn: '15m' });
  }

  async function createUser(roleName: string, branchId: string | null) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-privacy-${roleName}-${randomUUID().slice(0, 8)}-${stamp}@example.com`,
        roleId: role.id,
        branchId,
      },
    });
    userIds.push(user.id);
    return user.id;
  }

  async function createPassenger(firstName: string, phone: string) {
    const role = await prisma.role.upsert({
      where: { name: 'passenger' },
      update: {},
      create: { name: 'passenger' },
    });
    const user = await prisma.user.create({
      data: { phone, roleId: role.id },
    });
    userIds.push(user.id);
    return prisma.passenger.create({
      data: { userId: user.id, firstName, phone },
    });
  }

  async function approveDocuments() {
    const required = await prisma.documentType.findMany({ where: { required: true } });
    for (const documentType of required) {
      await prisma.document.create({
        data: {
          documentTypeId: documentType.id,
          driverId: documentType.owner === 'DRIVER' ? driverId : null,
          vehicleId: documentType.owner === 'VEHICLE' ? vehicleId : null,
          storageKey: `e2e/privacy/${stamp}/${documentType.code}`,
          status: 'APPROVED',
          expiresAt: new Date('2030-01-01T00:00:00.000Z'),
          reviewedAt: new Date(),
        },
      });
    }
  }
});

function once(socket: ClientSocket, event: string, ms: number) {
  return new Promise<void>((resolve, reject) => {
    const timer = setTimeout(() => {
      socket.off(event, onEvent);
      reject(new Error(`timed out waiting for ${event}`));
    }, ms);
    const onEvent = () => {
      clearTimeout(timer);
      resolve();
    };
    socket.once(event, onEvent);
  });
}

