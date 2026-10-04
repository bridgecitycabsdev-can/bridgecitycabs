import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import argon2 from 'argon2';
import type { Redis } from 'ioredis';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { AppModule } from '../src/app.module.js';
import { FleetStateService } from '../src/fleet/fleet-state.service.js';
import { REDIS } from '../src/redis/redis.constants.js';
import {
  DRIVER_HASH_FIELDS,
  driverKey,
  geoAvailableKey,
  onlineKey,
  presenceKey,
} from '../src/redis/redis.keys.js';
import { ensureRequiredDocumentTypes } from './ensure-document-types.js';
import { loadEnvFile } from './load-env-file.js';

loadEnvFile();

const prisma = new PrismaClient();
const password = 'correct-password';
const stamp = Date.now();
const tail = String(stamp).slice(-6);
const driverPhone = `+1403${String(stamp).slice(-7)}`;
const passengerPhone = `+1587${String(stamp).slice(-7)}`;

describe('driver shifts (e2e)', () => {
  let app: INestApplication<App>;
  let redis: Redis;
  let fleet: FleetStateService;
  const userIds: string[] = [];
  const branchIds: string[] = [];
  let homeBranchId: string;
  let otherBranchId: string;
  let driverId: string;
  let driverToken: string;
  let adminUserId: string;
  let adminToken: string;
  let otherToken: string;
  let vehicleId: string;
  let otherVehicleId: string;
  let typeId: string;
  let makeId: string;
  let modelId: string;
  let passengerId: string;
  let bookingId: string;

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
    await app.init();
    redis = app.get(REDIS);
    fleet = app.get(FleetStateService);
    await ensureRequiredDocumentTypes(prisma);

    const home = await prisma.branch.create({
      data: { name: `E2E Shift ${stamp}`, city: 'Lethbridge' },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Shift Other ${stamp}`, city: 'Calgary' },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    branchIds.push(home.id, other.id);

    const vehicleType = await prisma.vehicleType.create({
      data: { name: `E2E Shift Type ${stamp}` },
    });
    typeId = vehicleType.id;
    const make = await prisma.vehicleMake.create({
      data: { name: `E2E Shift Make ${stamp}` },
    });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: { makeId, vehicleTypeId: typeId, name: `E2E Shift Model ${stamp}` },
    });
    modelId = model.id;

    const vehicle = await prisma.vehicle.create({
      data: {
        branchId: homeBranchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: `SH${tail}`,
        unitNumber: '111',
        year: 2020,
      },
    });
    vehicleId = vehicle.id;
    const otherVehicle = await prisma.vehicle.create({
      data: {
        branchId: otherBranchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: `SO${tail}`,
        unitNumber: '222',
        year: 2021,
      },
    });
    otherVehicleId = otherVehicle.id;

    const driverRole = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    const driverUser = await prisma.user.create({
      data: {
        email: `e2e-shift-driver-${stamp}@example.com`,
        phone: driverPhone,
        passwordHash: await argon2.hash(password),
        roleId: driverRole.id,
        branchId: homeBranchId,
      },
    });
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

    adminUserId = await createUser('branch_admin', homeBranchId, 'home');
    adminToken = await login(`e2e-shift-home-branch_admin-${stamp}@example.com`);
    await createUser('branch_admin', otherBranchId, 'other');
    otherToken = await login(`e2e-shift-other-branch_admin-${stamp}@example.com`);
    driverToken = await login(`e2e-shift-driver-${stamp}@example.com`);
  });

  afterAll(async () => {
    if (bookingId) {
      await prisma.bookingStop.deleteMany({ where: { bookingId } });
      await prisma.booking.deleteMany({ where: { id: bookingId } });
    }
    if (driverId) {
      await prisma.driverShift.deleteMany({ where: { driverId } });
      await prisma.driverVehicleAssignment.deleteMany({ where: { driverId } });
      await prisma.document.deleteMany({
        where: { OR: [{ driverId }, { vehicleId }] },
      });
      await prisma.driver.deleteMany({ where: { id: driverId } });
    }
    if (passengerId) {
      const passenger = await prisma.passenger.findUnique({ where: { id: passengerId } });
      await prisma.passenger.deleteMany({ where: { id: passengerId } });
      if (passenger) {
        await prisma.user.deleteMany({ where: { id: passenger.userId } });
      }
    }
    const vehicleIds = [vehicleId, otherVehicleId].filter((id): id is string => Boolean(id));
    if (vehicleIds.length) {
      await prisma.vehicle.deleteMany({ where: { id: { in: vehicleIds } } });
    }
    if (modelId) await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    if (makeId) await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    if (typeId) await prisma.vehicleType.delete({ where: { id: typeId } }).catch(() => undefined);
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    if (redis && driverId) {
      await redis.del(driverKey(driverId), presenceKey(driverId));
      if (homeBranchId) {
        await redis.srem(onlineKey(homeBranchId), driverId);
        await redis.zrem(geoAvailableKey(homeBranchId), driverId);
      }
    }
    await prisma.$disconnect();
    await app.close();
  });

  it('keeps shift commands on the driver and force-offline on staff', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({})
      .expect(403);
    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/force-offline`)
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ reason: 'Not staff' })
      .expect(403);
    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/force-offline`)
      .set('Authorization', `Bearer ${otherToken}`)
      .send({ reason: 'Wrong branch' })
      .expect(404);
  });

  it('returns the missing driver and vehicle document codes', async () => {
    const missing = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ vehicleId })
      .expect(422);
    expect(missing.body.message).toBe('Missing documents');
    expect(missing.body.missing).toEqual(
      expect.arrayContaining(['AB_DRIVERS_LICENCE', 'VEHICLE_INSURANCE', 'TAXI_INSPECTION']),
    );
  });

  it('rejects an expired required document and a vehicle from another branch', async () => {
    await approveRequiredDocuments(new Date('2020-01-01T00:00:00.000Z'));
    const expired = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ vehicleId })
      .expect(422);
    expect(expired.body.missing).toContain('AB_DRIVERS_LICENCE');
    expect(expired.body.missing).not.toContain('VEHICLE_INSURANCE');

    await prisma.document.updateMany({
      where: {
        driverId,
        documentType: { code: 'AB_DRIVERS_LICENCE' },
      },
      data: { expiresAt: new Date('2030-01-01T00:00:00.000Z') },
    });

    const noVehicle = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({})
      .expect(422);
    expect(noVehicle.body.message).toBe('Driver has no vehicle');

    const wrongBranch = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ vehicleId: otherVehicleId })
      .expect(400);
    expect(wrongBranch.body.message).toBe('Vehicle is not available in this branch');
  });

  it('starts a shift once, caches the name and unit, and stores longitude first', async () => {
    const blocked = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ vehicleId })
      .expect(422);
    expect(blocked.body.message).toBe('Location tracking consent required');
    expect(blocked.body.fields?.type).toBe('LOCATION_TRACKING');

    const notice = await request(app.getHttpServer())
      .get('/api/v1/driver/location-notice')
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .post('/api/v1/driver/location-consent')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ version: notice.body.version })
      .expect(200);

    const started = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ vehicleId })
      .expect(200);
    expect(started.body).toMatchObject({
      v: 1,
      status: 'AVAILABLE',
      offer: null,
      booking: null,
      shift: {
        vehicle: { id: vehicleId, unitNumber: '111', plate: `SH${tail}` },
      },
    });

    const again = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ vehicleId })
      .expect(200);
    expect(again.body.v).toBe(1);
    expect(again.body.shift.startedAt).toBe(started.body.shift.startedAt);
    expect(await prisma.driverShift.count({ where: { driverId, endedAt: null } })).toBe(1);

    const key = driverKey(driverId);
    expect(await redis.hget(key, DRIVER_HASH_FIELDS.name)).toBe('Priya Nair');
    expect(await redis.hget(key, DRIVER_HASH_FIELDS.unit)).toBe('111');
    expect(await redis.hget(key, DRIVER_HASH_FIELDS.vehicleId)).toBe(vehicleId);
    expect(await redis.hget(key, DRIVER_HASH_FIELDS.ladyDriverEligible)).toBe('0');
    expect(Number(await redis.hget(key, DRIVER_HASH_FIELDS.availableSince))).toBeGreaterThan(0);
    expect(await redis.hget(key, DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.sismember(onlineKey(homeBranchId), driverId)).toBe(1);
    expect(await redis.ttl(presenceKey(driverId))).toBeGreaterThan(0);
    expect((await redis.geopos(geoAvailableKey(homeBranchId), driverId))[0]).toBeNull();

    await fleet.updateLocation(driverId, { lat: 49.6935, lng: -112.8418 });
    const position = (await redis.geopos(geoAvailableKey(homeBranchId), driverId))[0];
    expect(position).not.toBeNull();
    expect(Number(position?.[0])).toBeCloseTo(-112.8418, 3);
    expect(Number(position?.[1])).toBeCloseTo(49.6935, 3);

    const away = await request(app.getHttpServer())
      .post('/api/v1/driver/away')
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    expect(away.body).toMatchObject({ v: 2, status: 'AWAY' });
    expect((await redis.geopos(geoAvailableKey(homeBranchId), driverId))[0]).toBeNull();

    const back = await request(app.getHttpServer())
      .post('/api/v1/driver/back')
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    expect(back.body).toMatchObject({ v: 3, status: 'AVAILABLE' });
    const restored = (await redis.geopos(geoAvailableKey(homeBranchId), driverId))[0];
    expect(Number(restored?.[0])).toBeCloseTo(-112.8418, 3);
    expect(Number(restored?.[1])).toBeCloseTo(49.6935, 3);
  });

  it('shows the passenger first name only and blocks ending a live booking', async () => {
    const passengerRole = await prisma.role.upsert({
      where: { name: 'passenger' },
      update: {},
      create: { name: 'passenger' },
    });
    const passengerUser = await prisma.user.create({
      data: {
        phone: passengerPhone,
        roleId: passengerRole.id,
      },
    });
    userIds.push(passengerUser.id);
    const passenger = await prisma.passenger.create({
      data: {
        userId: passengerUser.id,
        firstName: 'Leila',
        phone: passengerPhone,
      },
    });
    passengerId = passenger.id;
    const booking = await prisma.booking.create({
      data: {
        trackingId: `BC-SH${tail}`,
        branchId: homeBranchId,
        source: 'DISPATCH',
        status: 'TRIP_STARTED',
        passengerId,
        passengerName: 'Walk Up Rider',
        passengerPhone,
        vehicleTypeId: typeId,
        distanceMeters: 1000,
        durationSeconds: 300,
        quotedFareCents: 2500,
        quotedTaxCents: 125,
        notes: 'Gate code 12',
        driverId,
        vehicleId,
        scheduledAt: new Date('2026-09-30T18:00:00.000Z'),
        stops: {
          create: [
            {
              sequence: 0,
              type: 'PICKUP',
              address: 'City Hall',
              lat: 49.6935,
              lng: -112.8418,
            },
          ],
        },
      },
    });
    bookingId = booking.id;

    const state = await request(app.getHttpServer())
      .get('/api/v1/driver/me/state')
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    expect(state.body.booking).toMatchObject({
      id: bookingId,
      trackingId: `BC-SH${tail}`,
      status: 'TRIP_STARTED',
      passengerFirstName: 'Leila',
      notes: 'Gate code 12',
      quotedFareCents: 2500,
      scheduledAt: '2026-09-30T18:00:00.000Z',
    });
    expect(state.body.booking.stops).toHaveLength(1);
    expect(JSON.stringify(state.body)).not.toContain(passengerPhone);

    const blocked = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/end')
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(409);
    expect(blocked.body.message).toBe('Driver has a live booking');
  });

  it('lets staff force the driver offline and records the reason', async () => {
    const forced = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/force-offline`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ reason: 'Radio failed, sending him home' })
      .expect(200);
    expect(forced.body).toMatchObject({ v: 4, status: 'OFFLINE', shift: null });

    const shift = await prisma.driverShift.findFirst({
      where: { driverId, endReason: 'ADMIN_FORCED' },
    });
    expect(shift?.endedById).toBe(adminUserId);
    expect(shift?.endNote).toBe('Radio failed, sending him home');
    expect(shift?.endedAt).toBeTruthy();
    expect(await redis.exists(driverKey(driverId))).toBe(0);
    expect(await redis.sismember(onlineKey(homeBranchId), driverId)).toBe(0);
    expect(await redis.exists(presenceKey(driverId))).toBe(0);
  });

  it('comes back on trip without entering the available geo index, then ends', async () => {
    await prisma.driverVehicleAssignment.create({
      data: { driverId, vehicleId },
    });
    const restarted = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({})
      .expect(200);
    expect(restarted.body).toMatchObject({
      v: 5,
      status: 'ON_TRIP',
      booking: { id: bookingId, passengerFirstName: 'Leila' },
    });
    expect((await redis.geopos(geoAvailableKey(homeBranchId), driverId))[0]).toBeNull();

    await prisma.booking.update({
      where: { id: bookingId },
      data: { status: 'CLOSED' },
    });
    const ended = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/end')
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    expect(ended.body).toMatchObject({ v: 6, status: 'OFFLINE', shift: null, booking: null });
    const closed = await prisma.driverShift.findFirst({
      where: { driverId, endReason: 'MANUAL' },
    });
    expect(closed?.endedById).toBeTruthy();
  });

  it('blocks an unapproved driver from going online', async () => {
    await prisma.driver.update({ where: { id: driverId }, data: { status: 'PENDING_APPROVAL' } });
    const blocked = await request(app.getHttpServer())
      .post('/api/v1/driver/shift/start')
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ vehicleId })
      .expect(422);
    expect(blocked.body.message).toBe('Driver is not approved');
    await prisma.driver.update({ where: { id: driverId }, data: { status: 'APPROVED' } });
  });

  async function approveRequiredDocuments(licenceExpiresAt: Date) {
    const required = await prisma.documentType.findMany({ where: { required: true } });
    for (const documentType of required) {
      await prisma.document.create({
        data: {
          documentTypeId: documentType.id,
          driverId: documentType.owner === 'DRIVER' ? driverId : null,
          vehicleId: documentType.owner === 'VEHICLE' ? vehicleId : null,
          storageKey: `e2e/shift/${stamp}/${documentType.code}`,
          status: 'APPROVED',
          expiresAt:
            documentType.code === 'AB_DRIVERS_LICENCE' ? licenceExpiresAt : new Date('2030-01-01'),
          reviewedAt: new Date(),
        },
      });
    }
  }

  async function createUser(roleName: string, branchId: string, label: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-shift-${label}-${roleName}-${stamp}@example.com`,
        passwordHash: await argon2.hash(password),
        roleId: role.id,
        branchId,
      },
    });
    userIds.push(user.id);
    return user.id;
  }

  async function login(email: string) {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password })
      .expect(200);
    return response.body.accessToken as string;
  }
});

