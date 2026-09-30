import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import type { Redis } from 'ioredis';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { AppModule } from '../src/app.module.js';
import { grantLocationConsent } from './location-consent.js';
import { FleetStateService } from '../src/fleet/fleet-state.service.js';
import { REDIS } from '../src/redis/redis.constants.js';
import {
  DRIVER_HASH_FIELDS,
  driverKey,
  geoAvailableKey,
  onlineKey,
  presenceKey,
} from '../src/redis/redis.keys.js';

loadEnvFile();

const prisma = new PrismaClient();
const stamp = Date.now();
const tail = String(stamp).slice(-6);
const homePhone = `+1403${String(stamp).slice(-7)}`;
const otherPhone = `+1587${String(stamp).slice(-7)}`;

describe('fleet rest (e2e)', () => {
  let app: INestApplication<App>;
  let redis: Redis;
  let fleet: FleetStateService;
  let jwt: JwtService;
  const userIds: string[] = [];
  const branchIds: string[] = [];
  const driverIds: string[] = [];
  let homeBranchId: string;
  let otherBranchId: string;
  let homeDriverId: string;
  let otherDriverId: string;
  let typeId: string;
  let makeId: string;
  let modelId: string;
  let homeVehicleId: string;
  let otherVehicleId: string;
  let bookingIds: string[] = [];
  let adminToken = '';
  let superToken = '';
  let hrToken = '';

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
    jwt = app.get(JwtService);

    const home = await prisma.branch.create({
      data: { name: `E2E Fleet ${stamp}`, city: 'Lethbridge', timezone: 'America/Edmonton' },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Fleet Other ${stamp}`, city: 'Calgary', timezone: 'America/Edmonton' },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    branchIds.push(home.id, other.id);

    const vehicleType = await prisma.vehicleType.create({ data: { name: `E2E Fleet Type ${stamp}` } });
    typeId = vehicleType.id;
    const make = await prisma.vehicleMake.create({ data: { name: `E2E Fleet Make ${stamp}` } });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: { makeId, vehicleTypeId: typeId, name: `E2E Fleet Model ${stamp}` },
    });
    modelId = model.id;
    homeVehicleId = await createVehicle(homeBranchId, `FH${tail}`, '11');
    otherVehicleId = await createVehicle(otherBranchId, `FO${tail}`, '22');

    const homeDriver = await createDriver(homeBranchId, homePhone, 'Priya', `e2e-fleet-home-${stamp}@example.com`);
    homeDriverId = homeDriver.driverId;
    const otherDriver = await createDriver(
      otherBranchId,
      otherPhone,
      'Mina',
      `e2e-fleet-other-${stamp}@example.com`,
    );
    otherDriverId = otherDriver.driverId;
    await approveDocuments(homeDriverId, homeVehicleId);
    await approveDocuments(otherDriverId, otherVehicleId);
    await grantLocationConsent(prisma, homeDriverId);
    await grantLocationConsent(prisma, otherDriverId);
    await fleet.startShift(
      { userId: homeDriver.userId, role: 'driver', branchId: homeBranchId },
      homeVehicleId,
    );
    await fleet.startShift(
      { userId: otherDriver.userId, role: 'driver', branchId: otherBranchId },
      otherVehicleId,
    );
    await fleet.updateLocation(homeDriverId, { lat: 49.6935, lng: -112.8418 });

    adminToken = sign('branch_admin', homeBranchId);
    superToken = sign('super_admin', null);
    hrToken = sign('hr_admin', homeBranchId);
  });

  afterAll(async () => {
    if (bookingIds.length) {
      await prisma.$transaction(async (tx) => {
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" DISABLE TRIGGER booking_history_immutable',
        );
        await tx.bookingStatusHistory.deleteMany({ where: { bookingId: { in: bookingIds } } });
        await tx.bookingStop.deleteMany({ where: { bookingId: { in: bookingIds } } });
        await tx.booking.deleteMany({ where: { id: { in: bookingIds } } });
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" ENABLE TRIGGER booking_history_immutable',
        );
      });
    }
    if (driverIds.length) {
      await prisma.driverShift.deleteMany({ where: { driverId: { in: driverIds } } });
      await prisma.driverVehicleAssignment.deleteMany({ where: { driverId: { in: driverIds } } });
      await prisma.document.deleteMany({
        where: { OR: [{ driverId: { in: driverIds } }, { vehicleId: { in: [homeVehicleId, otherVehicleId] } }] },
      });
      await prisma.driver.deleteMany({ where: { id: { in: driverIds } } });
    }
    await prisma.vehicle.deleteMany({ where: { id: { in: [homeVehicleId, otherVehicleId].filter(Boolean) } } });
    if (modelId) await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    if (makeId) await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    if (typeId) await prisma.vehicleType.delete({ where: { id: typeId } }).catch(() => undefined);
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    if (redis) {
      for (const [branchId, driverId] of [
        [homeBranchId, homeDriverId],
        [otherBranchId, otherDriverId],
      ] as const) {
        if (!branchId || !driverId) continue;
        await redis.zrem(geoAvailableKey(branchId), driverId);
        await redis.srem(onlineKey(branchId), driverId);
        await redis.del(driverKey(driverId), presenceKey(driverId));
      }
    }
    await prisma.$disconnect();
    if (app) await app.close();
  });

  it('returns the redis snapshot and ignores another branch for a branch admin', async () => {
    const own = await request(app.getHttpServer())
      .get('/api/v1/fleet/drivers')
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(own.body.branchId).toBe(homeBranchId);
    expect(own.body.drivers.map((driver: { id: string }) => driver.id)).toEqual([homeDriverId]);
    expect(own.body.drivers[0]).toMatchObject({
      status: 'AVAILABLE',
      name: 'Priya Nair',
      lat: expect.closeTo(49.6935, 3),
      lng: expect.closeTo(-112.8418, 3),
    });

    const ignored = await request(app.getHttpServer())
      .get('/api/v1/fleet/drivers')
      .query({ branchId: otherBranchId })
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(ignored.body.branchId).toBe(homeBranchId);
    expect(ignored.body.drivers.map((driver: { id: string }) => driver.id)).toEqual([homeDriverId]);

    const scoped = await request(app.getHttpServer())
      .get('/api/v1/fleet/drivers')
      .query({ branchId: otherBranchId })
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(scoped.body.branchId).toBe(otherBranchId);
    expect(scoped.body.drivers.map((driver: { id: string }) => driver.id)).toEqual([otherDriverId]);

    await request(app.getHttpServer())
      .get('/api/v1/fleet/drivers')
      .set('Authorization', `Bearer ${superToken}`)
      .expect(400);
    await request(app.getHttpServer())
      .get('/api/v1/fleet/drivers')
      .set('Authorization', `Bearer ${hrToken}`)
      .expect(403);
    await request(app.getHttpServer()).get('/api/v1/fleet/drivers').expect(401);
  });

  it('counts chips and reports shift seconds and jobs completed today', async () => {
    const today = await prisma.booking.create({
      data: booking(homeBranchId, homeDriverId, homeVehicleId, `BC-FT${tail}`, new Date()),
    });
    const yesterday = await prisma.booking.create({
      data: booking(
        homeBranchId,
        homeDriverId,
        homeVehicleId,
        `BC-FY${tail}`,
        new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
      ),
    });
    bookingIds = [today.id, yesterday.id];

    const free = await request(app.getHttpServer())
      .get('/api/v1/fleet/summary')
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(free.body.counts).toEqual({ ALL: 1, BUSY: 0, FREE: 1, ASSIGN: 0, WAIT: 0, AWAY: 0 });
    expect(free.body.drivers).toEqual([
      {
        id: homeDriverId,
        shiftSeconds: expect.any(Number),
        jobsToday: 1,
      },
    ]);
    expect(free.body.drivers[0].shiftSeconds).toBeGreaterThanOrEqual(0);
    expect(free.body.drivers[0].shiftSeconds).toBeLessThan(120);

    await expectChip('ON_TRIP', { ALL: 1, BUSY: 1, FREE: 0, ASSIGN: 0, WAIT: 0, AWAY: 0 });
    await expectChip('ARRIVED', { ALL: 1, BUSY: 0, FREE: 0, ASSIGN: 0, WAIT: 1, AWAY: 0 });
    await expectChip('OFFERED', { ALL: 1, BUSY: 0, FREE: 0, ASSIGN: 1, WAIT: 0, AWAY: 0 });
    await expectChip('AWAY', { ALL: 1, BUSY: 0, FREE: 0, ASSIGN: 0, WAIT: 0, AWAY: 1 });

    const other = await request(app.getHttpServer())
      .get('/api/v1/fleet/summary')
      .query({ branchId: otherBranchId })
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(other.body.counts.ALL).toBe(1);
    expect(other.body.drivers[0]).toMatchObject({ id: otherDriverId, jobsToday: 0 });
  });

  async function expectChip(
    status: string,
    counts: { ALL: number; BUSY: number; FREE: number; ASSIGN: number; WAIT: number; AWAY: number },
  ) {
    await redis.hset(driverKey(homeDriverId), DRIVER_HASH_FIELDS.status, status);
    const body = await request(app.getHttpServer())
      .get('/api/v1/fleet/summary')
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(body.body.counts).toEqual(counts);
  }

  function sign(role: string, branchId: string | null) {
    return jwt.sign({ sub: randomUUID(), role, branchId }, { expiresIn: '15m' });
  }

  function booking(
    branchId: string,
    driverId: string,
    vehicleId: string,
    trackingId: string,
    completedAt: Date,
  ) {
    return {
      trackingId,
      branchId,
      source: 'DISPATCH' as const,
      status: 'TRIP_COMPLETED' as const,
      passengerName: 'Leila Hassan',
      passengerPhone: homePhone,
      vehicleTypeId: typeId,
      distanceMeters: 1000,
      durationSeconds: 300,
      quotedFareCents: 2500,
      quotedTaxCents: 125,
      driverId,
      vehicleId,
      completedAt,
      stops: {
        create: [
          {
            sequence: 0,
            type: 'PICKUP' as const,
            address: 'City Hall',
            lat: 49.6935,
            lng: -112.8418,
          },
        ],
      },
    };
  }

  async function createVehicle(branchId: string, plate: string, unit: string) {
    const vehicle = await prisma.vehicle.create({
      data: {
        branchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: plate,
        unitNumber: unit,
        year: 2020,
      },
    });
    return vehicle.id;
  }

  async function createDriver(branchId: string, phone: string, firstName: string, email: string) {
    const role = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    const user = await prisma.user.create({
      data: { email, phone, roleId: role.id, branchId },
    });
    userIds.push(user.id);
    const driver = await prisma.driver.create({
      data: {
        userId: user.id,
        branchId,
        firstName,
        lastName: 'Nair',
        phone,
        status: 'APPROVED',
        approvedAt: new Date(),
      },
    });
    driverIds.push(driver.id);
    return { userId: user.id, driverId: driver.id };
  }

  async function approveDocuments(driverId: string, vehicleId: string) {
    const required = await prisma.documentType.findMany({ where: { required: true } });
    for (const documentType of required) {
      await prisma.document.create({
        data: {
          documentTypeId: documentType.id,
          driverId: documentType.owner === 'DRIVER' ? driverId : null,
          vehicleId: documentType.owner === 'VEHICLE' ? vehicleId : null,
          storageKey: `e2e/fleet/${stamp}/${driverId}/${documentType.code}`,
          status: 'APPROVED',
          expiresAt: new Date('2030-01-01T00:00:00.000Z'),
          reviewedAt: new Date(),
        },
      });
    }
  }
});

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
