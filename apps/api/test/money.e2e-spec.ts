import { INestApplication, ValidationPipe } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import type { Redis } from 'ioredis';
import request from 'supertest';
import { AppModule } from '../src/app.module.js';
import { grantLocationConsent } from './location-consent.js';
import { BookingStateService } from '../src/bookings/booking-state.service.js';
import { FleetStateService } from '../src/fleet/fleet-state.service.js';
import { LedgerIntegrityService } from '../src/jobs/ledger-integrity.service.js';
import { companyRevenueKey, driverBalanceKey } from '../src/ledger/account-keys.js';
import { LedgerService } from '../src/ledger/ledger.service.js';
import { REDIS } from '../src/redis/redis.constants.js';
import { DRIVER_HASH_FIELDS, driverKey } from '../src/redis/redis.keys.js';
import { assertIsolatedTestEnv } from './test-env.js';
import { loadEnvFile } from './load-env-file.js';

loadEnvFile();
assertIsolatedTestEnv();

const prisma = new PrismaClient();
const stamp = Date.now();
const tail = String(stamp).slice(-6);
const driverPhone = `+1403${String(stamp).slice(-7)}`;
const otherPhone = `+1587${String(stamp).slice(-7)}`;
const lethbridge = { lat: 49.6935, lng: -112.8418 };

describe('money ledger (e2e)', () => {
  let app: INestApplication;
  let redis: Redis;
  let jwt: JwtService;
  let fleet: FleetStateService;
  let bookings: BookingStateService;
  let ledger: LedgerService;
  let integrity: LedgerIntegrityService;
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
  let accountsToken = '';
  let branchAdminToken = '';

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
    jwt = app.get(JwtService);
    fleet = app.get(FleetStateService);
    bookings = app.get(BookingStateService);
    ledger = app.get(LedgerService);
    integrity = app.get(LedgerIntegrityService);

    const home = await prisma.branch.create({
      data: {
        name: `E2E Money ${stamp}`,
        city: 'Lethbridge',
        gstRateBps: 500,
        commissionBps: 1500,
      },
    });
    homeBranchId = home.id;
    branchIds.push(home.id);

    const vehicleType = await prisma.vehicleType.create({
      data: { name: `E2E Money Type ${stamp}` },
    });
    typeId = vehicleType.id;
    const make = await prisma.vehicleMake.create({
      data: { name: `E2E Money Make ${stamp}` },
    });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: {
        makeId,
        vehicleTypeId: typeId,
        name: `E2E Money Model ${stamp}`,
      },
    });
    modelId = model.id;
    const vehicle = await prisma.vehicle.create({
      data: {
        branchId: homeBranchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: `MN${tail}`,
        unitNumber: '222',
        year: 2021,
      },
    });
    vehicleId = vehicle.id;

    const driver = await createDriver('Mina', 'Cash', driverPhone, 'driver');
    driverId = driver.driverId;
    driverUserId = driver.userId;
    driverToken = sign(driverUserId, 'driver', homeBranchId);
    const other = await createDriver('Omar', 'Other', otherPhone, 'other');
    otherDriverId = other.driverId;
    otherToken = sign(other.userId, 'driver', homeBranchId);
    accountsToken = sign(
      await createUser('accounts_admin', homeBranchId),
      'accounts_admin',
      homeBranchId,
    );
    branchAdminToken = sign(
      await createUser('branch_admin', homeBranchId),
      'branch_admin',
      homeBranchId,
    );

    await approveRequiredDocuments();
    await grantLocationConsent(prisma, driverId);
    await fleet.startShift(
      { userId: driverUserId, role: 'driver', branchId: homeBranchId },
      vehicleId,
    );
    await fleet.updateLocation(driverId, { ...lethbridge, accuracyM: 8 });
  }, 60_000);

  afterAll(async () => {
    const bookingsInBranch = await prisma.booking.findMany({
      where: { branchId: homeBranchId },
      select: { id: true },
    });
    const ids = bookingsInBranch.map((row) => row.id);
    await prisma.$executeRawUnsafe(
      'ALTER TABLE "BookingStatusHistory" DISABLE TRIGGER booking_history_immutable',
    );
    await prisma.$executeRawUnsafe(
      'ALTER TABLE "LedgerEntry" DISABLE TRIGGER ledger_entry_immutable',
    );
    await prisma.$executeRawUnsafe(
      'ALTER TABLE "LedgerTransaction" DISABLE TRIGGER ledger_txn_immutable',
    );
    try {
      const txns = await prisma.ledgerTransaction.findMany({
        where: {
          OR: [
            { sourceType: 'BOOKING', sourceId: { in: ids } },
            { sourceType: 'TEST', branchId: homeBranchId },
            { sourceType: 'REVERSAL', branchId: homeBranchId },
          ],
        },
        select: { id: true },
      });
      const txnIds = txns.map((row) => row.id);
      if (txnIds.length) {
        await prisma.ledgerEntry.deleteMany({
          where: { transactionId: { in: txnIds } },
        });
        await prisma.ledgerTransaction.deleteMany({
          where: { id: { in: txnIds } },
        });
      }
      if (ids.length) {
        await prisma.payment.deleteMany({ where: { bookingId: { in: ids } } });
        await prisma.bookingStatusHistory.deleteMany({
          where: { bookingId: { in: ids } },
        });
        await prisma.bookingAssignment.deleteMany({
          where: { bookingId: { in: ids } },
        });
        await prisma.bookingOffer.deleteMany({
          where: { bookingId: { in: ids } },
        });
        await prisma.bookingStop.deleteMany({
          where: { bookingId: { in: ids } },
        });
        await prisma.booking.deleteMany({ where: { id: { in: ids } } });
      }
    } finally {
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "LedgerTransaction" ENABLE TRIGGER ledger_txn_immutable',
      );
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "LedgerEntry" ENABLE TRIGGER ledger_entry_immutable',
      );
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "BookingStatusHistory" ENABLE TRIGGER booking_history_immutable',
      );
    }
    await prisma.driverShift.deleteMany({ where: { driverId: { in: [driverId, otherDriverId] } } });
    await prisma.document.deleteMany({
      where: { OR: [{ driverId: { in: [driverId, otherDriverId] } }, { vehicleId }] },
    });
    await prisma.driver.deleteMany({ where: { id: { in: [driverId, otherDriverId] } } });
    await prisma.vehicle.deleteMany({ where: { id: vehicleId } });
    await prisma.vehicleModel.deleteMany({ where: { id: modelId } });
    await prisma.vehicleMake.deleteMany({ where: { id: makeId } });
    await prisma.vehicleType.deleteMany({ where: { id: typeId } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await app.close();
    await prisma.$disconnect();
  }, 60_000);

  it('rejects unbalanced inserts and blocks UPDATE/DELETE/TRUNCATE on ledger rows', async () => {
    const sourceId = `guard-${stamp}`;
    await expect(
      prisma.$transaction(async (tx) => {
        await ledger.post(tx, {
          kind: 'ADJUSTMENT',
          sourceType: 'TEST',
          sourceId,
          branchId: homeBranchId,
          lines: [
            {
              accountKey: companyRevenueKey(homeBranchId),
              type: 'COMPANY_REVENUE',
              amountCents: 100,
            },
          ],
        });
      }),
    ).rejects.toThrow(/unbalanced/);

    await prisma.$transaction(async (tx) => {
      await ledger.post(tx, {
        kind: 'ADJUSTMENT',
        sourceType: 'TEST',
        sourceId: `${sourceId}-ok`,
        branchId: homeBranchId,
        lines: [
          {
            accountKey: companyRevenueKey(homeBranchId),
            type: 'COMPANY_REVENUE',
            amountCents: 100,
          },
          {
            accountKey: driverBalanceKey(driverId),
            type: 'DRIVER_BALANCE',
            ownerId: driverId,
            amountCents: -100,
          },
        ],
      });
    });

    const txn = await prisma.ledgerTransaction.findFirstOrThrow({
      where: { sourceType: 'TEST', sourceId: `${sourceId}-ok` },
      include: { entries: true },
    });
    const entryId = txn.entries[0]!.id;

    await expect(
      prisma.$executeRaw`UPDATE "LedgerEntry" SET "amountCents" = 1 WHERE "id" = ${entryId}`,
    ).rejects.toThrow(/append-only/);
    await expect(
      prisma.$executeRaw`DELETE FROM "LedgerEntry" WHERE "id" = ${entryId}`,
    ).rejects.toThrow(/append-only/);
    await expect(
      prisma.$executeRaw`UPDATE "LedgerTransaction" SET "description" = 'x' WHERE "id" = ${txn.id}`,
    ).rejects.toThrow(/append-only/);
    await expect(
      prisma.$executeRaw`DELETE FROM "LedgerTransaction" WHERE "id" = ${txn.id}`,
    ).rejects.toThrow(/append-only/);
    await expect(
      prisma.$executeRawUnsafe('TRUNCATE "LedgerEntry"'),
    ).rejects.toThrow(/append-only/);
  });

  it('completes with finals, AVAILABLE presence, and pendingPayment that clears on close', async () => {
    const bookingId = await seedTripStarted(`BC-MN1${tail}`, {
      quotedFareCents: 2510,
      quotedTaxCents: 126,
    });
    const completed = await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/complete`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);

    expect(completed.body).toMatchObject({
      status: 'PAYMENT_PENDING',
      finalSubtotalCents: 2510,
      finalTaxCents: 126,
      finalFareCents: 2636,
      commissionBps: 1500,
      commissionCents: 377,
      driverEarningCents: 2133,
    });
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe(
      'AVAILABLE',
    );

    const pending = await request(app.getHttpServer())
      .get('/api/v1/driver/me/state')
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    expect(pending.body.pendingPayment).toEqual({
      bookingId,
      trackingId: expect.any(String),
      totalCents: 2636,
      subtotalCents: 2510,
      taxCents: 126,
      method: 'CASH',
    });

    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/cash-collected`)
      .set('Authorization', `Bearer ${driverToken}`)
      .send({ amountCents: 1 })
      .expect(200);

    const closed = await request(app.getHttpServer())
      .get('/api/v1/driver/me/state')
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    expect(closed.body.pendingPayment).toBeNull();

    const payment = await prisma.payment.findMany({ where: { bookingId } });
    expect(payment).toHaveLength(1);
    expect(payment[0]!.amountCents).toBe(2636);
  }, 30_000);

  it('double cash-collected is idempotent sequentially and under concurrency', async () => {
    const sequentialId = await seedPaymentPending(`BC-MN2${tail}`);
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${sequentialId}/cash-collected`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${sequentialId}/cash-collected`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    expect(await prisma.payment.count({ where: { bookingId: sequentialId } })).toBe(1);
    expect(
      await prisma.ledgerTransaction.count({
        where: {
          sourceType: 'BOOKING',
          sourceId: sequentialId,
          kind: 'TRIP_CASH',
        },
      }),
    ).toBe(1);
    expect(
      (await prisma.booking.findUniqueOrThrow({ where: { id: sequentialId } })).status,
    ).toBe('CLOSED');

    const concurrentId = await seedPaymentPending(`BC-MN3${tail}`);
    const [left, right] = await Promise.all([
      request(app.getHttpServer())
        .post(`/api/v1/driver/bookings/${concurrentId}/cash-collected`)
        .set('Authorization', `Bearer ${driverToken}`),
      request(app.getHttpServer())
        .post(`/api/v1/driver/bookings/${concurrentId}/cash-collected`)
        .set('Authorization', `Bearer ${driverToken}`),
    ]);
    expect([left.status, right.status].filter((code) => code === 200).length).toBeGreaterThanOrEqual(
      1,
    );
    expect(
      [left.status, right.status].every((code) => code === 200 || code === 409),
    ).toBe(true);
    expect(await prisma.payment.count({ where: { bookingId: concurrentId } })).toBe(1);
    expect(
      await prisma.ledgerTransaction.count({
        where: {
          sourceType: 'BOOKING',
          sourceId: concurrentId,
          kind: 'TRIP_CASH',
        },
      }),
    ).toBe(1);
    expect(
      (await prisma.booking.findUniqueOrThrow({ where: { id: concurrentId } })).status,
    ).toBe('CLOSED');
  }, 30_000);

  it('refuses wrong driver, wrong status, and non-cash methods', async () => {
    const pendingId = await seedPaymentPending(`BC-MN4${tail}`);
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${pendingId}/cash-collected`)
      .set('Authorization', `Bearer ${otherToken}`)
      .expect(404);

    await prisma.booking.update({
      where: { id: pendingId },
      data: { status: 'TRIP_STARTED' },
    });
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${pendingId}/cash-collected`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(409);

    await prisma.booking.update({
      where: { id: pendingId },
      data: { status: 'PAYMENT_PENDING', paymentMethod: 'CARD' },
    });
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${pendingId}/cash-collected`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(409);
  });

  it('makes the driver balance negative after a cash trip and nets a reversal to zero', async () => {
    const bookingId = await seedPaymentPending(`BC-MN5${tail}`, {
      finalSubtotalCents: 2510,
      finalTaxCents: 126,
      finalFareCents: 2636,
      commissionBps: 1500,
      commissionCents: 377,
      driverEarningCents: 2133,
    });
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/cash-collected`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);

    const balance = await request(app.getHttpServer())
      .get(`/api/v1/finance/drivers/${driverId}/balance`)
      .set('Authorization', `Bearer ${accountsToken}`)
      .expect(200);
    expect(balance.body.balanceCents).toBeLessThan(0);

    const txn = await prisma.ledgerTransaction.findFirstOrThrow({
      where: { sourceType: 'BOOKING', sourceId: bookingId, kind: 'TRIP_CASH' },
      include: { entries: true },
    });
    const originalSum = txn.entries.reduce((s, e) => s + e.amountCents, 0);
    expect(originalSum).toBe(0);

    const reversed = await request(app.getHttpServer())
      .post(`/api/v1/finance/transactions/${txn.id}/reverse`)
      .set('Authorization', `Bearer ${accountsToken}`)
      .send({ reason: 'Test refund' })
      .expect(200);
    expect(reversed.body.kind).toBe('REVERSAL');

    const all = await prisma.ledgerEntry.findMany({
      where: {
        transaction: {
          OR: [{ id: txn.id }, { reversalOfId: txn.id }],
        },
      },
    });
    expect(all.reduce((s, e) => s + e.amountCents, 0)).toBe(0);

    await request(app.getHttpServer())
      .post(`/api/v1/finance/transactions/${txn.id}/reverse`)
      .set('Authorization', `Bearer ${accountsToken}`)
      .send({ reason: 'Again' })
      .expect(409);
  }, 30_000);

  it('refuses adjust-fare after payment, respects the cap, and audits while pending', async () => {
    const pendingId = await seedPaymentPending(`BC-MN6${tail}`);
    const adjusted = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${pendingId}/adjust-fare`)
      .set('Authorization', `Bearer ${branchAdminToken}`)
      .send({ subtotalCents: 3000, reason: 'Wrong drop-off' })
      .expect(200);
    expect(adjusted.body).toMatchObject({
      finalSubtotalCents: 3000,
      finalTaxCents: 150,
      finalFareCents: 3150,
    });
    const audit = await prisma.auditLog.findFirst({
      where: { entityId: pendingId, action: 'booking.fare_adjusted' },
    });
    expect(audit).toBeTruthy();

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${pendingId}/adjust-fare`)
      .set('Authorization', `Bearer ${branchAdminToken}`)
      .send({ subtotalCents: 50_001, reason: 'Over cap' })
      .expect(400);

    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${pendingId}/cash-collected`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${pendingId}/adjust-fare`)
      .set('Authorization', `Bearer ${branchAdminToken}`)
      .send({ subtotalCents: 2800, reason: 'Too late' })
      .expect(409);
  }, 30_000);

  it('flags a deliberately corrupted total in a scratch database', async () => {
    await withScratchLedgerDb(async (scratch) => {
      await scratch.$executeRawUnsafe(`
        CREATE TABLE "LedgerEntry" (
          id text PRIMARY KEY,
          "amountCents" integer NOT NULL
        )
      `);
      await scratch.$executeRawUnsafe(
        `INSERT INTO "LedgerEntry" (id, "amountCents") VALUES ('corrupt-1', 12)`,
      );
      const service = new LedgerIntegrityService(scratch as never);
      await expect(service.check()).resolves.toEqual({ ok: false, sumCents: 12 });
    });
  });

  async function seedTripStarted(
    trackingId: string,
    money: { quotedFareCents: number; quotedTaxCents: number },
  ) {
    const bookingId = await insertBooking(trackingId, money);
    await bookings.transition(
      bookingId,
      'DRIVER_ASSIGNED',
      { type: 'STAFF', userId: driverUserId },
      { patch: { driverId, vehicleId, assignedAt: new Date() } },
    );
    await prisma.bookingAssignment.create({
      data: {
        bookingId,
        driverId,
        vehicleId,
        method: 'MANUAL',
      },
    });
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/arriving`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/arrived`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .post(`/api/v1/driver/bookings/${bookingId}/start`)
      .set('Authorization', `Bearer ${driverToken}`)
      .expect(200);
    return bookingId;
  }

  async function seedPaymentPending(
    trackingId: string,
    overrides: Record<string, unknown> = {},
  ) {
    const booking = await prisma.booking.create({
      data: {
        trackingId,
        branchId: homeBranchId,
        source: 'DISPATCH',
        status: 'PAYMENT_PENDING',
        paymentMethod: 'CASH',
        paymentStatus: 'UNPAID',
        passengerName: 'Cash Rider',
        passengerPhone: driverPhone,
        vehicleTypeId: typeId,
        driverId,
        vehicleId,
        distanceMeters: 1200,
        durationSeconds: 240,
        quotedFareCents: 2510,
        quotedTaxCents: 126,
        gstRateBps: 500,
        commissionBps: 1500,
        finalSubtotalCents: 2510,
        finalTaxCents: 126,
        finalFareCents: 2636,
        commissionCents: 377,
        driverEarningCents: 2133,
        completedAt: new Date(),
        ...overrides,
        stops: {
          create: [
            {
              sequence: 1,
              type: 'PICKUP',
              address: 'City Hall',
              lat: lethbridge.lat,
              lng: lethbridge.lng,
            },
            {
              sequence: 2,
              type: 'DROPOFF',
              address: 'Airport',
              lat: 49.63,
              lng: -112.8,
            },
          ],
        },
      },
    });
    return booking.id;
  }

  async function insertBooking(
    trackingId: string,
    money: { quotedFareCents: number; quotedTaxCents: number },
  ) {
    const booking = await prisma.booking.create({
      data: {
        trackingId,
        branchId: homeBranchId,
        source: 'DISPATCH',
        status: 'SEARCHING_DRIVER',
        paymentMethod: 'CASH',
        passengerName: 'Cash Rider',
        passengerPhone: driverPhone,
        vehicleTypeId: typeId,
        distanceMeters: 1200,
        durationSeconds: 240,
        quotedFareCents: money.quotedFareCents,
        quotedTaxCents: money.quotedTaxCents,
        gstRateBps: 500,
        stops: {
          create: [
            {
              sequence: 1,
              type: 'PICKUP',
              address: 'City Hall',
              lat: lethbridge.lat,
              lng: lethbridge.lng,
            },
            {
              sequence: 2,
              type: 'DROPOFF',
              address: 'Airport',
              lat: 49.63,
              lng: -112.8,
            },
          ],
        },
      },
    });
    return booking.id;
  }

  async function createDriver(
    firstName: string,
    lastName: string,
    phone: string,
    label: string,
  ) {
    const role = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-money-${label}-${stamp}@example.com`,
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
        email: `e2e-money-${roleName}-${stamp}@example.com`,
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
          storageKey: `e2e/money/${stamp}/${documentType.code}`,
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
});

async function withScratchLedgerDb(
  run: (client: PrismaClient) => Promise<void>,
) {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) throw new Error('DATABASE_URL is required');
  const scratchName = `bridgecabs_scratch_${Date.now()}`;
  const adminUrl = databaseUrl.replace(/\/[^/?]+(\?.*)?$/, '/postgres$1');
  const scratchUrl = databaseUrl.replace(/\/[^/?]+(\?.*)?$/, `/${scratchName}$1`);
  const admin = new PrismaClient({ datasourceUrl: adminUrl });
  await admin.$executeRawUnsafe(`CREATE DATABASE "${scratchName}"`);
  const scratch = new PrismaClient({ datasourceUrl: scratchUrl });
  try {
    await run(scratch);
  } finally {
    await scratch.$disconnect();
    await admin.$executeRawUnsafe(`DROP DATABASE "${scratchName}" WITH (FORCE)`);
    await admin.$disconnect();
  }
}

