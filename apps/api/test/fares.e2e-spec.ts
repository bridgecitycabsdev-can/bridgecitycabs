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

loadEnvFile();

const prisma = new PrismaClient();
const password = 'correct-password';
const stamp = Date.now();
const origin = { lat: 0, lng: 0 };
const oneKmNorth = {
  lat: (1000 / 6_371_000) * (180 / Math.PI),
  lng: 0,
};

describe('fares (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  const branchIds: string[] = [];
  let typeId: string;
  let homeBranchId: string;
  let otherBranchId: string;
  let ruleId: string;
  let superToken: string;
  let adminToken: string;
  let otherAdminToken: string;
  let dispatcherToken: string;
  let passengerToken: string;

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
      data: { name: `E2E Fares ${stamp}`, city: 'Lethbridge', gstRateBps: 500 },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Fares Other ${stamp}`, city: 'Calgary', gstRateBps: 500 },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    branchIds.push(home.id, other.id);

    const type = await prisma.vehicleType.create({
      data: { name: `E2E SUV ${stamp}` },
    });
    typeId = type.id;

    superToken = await login(await createUser('super_admin', 'super'));
    adminToken = await login(await createUser('branch_admin', 'home', homeBranchId));
    otherAdminToken = await login(
      await createUser('branch_admin', 'other', otherBranchId),
    );
    dispatcherToken = await login(
      await createUser('dispatcher', 'dispatch', homeBranchId),
    );
    passengerToken = await login(await createUser('passenger', 'rider'));
  });

  afterAll(async () => {
    await prisma.fareRule.deleteMany({ where: { branchId: { in: branchIds } } });
    if (typeId) {
      await prisma.vehicleType.delete({ where: { id: typeId } }).catch(() => undefined);
    }
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('rejects unauthenticated and non-staff callers', async () => {
    await request(app.getHttpServer()).get('/api/v1/fare-rules').expect(401);
    await request(app.getHttpServer())
      .get('/api/v1/fare-rules')
      .set('Authorization', `Bearer ${passengerToken}`)
      .expect(403);
    await request(app.getHttpServer())
      .post('/api/v1/fares/quote')
      .set('Authorization', `Bearer ${passengerToken}`)
      .send(quoteBody(homeBranchId))
      .expect(403);
  });

  it('lets a branch admin write only their own branch, and staff read it', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/fare-rules')
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send(ruleBody(homeBranchId))
      .expect(403);

    const created = await request(app.getHttpServer())
      .post('/api/v1/fare-rules')
      .set('Authorization', `Bearer ${adminToken}`)
      .send(ruleBody(otherBranchId))
      .expect(201);
    ruleId = created.body.id;
    expect(created.body.branchId).toBe(homeBranchId);
    expect(created.body.perMinuteCents).toBe(0);
    expect(created.body.minFareCents).toBe(0);
    expect(created.body.vehicleType.name).toContain('SUV');

    await request(app.getHttpServer())
      .post('/api/v1/fare-rules')
      .set('Authorization', `Bearer ${adminToken}`)
      .send(ruleBody(homeBranchId, 'OUT_OF_TOWN'))
      .expect(201);

    const duplicate = await request(app.getHttpServer())
      .post('/api/v1/fare-rules')
      .set('Authorization', `Bearer ${adminToken}`)
      .send(ruleBody(homeBranchId))
      .expect(409);
    expect(duplicate.body.message).toBe(
      'A fare rule already exists for this vehicle type and zone',
    );

    const listed = await request(app.getHttpServer())
      .get('/api/v1/fare-rules')
      .query({ vehicleTypeId: typeId, zone: 'INSIDE_TOWN' })
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .expect(200);
    expect(listed.body.data).toHaveLength(1);
    expect(listed.body.data[0].id).toBe(ruleId);

    await request(app.getHttpServer())
      .get(`/api/v1/fare-rules/${ruleId}`)
      .set('Authorization', `Bearer ${otherAdminToken}`)
      .expect(404);

    const hidden = await request(app.getHttpServer())
      .get('/api/v1/fare-rules')
      .query({ branchId: homeBranchId })
      .set('Authorization', `Bearer ${otherAdminToken}`)
      .expect(200);
    expect(hidden.body.data).toHaveLength(0);
  });

  it('quotes from the active rule and changes when the rule changes', async () => {
    const bookingsBefore = await prisma.booking.count();
    const trip = await new HaversineDistanceService().estimate(origin, oneKmNorth);
    const expected = calcFare(
      {
        baseFareCents: 595,
        perKmCents: 249,
        perMinuteCents: 0,
        minFareCents: 0,
      },
      trip.meters,
      trip.seconds,
      500,
    );

    const quoted = await request(app.getHttpServer())
      .post('/api/v1/fares/quote')
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send(quoteBody(otherBranchId))
      .expect(201);
    expect(quoted.body).toEqual({
      distanceMeters: trip.meters,
      durationSeconds: trip.seconds,
      ...expected,
    });
    expect(await prisma.booking.count()).toBe(bookingsBefore);

    await request(app.getHttpServer())
      .post('/api/v1/fares/quote')
      .set('Authorization', `Bearer ${otherAdminToken}`)
      .send(quoteBody(homeBranchId))
      .expect(404);

    await request(app.getHttpServer())
      .patch(`/api/v1/fare-rules/${ruleId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ perKmCents: 300, branchId: otherBranchId })
      .expect(200);

    const revised = await request(app.getHttpServer())
      .post('/api/v1/fares/quote')
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send(quoteBody(homeBranchId))
      .expect(201);
    const revisedExpected = calcFare(
      {
        baseFareCents: 595,
        perKmCents: 300,
        perMinuteCents: 0,
        minFareCents: 0,
      },
      trip.meters,
      trip.seconds,
      500,
    );
    expect(revised.body.subtotalCents).toBe(revisedExpected.subtotalCents);
    expect(revised.body.subtotalCents).not.toBe(expected.subtotalCents);

    const stillHome = await prisma.fareRule.findUnique({ where: { id: ruleId } });
    expect(stillHome?.branchId).toBe(homeBranchId);

    await request(app.getHttpServer())
      .patch(`/api/v1/fare-rules/${ruleId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ active: false })
      .expect(200);
    await request(app.getHttpServer())
      .post('/api/v1/fares/quote')
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send(quoteBody(homeBranchId))
      .expect(404);

    await request(app.getHttpServer())
      .delete(`/api/v1/fare-rules/${ruleId}`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .expect(403);
    await request(app.getHttpServer())
      .delete(`/api/v1/fare-rules/${ruleId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .get(`/api/v1/fare-rules/${ruleId}`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(404);
  });

  function ruleBody(
    branchId: string,
    zone: 'INSIDE_TOWN' | 'OUT_OF_TOWN' = 'INSIDE_TOWN',
  ) {
    return {
      branchId,
      vehicleTypeId: typeId,
      zone,
      title: `SUV ${zone === 'INSIDE_TOWN' ? 'inside' : 'outside'} town`,
      baseFareCents: 595,
      perKmCents: 249,
    };
  }

  function quoteBody(branchId: string) {
    return {
      branchId,
      vehicleTypeId: typeId,
      zone: 'INSIDE_TOWN',
      stops: [origin, oneKmNorth],
    };
  }

  async function createUser(roleName: string, label: string, branchId?: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-fares-${label}-${stamp}@example.com`,
        passwordHash: await argon2.hash(password),
        roleId: role.id,
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
