import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import type { Redis } from 'ioredis';
import { io, type Socket as ClientSocket } from 'socket.io-client';
import request from 'supertest';
import { SOCKET_EVENTS } from '@bridgecabs/shared-types';
import { AppModule } from '../src/app.module.js';
import { grantLocationConsent } from './location-consent.js';
import { BookingStateService } from '../src/bookings/booking-state.service.js';
import { FleetStateService } from '../src/fleet/fleet-state.service.js';
import { FleetReconciler } from '../src/realtime/fleet-reconciler.js';
import { RedisIoAdapter } from '../src/realtime/redis-io.adapter.js';
import { REDIS, REDIS_SUBSCRIBER } from '../src/redis/redis.constants.js';
import {
  DRIVER_HASH_FIELDS,
  driverKey,
  geoAvailableKey,
  offerReserveKey,
  onlineKey,
  presenceKey,
  sessionKey,
} from '../src/redis/redis.keys.js';

loadEnvFile();

const prisma = new PrismaClient();
const stamp = Date.now();
const tail = String(stamp).slice(-6);
const driverPhone = `+1403${String(stamp).slice(-7)}`;
const otherPhone = `+1587${String(stamp).slice(-7)}`;
const lethbridge = { lat: 49.6935, lng: -112.8418 };

describe('booking fleet sync (e2e)', () => {
  let app: INestApplication;
  let redis: Redis;
  let jwt: JwtService;
  let fleet: FleetStateService;
  let bookings: BookingStateService;
  let reconciler: FleetReconciler;
  let baseUrl = '';
  const clients: ClientSocket[] = [];
  const userIds: string[] = [];
  const branchIds: string[] = [];
  let homeBranchId: string;
  let driverId: string;
  let driverUserId: string;
  let otherDriverId: string;
  let vehicleId: string;
  let typeId: string;
  let makeId: string;
  let modelId: string;
  let driverToken = '';
  let otherToken = '';
  let dispatcherToken = '';

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
    fleet = app.get(FleetStateService);
    bookings = app.get(BookingStateService);
    reconciler = app.get(FleetReconciler);
    const address = app.getHttpServer().address();
    const port = typeof address === 'object' && address ? address.port : 0;
    baseUrl = `http://127.0.0.1:${port}`;

    const home = await prisma.branch.create({
      data: { name: `E2E Sync ${stamp}`, city: 'Lethbridge' },
    });
    homeBranchId = home.id;
    branchIds.push(home.id);
    const vehicleType = await prisma.vehicleType.create({
      data: { name: `E2E Sync Type ${stamp}` },
    });
    typeId = vehicleType.id;
    const make = await prisma.vehicleMake.create({ data: { name: `E2E Sync Make ${stamp}` } });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: { makeId, vehicleTypeId: typeId, name: `E2E Sync Model ${stamp}` },
    });
    modelId = model.id;
    const vehicle = await prisma.vehicle.create({
      data: {
        branchId: homeBranchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: `SY${tail}`,
        unitNumber: '111',
        year: 2020,
      },
    });
    vehicleId = vehicle.id;

    const driver = await createDriver('Priya', 'Nair', driverPhone, 'driver');
    driverId = driver.driverId;
    driverUserId = driver.userId;
    driverToken = sign(driverUserId, 'driver', homeBranchId);
    const other = await createDriver('Owen', 'Cole', otherPhone, 'other');
    otherDriverId = other.driverId;
    otherToken = sign(other.userId, 'driver', homeBranchId);
    const dispatcher = await createUser('dispatcher', homeBranchId);
    dispatcherToken = sign(dispatcher, 'dispatcher', homeBranchId);
    await approveRequiredDocuments();
    await grantLocationConsent(prisma, driverId);
    await fleet.startShift(
      { userId: driverUserId, role: 'driver', branchId: homeBranchId },
      vehicleId,
    );
    await fleet.updateLocation(driverId, { ...lethbridge, accuracyM: 8 });
  });

  afterAll(async () => {
    for (const client of clients) client.disconnect();
    const bookingsInBranch = await prisma.booking.findMany({
      where: { branchId: homeBranchId },
      select: { id: true },
    });
    const ids = bookingsInBranch.map((booking) => booking.id);
    if (ids.length) {
      await prisma.$transaction(async (tx) => {
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" DISABLE TRIGGER booking_history_immutable',
        );
        await tx.bookingStatusHistory.deleteMany({ where: { bookingId: { in: ids } } });
        await tx.bookingOffer.deleteMany({ where: { bookingId: { in: ids } } });
        await tx.bookingAssignment.deleteMany({ where: { bookingId: { in: ids } } });
        await tx.booking.deleteMany({ where: { id: { in: ids } } });
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" ENABLE TRIGGER booking_history_immutable',
        );
      });
    }
    for (const id of [driverId, otherDriverId]) {
      if (!id || !redis) continue;
      await redis.del(driverKey(id), presenceKey(id), sessionKey(id), offerReserveKey(id));
      await redis.srem(onlineKey(homeBranchId), id);
      await redis.zrem(geoAvailableKey(homeBranchId), id);
      await prisma.driverShift.deleteMany({ where: { driverId: id } });
      await prisma.document.deleteMany({ where: { driverId: id } });
      await prisma.driver.deleteMany({ where: { id } });
    }
    if (vehicleId) {
      await prisma.document.deleteMany({ where: { vehicleId } });
      await prisma.vehicle.deleteMany({ where: { id: vehicleId } });
    }
    if (modelId) await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    if (makeId) await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    if (typeId) await prisma.vehicleType.delete({ where: { id: typeId } }).catch(() => undefined);
    await prisma.fareRule.deleteMany({ where: { branchId: homeBranchId } });
    await prisma.idempotencyKey.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('pushes a new booking onto the dispatch queue', async () => {
    await prisma.fareRule.create({
      data: {
        branchId: homeBranchId,
        vehicleTypeId: typeId,
        zone: 'INSIDE_TOWN',
        title: 'Sync inside town',
        baseFareCents: 595,
        perKmCents: 249,
      },
    });
    const dispatch = connect('/dispatch', dispatcherToken);
    await once(dispatch, SOCKET_EVENTS.fleetSnapshot);
    const created = once<{
      id: string;
      status: string;
      pickupAddress: string;
      passengerName: string;
    }>(dispatch, SOCKET_EVENTS.bookingCreated);
    const response = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .set('Idempotency-Key', `sync-create-${stamp}`)
      .send({
        passengerName: 'Leila Hassan',
        passengerPhone: `+1403555${tail.slice(-4)}`,
        vehicleTypeId: typeId,
        zone: 'INSIDE_TOWN',
        stops: [
          { address: 'City Hall', ...lethbridge },
          { address: 'Galt Gardens', lat: 49.6948, lng: -112.8326 },
        ],
      })
      .expect(201);
    expect(await created).toMatchObject({
      id: response.body.id,
      branchId: homeBranchId,
      status: 'SEARCHING_DRIVER',
      passengerName: 'Leila Hassan',
      pickupAddress: 'City Hall',
      vehicleType: { id: typeId, name: expect.any(String) },
    });
  });

  it('walks the trip, frees the driver at dropoff, and leaves payment alone', async () => {
    const driver = connect('/driver', driverToken);
    const initial = await once<{ v: number }>(driver, SOCKET_EVENTS.driverState);
    const dispatch = connect('/dispatch', dispatcherToken);
    await once(dispatch, SOCKET_EVENTS.fleetSnapshot);

    const statuses: string[] = [];
    const versions: number[] = [];
    const bookingEvents: string[] = [];
    const mapStatuses: string[] = [];
    driver.on(SOCKET_EVENTS.driverState, (snapshot: { status: string; v: number }) => {
      statuses.push(snapshot.status);
      versions.push(snapshot.v);
    });
    dispatch.on(SOCKET_EVENTS.bookingStatusChanged, (event: { to: string }) => {
      bookingEvents.push(event.to);
    });
    dispatch.on(
      SOCKET_EVENTS.fleetDriverUpdated,
      (batch: { drivers: { id: string; status: string }[] }) => {
        const row = batch.drivers.find((item) => item.id === driverId);
        if (row) mapStatuses.push(row.status);
      },
    );

    const bookingId = await insertBooking('BC-SY1' + tail);
    const assigned = await bookings.transition(
      bookingId,
      'DRIVER_ASSIGNED',
      { type: 'STAFF', userId: driverUserId },
      { patch: { driverId, vehicleId, assignedAt: new Date() } },
    );
    expect(assigned).toMatchObject({ to: 'DRIVER_ASSIGNED' });
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('ASSIGNED');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBe(bookingId);
    expect(await position()).toBeNull();
    await waitFor(() => versions.length > 0);
    expect(versions[0]).toBeGreaterThan(initial.v);

    const stranger = await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/arriving`)
      .set('Authorization', `Bearer ${otherToken}`)
      .expect(404);
    expect(stranger.body.message).toBe('Not Found');

    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/arriving`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe(
      'EN_ROUTE_PICKUP',
    );

    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/arrived`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/start`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    const versionOnTrip = await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.version);
    const completed = await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/complete`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    expect(completed.body).toMatchObject({
      id: bookingId,
      status: 'PAYMENT_PENDING',
      paymentMethod: 'CASH',
      finalSubtotalCents: 2500,
      finalTaxCents: 125,
      finalFareCents: 2625,
      commissionBps: 0,
      commissionCents: 0,
      driverEarningCents: 2500,
    });

    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBeNull();
    expect(await position()).toEqual([
      expect.closeTo(lethbridge.lng, 3),
      expect.closeTo(lethbridge.lat, 3),
    ]);
    const versionFree = await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.version);
    expect(Number(versionFree)).toBeGreaterThan(Number(versionOnTrip));

    await waitFor(() =>
      includesSequence(statuses, [
        'ASSIGNED',
        'EN_ROUTE_PICKUP',
        'ARRIVED',
        'ON_TRIP',
        'AVAILABLE',
      ]),
    );
    await waitFor(() => bookingEvents.length >= 6);
    expect(bookingEvents.slice(0, 6)).toEqual([
      'DRIVER_ASSIGNED',
      'DRIVER_ARRIVING',
      'DRIVER_ARRIVED',
      'TRIP_STARTED',
      'TRIP_COMPLETED',
      'PAYMENT_PENDING',
    ]);
    const pushed = statuses.at(-1);
    expect(pushed).toBe('AVAILABLE');
    await waitFor(() => mapStatuses.includes('AVAILABLE'), 8000);

    // PAYMENT_PENDING must not move fleet again after TRIP_COMPLETED freed the driver.
    const beforePayment = await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.version);
    const stateCount = statuses.length;
    await delay(100);
    expect(statuses).toHaveLength(stateCount);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.version)).toBe(beforePayment);
    expect(bookingEvents.at(-1)).toBe('PAYMENT_PENDING');
    expect(await position()).not.toBeNull();
  }, 20000);

  it('frees the previous driver on search and on cancel', async () => {
    const searching = await insertBooking('BC-SY2' + tail);
    await assign(searching);
    await prisma.bookingAssignment.create({
      data: { bookingId: searching, driverId, vehicleId, method: 'MANUAL' },
    });
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('ASSIGNED');
    expect(await position()).toBeNull();
    await bookings.transition(searching, 'SEARCHING_DRIVER', { type: 'STAFF', userId: driverUserId });
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBeNull();
    expect(await position()).not.toBeNull();

    const cancelled = await insertBooking('BC-SY3' + tail);
    await assign(cancelled);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBe(cancelled);
    await bookings.transition(cancelled, 'CANCELLED', {
      type: 'STAFF',
      userId: driverUserId,
    });
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBeNull();
    const row = await prisma.booking.findUnique({ where: { id: cancelled } });
    expect(row?.driverId).toBe(driverId);
    expect(await position()).not.toBeNull();
  });

  it('rebuilds a missing hash as stale and corrects a finished booking', async () => {
    await fleet.updateLocation(driverId, { ...lethbridge, accuracyM: 8 });
    const bookingId = await insertBooking('BC-SY4' + tail);
    await assign(bookingId);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('ASSIGNED');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.lat)).toBeTruthy();

    await prisma.booking.update({ where: { id: bookingId }, data: { status: 'CLOSED' } });
    await reconciler.sweep();
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBeNull();
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.staleSince)).toBeNull();
    expect(await position()).not.toBeNull();

    await redis.del(driverKey(driverId), presenceKey(driverId));
    await reconciler.sweep();
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.staleSince)).toBeTruthy();
    expect(await position()).toBeNull();
    expect(await redis.sismember(onlineKey(homeBranchId), driverId)).toBe(1);
  });

  it('keeps a live offer on reconnect and expires it when the reservation key is gone', async () => {
    await fleet.updateLocation(driverId, { ...lethbridge, accuracyM: 8 });
    const bookingId = await insertBooking('BC-SY5' + tail);
    await prisma.bookingStop.create({
      data: {
        bookingId,
        sequence: 2,
        type: 'DROPOFF',
        address: 'Airport',
        lat: 49.63,
        lng: -112.8,
      },
    });
    await redis.set(offerReserveKey(driverId), 'pending');
    await bookings.transition(
      bookingId,
      'MATCHED',
      { type: 'SYSTEM' },
      { patch: { driverId, vehicleId } },
    );
    const expiresAt = new Date(Date.now() + 12_000);
    const offer = await prisma.bookingOffer.create({
      data: {
        bookingId,
        driverId,
        vehicleId,
        attempt: 1,
        distanceToPickupM: 640,
        expiresAt,
      },
    });
    await redis.set(offerReserveKey(driverId), offer.id);

    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('OFFERED');
    expect(await position()).toBeNull();

    await reconciler.sweep();
    expect((await prisma.bookingOffer.findUnique({ where: { id: offer.id } }))?.status).toBe(
      'OFFERED',
    );

    const state = await fleet.state({
      userId: driverUserId,
      role: 'driver',
      branchId: homeBranchId,
    });
    expect(state.status).toBe('OFFERED');
    expect(state.offer).toMatchObject({
      id: offer.id,
      distanceToPickupM: 640,
      tripDistanceM: 1200,
      quotedFareCents: 2500,
      passengerFirstName: 'Leila',
      notes: null,
      pickup: { address: 'City Hall', lat: lethbridge.lat, lng: lethbridge.lng },
      dropoff: { address: 'Airport', lat: 49.63, lng: -112.8 },
    });
    const remaining =
      Date.parse(state.offer?.expiresAt ?? '') - Date.parse(state.offer?.serverNow ?? '');
    expect(remaining).toBeGreaterThan(0);
    expect(remaining).toBeLessThanOrEqual(12_000);

    await redis.del(offerReserveKey(driverId));
    await reconciler.sweep();

    expect((await prisma.bookingOffer.findUnique({ where: { id: offer.id } }))?.status).toBe(
      'EXPIRED',
    );
    const booking = await prisma.booking.findUnique({ where: { id: bookingId } });
    expect(booking?.status).toBe('SEARCHING_DRIVER');
    expect(booking?.driverId).toBeNull();
    expect(booking?.vehicleId).toBeNull();
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBeNull();
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.availableSince)).toBeTruthy();
    expect(await position()).not.toBeNull();
  });

  async function assign(bookingId: string) {
    await bookings.transition(
      bookingId,
      'DRIVER_ASSIGNED',
      { type: 'STAFF', userId: driverUserId },
      { patch: { driverId, vehicleId, assignedAt: new Date() } },
    );
  }

  async function insertBooking(trackingId: string) {
    const booking = await prisma.booking.create({
      data: {
        trackingId,
        branchId: homeBranchId,
        source: 'DISPATCH',
        status: 'SEARCHING_DRIVER',
        passengerName: 'Leila Hassan',
        passengerPhone: driverPhone,
        vehicleTypeId: typeId,
        distanceMeters: 1200,
        durationSeconds: 240,
        quotedFareCents: 2500,
        quotedTaxCents: 125,
        stops: {
          create: [
            {
              sequence: 1,
              type: 'PICKUP',
              address: 'City Hall',
              lat: lethbridge.lat,
              lng: lethbridge.lng,
            },
          ],
        },
      },
    });
    return booking.id;
  }

  async function createDriver(firstName: string, lastName: string, phone: string, label: string) {
    const role = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-sync-${label}-${stamp}@example.com`,
        phone,
        roleId: role.id,
        branchId: homeBranchId,
      },
    });
    userIds.push(user.id);
    const driver = await prisma.driver.create({
      data: {
        userId: user.id,
        branchId: homeBranchId,
        firstName,
        lastName,
        phone,
        status: 'APPROVED',
        approvedAt: new Date(),
      },
    });
    return { userId: user.id, driverId: driver.id };
  }

  async function createUser(roleName: string, branchId: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-sync-${roleName}-${stamp}@example.com`,
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
          storageKey: `e2e/sync/${stamp}/${documentType.code}`,
          status: 'APPROVED',
          expiresAt: new Date('2030-01-01T00:00:00.000Z'),
          reviewedAt: new Date(),
        },
      });
    }
  }

  function sign(userId: string, role: string, branchId: string | null) {
    return jwt.sign({ sub: userId, role, branchId }, { expiresIn: '15m' as const });
  }

  function connect(namespace: string, token: string) {
    const socket = io(`${baseUrl}${namespace}`, {
      transports: ['websocket'],
      reconnection: false,
      auth: { token },
    });
    clients.push(socket);
    return socket;
  }

  async function position() {
    const point = (await redis.geopos(geoAvailableKey(homeBranchId), driverId))[0];
    if (!point) return null;
    return [Number(point[0]), Number(point[1])];
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

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitFor(check: () => boolean, ms = 4000) {
  const start = Date.now();
  while (!check()) {
    if (Date.now() - start > ms) throw new Error('timed out waiting for fleet sync');
    await delay(50);
  }
}

function includesSequence(actual: string[], expected: string[]) {
  let index = 0;
  for (const value of actual) {
    if (value === expected[index]) index += 1;
    if (index === expected.length) return true;
  }
  return false;
}

function loadEnvFile() {
  const contents = readFileSync(resolve(process.cwd(), '.env'), 'utf8');
  for (const rawLine of contents.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const separator = line.indexOf('=');
    if (separator === -1) continue;
    const key = line.slice(0, separator).trim();
    if (process.env[key] !== undefined) continue;
    let value = line.slice(separator + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    process.env[key] = value;
  }
}
