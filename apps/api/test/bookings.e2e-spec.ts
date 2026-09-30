import { randomInt } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import argon2 from 'argon2';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { AppModule } from '../src/app.module.js';
import { calcFare } from '../src/fares/calc-fare.js';
import { HaversineDistanceService } from '../src/fares/distance.service.js';
import { TRACKING_ALPHABET } from '../src/bookings/tracking-id.js';

loadEnvFile();

const prisma = new PrismaClient();
const password = 'correct-password';
const stamp = Date.now();
const origin = { lat: 0, lng: 0, address: '100 1 Ave S' };
const dropoff = {
  lat: (1000 / 6_371_000) * (180 / Math.PI),
  lng: 0,
  address: '200 5 Ave S',
};
const via = { lat: origin.lat / 2 + dropoff.lat / 2, lng: 0, address: '150 3 Ave S' };

describe('bookings (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  const branchIds: string[] = [];
  let homeBranchId: string;
  let otherBranchId: string;
  let typeId: string;
  let inactiveTypeId: string;
  let makeId: string;
  let modelId: string;
  let vehicleId: string;
  let driverId: string;
  let eligibleDriverId: string;
  let minivanDriverId: string;
  let minivanTypeId: string;
  const vehicleIds: string[] = [];
  const driverIds: string[] = [];
  let passengerId: string;
  let passengerPhone: string;
  let blockedPhone: string;
  let superToken: string;
  let adminToken: string;
  let otherToken: string;
  let dispatchToken: string;
  let hrToken: string;

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

    const home = await prisma.branch.create({
      data: { name: `E2E Book ${stamp}`, city: 'Lethbridge', gstRateBps: 500 },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Book Other ${stamp}`, city: 'Calgary', gstRateBps: 500 },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    branchIds.push(home.id, other.id);

    const type = await prisma.vehicleType.create({
      data: { name: `E2E Book SUV ${stamp}` },
    });
    const inactive = await prisma.vehicleType.create({
      data: { name: `E2E Book Old ${stamp}`, active: false },
    });
    typeId = type.id;
    inactiveTypeId = inactive.id;
    const make = await prisma.vehicleMake.create({
      data: { name: `E2E Book Make ${stamp}` },
    });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: { makeId, vehicleTypeId: typeId, name: `E2E Book Model ${stamp}` },
    });
    modelId = model.id;
    const vehicle = await prisma.vehicle.create({
      data: {
        branchId: homeBranchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: `BK${String(stamp).slice(-6)}`,
        year: 2022,
      },
    });
    vehicleId = vehicle.id;
    vehicleIds.push(vehicle.id);

    await prisma.fareRule.create({
      data: {
        branchId: homeBranchId,
        vehicleTypeId: typeId,
        zone: 'INSIDE_TOWN',
        title: 'SUV inside town',
        baseFareCents: 595,
        perKmCents: 249,
      },
    });
    await prisma.fareRule.create({
      data: {
        branchId: otherBranchId,
        vehicleTypeId: typeId,
        zone: 'INSIDE_TOWN',
        title: 'SUV inside town',
        baseFareCents: 595,
        perKmCents: 249,
      },
    });

    const driverPhone = nextPhone();
    const driverUser = await prisma.user.create({
      data: {
        phone: driverPhone,
        roleId: (await role('driver')).id,
        branchId: homeBranchId,
        driver: {
          create: {
            branchId: homeBranchId,
            firstName: 'Priya',
            lastName: 'Shah',
            phone: driverPhone,
            status: 'APPROVED',
          },
        },
      },
      include: { driver: true },
    });
    userIds.push(driverUser.id);
    driverId = driverUser.driver!.id;
    driverIds.push(driverId);
    await prisma.driverVehicleAssignment.create({
      data: { driverId, vehicleId },
    });

    const eligible = await createApprovedDriver('Eligible', 'Driver', true);
    eligibleDriverId = eligible.driverId;
    const minivanType = await prisma.vehicleType.upsert({
      where: { name: 'Minivan' },
      update: {},
      create: { name: 'Minivan' },
    });
    minivanTypeId = minivanType.id;
    const minivan = await createApprovedDriver('Mina', 'Van', false, minivanType.id);
    minivanDriverId = minivan.driverId;

    passengerPhone = nextPhone();
    const passengerUser = await prisma.user.create({
      data: {
        phone: passengerPhone,
        roleId: (await role('passenger')).id,
        passenger: {
          create: {
            firstName: 'Amira',
            lastName: 'Haddad',
            phone: passengerPhone,
          },
        },
      },
      include: { passenger: true },
    });
    userIds.push(passengerUser.id);
    passengerId = passengerUser.passenger!.id;

    blockedPhone = nextPhone();
    const blockedUser = await prisma.user.create({
      data: {
        phone: blockedPhone,
        roleId: (await role('passenger')).id,
        passenger: {
          create: {
            firstName: 'Blocked',
            lastName: 'Rider',
            phone: blockedPhone,
            blocked: true,
            blockReason: 'test',
          },
        },
      },
    });
    userIds.push(blockedUser.id);

    superToken = await login(await createUser('super_admin', 'super'));
    adminToken = await login(await createUser('branch_admin', 'home', homeBranchId));
    otherToken = await login(await createUser('branch_admin', 'other', otherBranchId));
    dispatchToken = await login(await createUser('dispatcher', 'dispatch', homeBranchId));
    hrToken = await login(await createUser('hr_admin', 'hr', homeBranchId));
  });

  afterAll(async () => {
    const bookings = await prisma.booking.findMany({
      where: { branchId: { in: branchIds } },
      select: { id: true },
    });
    const ids = bookings.map((booking) => booking.id);
    if (ids.length) {
      await prisma.$transaction(async (tx) => {
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" DISABLE TRIGGER booking_history_immutable',
        );
        await tx.bookingStatusHistory.deleteMany({ where: { bookingId: { in: ids } } });
        await tx.bookingAssignment.deleteMany({ where: { bookingId: { in: ids } } });
        await tx.booking.deleteMany({ where: { id: { in: ids } } });
        await tx.$executeRawUnsafe(
          'ALTER TABLE "BookingStatusHistory" ENABLE TRIGGER booking_history_immutable',
        );
      });
    }
    await prisma.idempotencyKey.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.driverVehicleAssignment.deleteMany({
      where: { vehicleId: { in: vehicleIds } },
    });
    await prisma.driver.deleteMany({ where: { id: { in: driverIds } } });
    await prisma.vehicle.deleteMany({ where: { id: { in: vehicleIds } } });
    await prisma.passenger.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.fareRule.deleteMany({ where: { branchId: { in: branchIds } } });
    if (modelId) await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    if (makeId) await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    await prisma.vehicleType.deleteMany({
      where: { id: { in: [typeId, inactiveTypeId].filter(Boolean) } },
    });
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('rejects staff who cannot create, a missing key, and a blocked passenger', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${hrToken}`)
      .set('Idempotency-Key', `hr-${stamp}`)
      .send(body())
      .expect(403);

    await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send(body())
      .expect(400);

    const blocked = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `blocked-${stamp}`)
      .send(body({ passengerPhone: blockedPhone, passengerName: 'Blocked Rider' }))
      .expect(422);
    expect(blocked.body.message).toBe('Passenger is blocked');
  });

  it('creates an immediate booking, snapshots the passenger, and replays the response', async () => {
    const trip = await new HaversineDistanceService().estimate(origin, dropoff, [via]);
    const fare = calcFare(
      { baseFareCents: 595, perKmCents: 249, perMinuteCents: 0, minFareCents: 0 },
      trip.meters,
      trip.seconds,
      500,
    );
    const key = `create-${stamp}`;
    const created = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', key)
      .send(
        body({
          passengerPhone,
          passengerName: 'Phone-in Amira',
          fixedFareCents: 2000,
          stops: [origin, via, dropoff],
        }),
      )
      .expect(201);

    expect(created.body.trackingId).toMatch(new RegExp(`^BC-[${TRACKING_ALPHABET}]{8}$`));
    expect(created.body.status).toBe('SEARCHING_DRIVER');
    expect(created.body.branchId).toBe(homeBranchId);
    expect(created.body.passengerId).toBe(passengerId);
    expect(created.body.passengerName).toBe('Phone-in Amira');
    expect(created.body.passengerPhone).toBe(passengerPhone);
    expect(created.body.quotedFareCents).toBe(fare.subtotalCents);
    expect(created.body.quotedTaxCents).toBe(fare.taxCents);
    expect(created.body.fixedFareCents).toBe(2000);
    expect(created.body.stops.map((stop: { type: string }) => stop.type)).toEqual([
      'PICKUP',
      'STOP',
      'DROPOFF',
    ]);
    expect(created.body.history.map((row: { toStatus: string }) => row.toStatus)).toEqual([
      'CREATED',
      'SEARCHING_DRIVER',
    ]);
    expect(created.body.history[0].fromStatus).toBeNull();

    await prisma.passenger.update({
      where: { id: passengerId },
      data: { firstName: 'Renamed' },
    });
    const detail = await request(app.getHttpServer())
      .get(`/api/v1/bookings/${created.body.id}`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .expect(200);
    expect(detail.body.passengerName).toBe('Phone-in Amira');

    const before = await prisma.booking.count({ where: { branchId: homeBranchId } });
    const replay = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', key)
      .send(
        body({
          passengerPhone,
          passengerName: 'Phone-in Amira',
          fixedFareCents: 2000,
          stops: [origin, via, dropoff],
        }),
      )
      .expect(201);
    expect(replay.body.id).toBe(created.body.id);
    expect(await prisma.booking.count({ where: { branchId: homeBranchId } })).toBe(before);

    const reused = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', key)
      .send(body({ passengerName: 'Someone else' }))
      .expect(422);

    expect(reused.body.message).toBe(
      'Idempotency key was reused with a different payload',
    );

    await request(app.getHttpServer())
      .get(`/api/v1/bookings/${created.body.id}`)
      .set('Authorization', `Bearer ${otherToken}`)
      .expect(404);
    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${created.body.id}/assign`)
      .set('Authorization', `Bearer ${otherToken}`)
      .send({ driverId })
      .expect(404);
    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${created.body.id}/cancel`)
      .set('Authorization', `Bearer ${otherToken}`)
      .send({ reason: 'OPERATIONAL' })
      .expect(404);

    const found = await request(app.getHttpServer())
      .get('/api/v1/bookings/lookup')
      .query({ trackingId: created.body.trackingId.toLowerCase() })
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(found.body.id).toBe(created.body.id);
  });

  it('forces the token branch, keeps scheduled bookings scheduled, and rejects bad stops', async () => {
    const forced = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${adminToken}`)
      .set('Idempotency-Key', `force-${stamp}`)
      .send(body({ branchId: otherBranchId }))
      .expect(201);
    expect(forced.body.branchId).toBe(homeBranchId);

    const when = new Date(Date.now() + 20 * 60_000).toISOString();
    const scheduled = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `later-${stamp}`)
      .send(body({ scheduledAt: when }))
      .expect(201);
    expect(scheduled.body.status).toBe('SCHEDULED');
    expect(scheduled.body.history).toHaveLength(1);
    expect(scheduled.body.history[0].toStatus).toBe('SCHEDULED');

    const soon = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `soon-${stamp}`)
      .send(body({ scheduledAt: new Date(Date.now() + 5 * 60_000).toISOString() }))
      .expect(400);
    expect(soon.body.message).toMatch(/15 minutes/);

    const far = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `far-${stamp}`)
      .send(
        body({
          scheduledAt: new Date(Date.now() + 31 * 24 * 60 * 60_000).toISOString(),
        }),
      )
      .expect(400);
    expect(far.body.message).toMatch(/30 days/);

    await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `same-${stamp}`)
      .send(body({ stops: [origin, { ...origin, address: 'Same place' }] }))
      .expect(400);

    await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `zone-${stamp}`)
      .send(body({ zone: 'OUT_OF_TOWN' }))
      .expect(404);

    await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `inactive-${stamp}`)
      .send(body({ vehicleTypeId: inactiveTypeId }))
      .expect(422);

    const listed = await request(app.getHttpServer())
      .get('/api/v1/bookings')
      .query({ tab: 'unassigned', status: 'SCHEDULED' })
      .set('Authorization', `Bearer ${hrToken}`)
      .expect(200);
    expect(listed.body.data.some((row: { id: string }) => row.id === scheduled.body.id)).toBe(
      true,
    );
    const hidden = await request(app.getHttpServer())
      .get('/api/v1/bookings')
      .query({ tab: 'unassigned' })
      .set('Authorization', `Bearer ${otherToken}`)
      .expect(200);
    expect(hidden.body.data).toHaveLength(0);
  });

  it('assigns and unassigns a driver, and lets only admins force a legal status', async () => {
    const first = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `assign-a-${stamp}`)
      .send(body())
      .expect(201);
    const second = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `assign-b-${stamp}`)
      .send(body())
      .expect(201);

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${first.body.id}/assign`)
      .set('Authorization', `Bearer ${hrToken}`)
      .send({ driverId })
      .expect(403);

    const assigned = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${first.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId })
      .expect(200);
    expect(assigned.body.status).toBe('DRIVER_ASSIGNED');
    expect(assigned.body.driverId).toBe(driverId);
    expect(assigned.body.vehicleId).toBe(vehicleId);
    expect(assigned.body.assignments[0].endedAt).toBeNull();
    expect(assigned.body.assignments[0].method).toBe('MANUAL');

    const busy = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${second.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId })
      .expect(409);
    expect(busy.body.message).toBe('Driver is busy');

    const released = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${first.body.id}/unassign`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ reason: 'Wrong car' })
      .expect(200);
    expect(released.body.status).toBe('SEARCHING_DRIVER');
    expect(released.body.driverId).toBeNull();
    expect(released.body.vehicleId).toBeNull();
    expect(released.body.assignments[0].endReason).toBe('REASSIGNED');
    expect(released.body.assignments[0].endedAt).toBeTruthy();

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${second.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId })
      .expect(200);

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${first.body.id}/status`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ to: 'CANCELLED', reason: 'Not allowed' })
      .expect(403);

    const illegal = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${first.body.id}/status`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ to: 'TRIP_STARTED' })
      .expect(409);
    expect(illegal.body.message).toMatch(/Illegal transition/);

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${second.body.id}/cancel`)
      .set('Authorization', `Bearer ${hrToken}`)
      .send({ reason: 'CHANGED_MIND' })
      .expect(400);

    const cancelled = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${second.body.id}/cancel`)
      .set('Authorization', `Bearer ${hrToken}`)
      .send({ reason: 'PASSENGER_REQUEST', note: 'Passenger changed plans' })
      .expect(200);
    expect(cancelled.body.status).toBe('CANCELLED');
    expect(cancelled.body.cancelledBy).toBe('STAFF');
    expect(cancelled.body.cancelReason).toBe('PASSENGER_REQUEST');
    expect(cancelled.body.cancelNote).toBe('Passenger changed plans');
    expect(cancelled.body.cancellationFeeCents).toBe(0);
    expect(cancelled.body.assignments[0].endReason).toBe('BOOKING_CANCELLED');
    expect(cancelled.body.assignments[0].endedAt).toBeTruthy();

    const closed = await request(app.getHttpServer())
      .get('/api/v1/bookings')
      .query({ tab: 'closed', status: 'CANCELLED' })
      .set('Authorization', `Bearer ${dispatchToken}`)
      .expect(200);
    expect(closed.body.data.some((row: { id: string }) => row.id === second.body.id)).toBe(
      true,
    );
  });

  it('rejects a poor vehicle fit and reassigns in one transaction', async () => {
    const vanBooking = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `van-${stamp}`)
      .send(body({ vanOnly: true }))
      .expect(201);
    const needsVan = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${vanBooking.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId: eligibleDriverId })
      .expect(422);
    expect(needsVan.body.message).toBe('Booking requires a minivan');
    const vanAssigned = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${vanBooking.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId: minivanDriverId })
      .expect(200);
    expect(vanAssigned.body.driverId).toBe(minivanDriverId);
    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${vanBooking.body.id}/unassign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({})
      .expect(200);

    const ladyBooking = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `lady-${stamp}`)
      .send(body({ ladyDriverOnly: true }))
      .expect(201);
    const needsLady = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${ladyBooking.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId: minivanDriverId })
      .expect(422);
    expect(needsLady.body.message).toBe('Booking requires a lady driver');
    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${ladyBooking.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId: eligibleDriverId })
      .expect(200);

    const ride = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `reassign-${stamp}`)
      .send(body())
      .expect(201);
    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${ride.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId: eligibleDriverId })
      .expect(409);

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${ladyBooking.body.id}/unassign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({})
      .expect(200);

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${ride.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId: eligibleDriverId })
      .expect(200);
    const moved = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${ride.body.id}/assign`)
      .set('Authorization', `Bearer ${dispatchToken}`)
      .send({ driverId: minivanDriverId })
      .expect(200);
    expect(moved.body.driverId).toBe(minivanDriverId);
    expect(moved.body.status).toBe('DRIVER_ASSIGNED');
    const ended = moved.body.assignments.find(
      (row: { driverId: string }) => row.driverId === eligibleDriverId,
    );
    const open = moved.body.assignments.find(
      (row: { driverId: string; endedAt: string | null }) =>
        row.driverId === minivanDriverId,
    );
    expect(ended.endReason).toBe('REASSIGNED');
    expect(ended.endedAt).toBeTruthy();
    expect(open.endedAt).toBeNull();
    expect(open.method).toBe('MANUAL');
    expect(open.assignedById).toBeTruthy();
    expect(
      moved.body.history.map((row: { toStatus: string }) => row.toStatus),
    ).toEqual(['CREATED', 'SEARCHING_DRIVER', 'DRIVER_ASSIGNED', 'SEARCHING_DRIVER', 'DRIVER_ASSIGNED']);
  });

  it('keeps history immutable, rejects a started-trip cancel, and lets one race win', async () => {
    const created = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${dispatchToken}`)
      .set('Idempotency-Key', `race-${stamp}`)
      .send(body())
      .expect(201);

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${created.body.id}/assign`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ driverId })
      .expect(200);

    const [left, right] = await Promise.all([
      request(app.getHttpServer())
        .post(`/api/v1/bookings/${created.body.id}/status`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ to: 'CANCELLED', reason: 'DUPLICATE' }),
      request(app.getHttpServer())
        .post(`/api/v1/bookings/${created.body.id}/status`)
        .set('Authorization', `Bearer ${superToken}`)
        .send({ to: 'SEARCHING_DRIVER' }),
    ]);
    expect([left.status, right.status].sort()).toEqual([200, 409]);
    const loser = left.status === 409 ? left : right;
    expect(loser.body.message).toMatch(/Booking changed, retry|Illegal transition/);

    await prisma.booking.update({
      where: { id: created.body.id },
      data: { status: 'TRIP_STARTED' },
    });
    const illegal = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${created.body.id}/status`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ to: 'CANCELLED', reason: 'PASSENGER_REQUEST' })
      .expect(409);
    expect(illegal.body.message).toBe('Illegal transition TRIP_STARTED → CANCELLED');

    const history = await prisma.bookingStatusHistory.findFirstOrThrow({
      where: { bookingId: created.body.id },
    });
    await expect(
      prisma.$executeRaw`UPDATE "BookingStatusHistory" SET "reason" = 'tamper' WHERE "id" = ${history.id}`,
    ).rejects.toThrow(/append-only/);
    await expect(
      prisma.$executeRaw`DELETE FROM "BookingStatusHistory" WHERE "id" = ${history.id}`,
    ).rejects.toThrow(/append-only/);
    const still = await prisma.bookingStatusHistory.findUnique({ where: { id: history.id } });
    expect(still?.reason).toBe(history.reason);
  });

  function body(overrides: Record<string, unknown> = {}) {
    return {
      passengerName: 'Walk-up Rider',
      passengerPhone: nextPhone(),
      vehicleTypeId: typeId,
      zone: 'INSIDE_TOWN',
      stops: [origin, dropoff],
      ...overrides,
    };
  }

  async function createApprovedDriver(
    firstName: string,
    lastName: string,
    ladyDriverEligible: boolean,
    vehicleTypeId = typeId,
  ) {
    const phone = nextPhone();
    const user = await prisma.user.create({
      data: {
        phone,
        roleId: (await role('driver')).id,
        branchId: homeBranchId,
        driver: {
          create: {
            branchId: homeBranchId,
            firstName,
            lastName,
            phone,
            status: 'APPROVED',
            ladyDriverEligible,
          },
        },
      },
      include: { driver: true },
    });
    userIds.push(user.id);
    const id = user.driver!.id;
    driverIds.push(id);
    const fleetVehicle = await prisma.vehicle.create({
      data: {
        branchId: homeBranchId,
        modelId,
        vehicleTypeId,
        plateNumber: `B${String(phone).slice(-6)}`,
        year: 2021,
      },
    });
    vehicleIds.push(fleetVehicle.id);
    await prisma.driverVehicleAssignment.create({
      data: { driverId: id, vehicleId: fleetVehicle.id },
    });
    return { driverId: id, vehicleId: fleetVehicle.id };
  }

  async function role(name: string) {
    return prisma.role.upsert({
      where: { name },
      update: {},
      create: { name },
    });
  }

  async function createUser(roleName: string, label: string, branchId?: string) {
    const found = await role(roleName);
    const user = await prisma.user.create({
      data: {
        email: `e2e-book-${label}-${stamp}@example.com`,
        passwordHash: await argon2.hash(password),
        roleId: found.id,
        branchId,
      },
    });
    userIds.push(user.id);
    return user.email!;
  }

  async function login(email: string) {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password })
      .expect(200);
    return response.body.accessToken as string;
  }
});

function nextPhone() {
  return `+1403${randomInt(2000000, 9999999)}`;
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
