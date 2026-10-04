import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import type { Redis } from 'ioredis';
import { AppModule } from '../src/app.module.js';
import { grantLocationConsent } from './location-consent.js';
import { FleetStateService } from '../src/fleet/fleet-state.service.js';
import { IdempotencyService } from '../src/idempotency/idempotency.service.js';
import { LocationFlushService } from '../src/jobs/location-flush.service.js';
import { LocationRetentionService } from '../src/jobs/location-retention.service.js';
import { PresenceSweepService } from '../src/jobs/presence-sweep.service.js';
import { REDIS } from '../src/redis/redis.constants.js';
import { loadEnvFile } from './load-env-file.js';
import {
  DRIVER_HASH_FIELDS,
  LOC_BUFFER_KEY,
  driverKey,
  geoAvailableKey,
  onlineKey,
  presenceKey,
} from '../src/redis/redis.keys.js';

loadEnvFile();

const prisma = new PrismaClient();
const stamp = Date.now();
const tail = String(stamp).slice(-6);
const driverPhone = `+1403${String(stamp).slice(-7)}`;
const lethbridge = { lat: 49.6935, lng: -112.8418 };
const day = 24 * 60 * 60 * 1000;

describe('background jobs (e2e)', () => {
  let app: INestApplication;
  let redis: Redis;
  let fleet: FleetStateService;
  let sweep: PresenceSweepService;
  let flush: LocationFlushService;
  let retention: LocationRetentionService;
  let idempotency: IdempotencyService;
  const userIds: string[] = [];
  let branchId: string;
  let driverId: string;
  let driverUserId: string;
  let vehicleId: string;
  let typeId: string;
  let makeId: string;
  let modelId: string;
  let bookingId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
    );
    await app.init();
    redis = app.get(REDIS);
    fleet = app.get(FleetStateService);
    sweep = app.get(PresenceSweepService);
    flush = app.get(LocationFlushService);
    retention = app.get(LocationRetentionService);
    idempotency = app.get(IdempotencyService);

    const branch = await prisma.branch.create({
      data: { name: `E2E Jobs ${stamp}`, city: 'Lethbridge' },
    });
    branchId = branch.id;
    const vehicleType = await prisma.vehicleType.create({ data: { name: `E2E Jobs Type ${stamp}` } });
    typeId = vehicleType.id;
    const make = await prisma.vehicleMake.create({ data: { name: `E2E Jobs Make ${stamp}` } });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: { makeId, vehicleTypeId: typeId, name: `E2E Jobs Model ${stamp}` },
    });
    modelId = model.id;
    const vehicle = await prisma.vehicle.create({
      data: {
        branchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: `JB${tail}`,
        unitNumber: '11',
        year: 2020,
      },
    });
    vehicleId = vehicle.id;
    const role = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-jobs-driver-${stamp}@example.com`,
        phone: driverPhone,
        roleId: role.id,
        branchId,
      },
    });
    driverUserId = user.id;
    userIds.push(user.id);
    const driver = await prisma.driver.create({
      data: {
        userId: user.id,
        branchId,
        firstName: 'Priya',
        lastName: 'Nair',
        phone: driverPhone,
        status: 'APPROVED',
        approvedAt: new Date(),
      },
    });
    driverId = driver.id;
    await approveRequiredDocuments();
    await grantLocationConsent(prisma, driver.id);
    await fleet.startShift({ userId: user.id, role: 'driver', branchId }, vehicleId);
  });

  afterAll(async () => {
    if (bookingId) {
      await prisma.$transaction(async (tx) => {
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" DISABLE TRIGGER booking_history_immutable',
        );
        await tx.bookingStatusHistory.deleteMany({ where: { bookingId } });
        await tx.bookingStop.deleteMany({ where: { bookingId } });
        await tx.bookingAssignment.deleteMany({ where: { bookingId } });
        await tx.booking.deleteMany({ where: { id: bookingId } });
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" ENABLE TRIGGER booking_history_immutable',
        );
      });
    }
    if (driverId) {
      await prisma.driverLocationLog.deleteMany({ where: { driverId } });
      await prisma.driverShift.deleteMany({ where: { driverId } });
      await prisma.driverVehicleAssignment.deleteMany({ where: { driverId } });
      await prisma.document.deleteMany({ where: { OR: [{ driverId }, { vehicleId }] } });
      await prisma.driver.deleteMany({ where: { id: driverId } });
    }
    await prisma.idempotencyKey.deleteMany({ where: { userId: { in: userIds } } });
    if (vehicleId) await prisma.vehicle.deleteMany({ where: { id: vehicleId } });
    if (modelId) await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    if (makeId) await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    if (typeId) await prisma.vehicleType.delete({ where: { id: typeId } }).catch(() => undefined);
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    if (branchId) await prisma.branch.deleteMany({ where: { id: branchId } });
    if (redis && driverId && branchId) {
      await redis.zrem(geoAvailableKey(branchId), driverId);
      await redis.srem(onlineKey(branchId), driverId);
      await redis.del(driverKey(driverId), presenceKey(driverId));
    }
    await prisma.$disconnect();
    if (app) await app.close();
  });

  it('flags a silent available driver, then ends the shift as connection lost', async () => {
    await fleet.updateLocation(driverId, lethbridge);
    expect((await redis.geopos(geoAvailableKey(branchId), driverId))[0]).not.toBeNull();

    await redis.del(presenceKey(driverId));
    const now = Date.now();
    await sweep.sweep(now, branchId);

    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.staleSince)).toBe(String(now));
    expect((await redis.geopos(geoAvailableKey(branchId), driverId))[0]).toBeNull();
    const open = await prisma.driverShift.findFirst({ where: { driverId, endedAt: null } });
    expect(open).not.toBeNull();

    await sweep.sweep(now, branchId);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.staleSince)).toBe(String(now));

    await sweep.sweep(now + 121_000, branchId);
    const shift = await prisma.driverShift.findFirst({
      where: { driverId },
      orderBy: { startedAt: 'desc' },
    });
    expect(shift?.endReason).toBe('CONNECTION_LOST');
    expect(shift?.endedById).toBeNull();
    expect(await redis.exists(driverKey(driverId))).toBe(0);
    expect(await redis.sismember(onlineKey(branchId), driverId)).toBe(0);
  });

  it('flags a driver on a live booking and leaves the shift open', async () => {
    await fleet.startShift({ userId: driverUserId, role: 'driver', branchId }, vehicleId);
    await fleet.updateLocation(driverId, lethbridge);
    const booking = await prisma.booking.create({
      data: {
        trackingId: `BC-JB${tail}`,
        branchId,
        source: 'DISPATCH',
        status: 'TRIP_STARTED',
        passengerName: 'Leila Hassan',
        passengerPhone: driverPhone,
        vehicleTypeId: typeId,
        distanceMeters: 1000,
        durationSeconds: 300,
        quotedFareCents: 2500,
        quotedTaxCents: 125,
        driverId,
        vehicleId,
        stops: {
          create: [
            {
              sequence: 0,
              type: 'PICKUP',
              address: 'City Hall',
              lat: lethbridge.lat,
              lng: lethbridge.lng,
            },
          ],
        },
      },
    });
    bookingId = booking.id;

    await redis.del(presenceKey(driverId));
    const now = Date.now();
    await sweep.sweep(now, branchId);
    await sweep.sweep(now + 121_000, branchId);

    const shift = await prisma.driverShift.findFirst({ where: { driverId, endedAt: null } });
    expect(shift).not.toBeNull();
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.staleSince)).toBe(String(now));
    expect(await redis.sismember(onlineKey(branchId), driverId)).toBe(1);
    expect((await redis.geopos(geoAvailableKey(branchId), driverId))[0]).not.toBeNull();
  });

  it('samples trip pings and flushes the buffer in batches', async () => {
    await redis.hset(driverKey(driverId), DRIVER_HASH_FIELDS.status, 'AVAILABLE');
    await redis.hdel(driverKey(driverId), DRIVER_HASH_FIELDS.histAt);
    const start = Date.now();
    await ping(start);
    await ping(start + 1_000);
    expect(await buffered()).toHaveLength(1);

    await redis.hset(driverKey(driverId), DRIVER_HASH_FIELDS.status, 'ON_TRIP');
    await ping(start + 2_000);
    await ping(start + 3_000);
    expect(await buffered()).toHaveLength(3);

    await redis.rpush(LOC_BUFFER_KEY, 'not-json', JSON.stringify({ lat: 1 }));
    const before = await prisma.driverLocationLog.count({ where: { driverId } });
    await flush.flush();
    expect(await buffered()).toHaveLength(0);
    expect(await prisma.driverLocationLog.count({ where: { driverId } })).toBe(before + 3);
  });

  it('purges idempotency keys older than a day and old location rows', async () => {
    const staleKey = `jobs-old-${stamp}`;
    const freshKey = `jobs-fresh-${stamp}`;
    await prisma.idempotencyKey.create({
      data: {
        userId: driverUserId,
        key: staleKey,
        requestHash: 'old',
        createdAt: new Date(Date.now() - 25 * 60 * 60 * 1000),
      },
    });
    await prisma.idempotencyKey.create({
      data: { userId: driverUserId, key: freshKey, requestHash: 'new' },
    });
    await idempotency.purgeExpired();
    expect(
      await prisma.idempotencyKey.findFirst({ where: { userId: driverUserId, key: staleKey } }),
    ).toBeNull();
    expect(
      await prisma.idempotencyKey.findFirst({ where: { userId: driverUserId, key: freshKey } }),
    ).not.toBeNull();

    await prisma.driverLocationLog.create({
      data: {
        driverId,
        lat: lethbridge.lat,
        lng: lethbridge.lng,
        recordedAt: new Date(Date.now() - 91 * day),
      },
    });
    const removed = await retention.purge();
    expect(removed).toBeGreaterThanOrEqual(1);
    const rows = await prisma.driverLocationLog.findMany({ where: { driverId } });
    expect(rows.length).toBeGreaterThan(0);
    expect(rows.every((row) => row.recordedAt.getTime() > Date.now() - 90 * day)).toBe(true);
  });

  async function ping(receivedAtMs: number) {
    await fleet.recordDriverPing(driverId, {
      ...lethbridge,
      accuracyM: 8,
      recordedAt: new Date(receivedAtMs).toISOString(),
      receivedAtMs,
    });
  }

  async function buffered() {
    const rows = await redis.lrange(LOC_BUFFER_KEY, 0, -1);
    return rows.filter((row) => row.includes(driverId));
  }

  async function approveRequiredDocuments() {
    const required = await prisma.documentType.findMany({ where: { required: true } });
    for (const documentType of required) {
      await prisma.document.create({
        data: {
          documentTypeId: documentType.id,
          driverId: documentType.owner === 'DRIVER' ? driverId : null,
          vehicleId: documentType.owner === 'VEHICLE' ? vehicleId : null,
          storageKey: `e2e/jobs/${stamp}/${documentType.code}`,
          status: 'APPROVED',
          expiresAt: new Date('2030-01-01T00:00:00.000Z'),
          reviewedAt: new Date(),
        },
      });
    }
  }
});

