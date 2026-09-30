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

loadEnvFile();

const prisma = new PrismaClient();
const password = 'correct-password';
const stamp = Date.now();
const tail = String(stamp).slice(-6);
const requiredCodes = [
  'AB_DRIVERS_LICENCE',
  'POLICE_CHECK_VSC',
  'WORK_ELIGIBILITY',
] as const;

describe('fleet rules (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  const driverIds: string[] = [];
  const vehicleIds: string[] = [];
  const branchIds: string[] = [];
  const typeNames: string[] = [];
  let homeBranchId: string;
  let otherBranchId: string;
  let modelId: string;
  let typeId: string;
  let superToken: string;
  let adminToken: string;
  let homeDriverId: string;

  beforeAll(async () => {
    await prisma.user
      .findUnique({ where: { phone: '+14035550100' } })
      .then(async (existing) => {
        if (!existing) return;
        await prisma.driver.deleteMany({ where: { userId: existing.id } });
        await prisma.passenger.deleteMany({ where: { userId: existing.id } });
        await prisma.refreshToken.deleteMany({ where: { userId: existing.id } });
        await prisma.user.delete({ where: { id: existing.id } });
      });

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

    for (const code of requiredCodes) {
      await prisma.documentType.upsert({
        where: { code },
        update: { owner: 'DRIVER', required: true, hasExpiry: true },
        create: {
          code,
          name: code,
          owner: 'DRIVER',
          required: true,
          hasExpiry: true,
        },
      });
    }

    const home = await prisma.branch.create({
      data: { name: `Fleet Home ${stamp}`, city: 'Lethbridge' },
    });
    const other = await prisma.branch.create({
      data: { name: `Fleet Other ${stamp}`, city: 'Calgary' },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    branchIds.push(home.id, other.id);

    const vehicleType = await prisma.vehicleType.create({
      data: { name: `Fleet Type ${stamp}` },
    });
    typeId = vehicleType.id;
    typeNames.push(vehicleType.name);
    const make = await prisma.vehicleMake.create({
      data: { name: `Fleet Make ${stamp}` },
    });
    const model = await prisma.vehicleModel.create({
      data: { makeId: make.id, vehicleTypeId: typeId, name: `Fleet Model ${stamp}` },
    });
    modelId = model.id;

    await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    await createUser('super_admin');
    superToken = await login(`e2e-fleet-super_admin-${stamp}@example.com`);
    await createUser('branch_admin', homeBranchId);
    adminToken = await login(`e2e-fleet-branch_admin-${stamp}@example.com`);
  });

  afterAll(async () => {
    await prisma.driverVehicleAssignment.deleteMany({
      where: { OR: [{ driverId: { in: driverIds } }, { vehicleId: { in: vehicleIds } }] },
    });
    await prisma.document.deleteMany({ where: { driverId: { in: driverIds } } });
    await prisma.driver.deleteMany({ where: { id: { in: driverIds } } });
    await prisma.vehicle.deleteMany({ where: { id: { in: vehicleIds } } });
    if (modelId) {
      await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    }
    await prisma.vehicleMake.deleteMany({ where: { name: `Fleet Make ${stamp}` } });
    await prisma.vehicleType.deleteMany({
      where: { name: { in: [...typeNames, `Fleet Type ${stamp}`] } },
    });
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('keeps a branch admin inside their own drivers', async () => {
    await createDriver(superToken, otherBranchId, 'Other', demoPhone());
    const home = await request(app.getHttpServer())
      .post('/api/v1/drivers')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        branchId: otherBranchId,
        firstName: 'Home',
        lastName: `Fleet${tail}`,
        phone: demoPhone(),
      })
      .expect(201);
    homeDriverId = home.body.id;
    driverIds.push(homeDriverId);
    userIds.push(home.body.user.id);
    expect(home.body.branchId).toBe(homeBranchId);

    const listed = await request(app.getHttpServer())
      .get('/api/v1/drivers')
      .query({ search: `Fleet${tail}` })
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(listed.body.data.map((row: { id: string }) => row.id)).toEqual([homeDriverId]);
    expect(listed.body.meta.total).toBe(1);
  });

  it('blocks approval until required documents are valid, then assigns the vehicle', async () => {
    const missing = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${homeDriverId}/approve`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(422);
    expect(missing.body.message).toBe('Missing documents');
    expect(missing.body.missing).toEqual(expect.arrayContaining([...requiredCodes]));

    const licence = await prisma.documentType.findUniqueOrThrow({
      where: { code: 'AB_DRIVERS_LICENCE' },
    });
    await prisma.document.create({
      data: {
        documentTypeId: licence.id,
        driverId: homeDriverId,
        storageKey: `drivers/${homeDriverId}/licence-expired.pdf`,
        status: 'APPROVED',
        expiresAt: new Date('2020-01-01T00:00:00.000Z'),
      },
    });
    const stillMissing = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${homeDriverId}/approve`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(422);
    expect(stillMissing.body.missing).toContain('AB_DRIVERS_LICENCE');

    const required = await prisma.documentType.findMany({
      where: { owner: 'DRIVER', required: true },
    });
    for (const documentType of required) {
      const created = await request(app.getHttpServer())
        .post(`/api/v1/drivers/${homeDriverId}/documents`)
        .set('Authorization', `Bearer ${superToken}`)
        .send({
          documentTypeId: documentType.id,
          expiresAt: documentType.hasExpiry ? daysFromNow(400) : undefined,
          storageKey: `drivers/${homeDriverId}/${documentType.code}.pdf`,
        })
        .expect(201);
      expect(created.body.storageKey.includes('://')).toBe(false);
      await request(app.getHttpServer())
        .post(`/api/v1/documents/${created.body.id}/review`)
        .set('Authorization', `Bearer ${superToken}`)
        .send({ status: 'APPROVED' })
        .expect(200);
    }

    const approved = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${homeDriverId}/approve`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(approved.body.status).toBe('APPROVED');

    const vehicle = await createVehicle(superToken, homeBranchId, `H${tail}`);
    const assigned = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${homeDriverId}/assign-vehicle`)
      .set('Authorization', `Bearer ${superToken}`)
      .send({ vehicleId: vehicle.id })
      .expect(201);
    expect(assigned.body.endedAt).toBeNull();

    const history = await prisma.driverVehicleAssignment.findMany({
      where: { vehicleId: vehicle.id },
    });
    expect(history).toHaveLength(1);
    expect(history[0]?.endedAt).toBeNull();
    expect(history[0]?.startedAt).toBeTruthy();
  });

  it('rejects a duplicate plate in one branch and allows it in another', async () => {
    const plate = `P${tail}`;
    await createVehicle(superToken, homeBranchId, plate);
    const collision = await request(app.getHttpServer())
      .post('/api/v1/vehicles')
      .set('Authorization', `Bearer ${superToken}`)
      .send(vehicleBody(homeBranchId, plate))
      .expect(409);
    expect(collision.body.message).toBe(
      'A vehicle with that plate already exists in this branch',
    );
    const other = await createVehicle(superToken, otherBranchId, plate);
    expect(other.branchId).toBe(otherBranchId);
  });

  it('returns page meta and rejects a pageSize above 100', async () => {
    const prefix = `FleetPage${stamp}`;
    typeNames.push(`${prefix}-a`, `${prefix}-b`);
    await request(app.getHttpServer())
      .post('/api/v1/vehicle-types')
      .set('Authorization', `Bearer ${superToken}`)
      .send({ name: `${prefix}-a` })
      .expect(201);
    await request(app.getHttpServer())
      .post('/api/v1/vehicle-types')
      .set('Authorization', `Bearer ${superToken}`)
      .send({ name: `${prefix}-b` })
      .expect(201);

    const page = await request(app.getHttpServer())
      .get('/api/v1/vehicle-types')
      .query({ search: prefix, pageSize: 1 })
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(page.body.data).toHaveLength(1);
    expect(page.body.meta).toEqual({
      page: 1,
      pageSize: 1,
      total: 2,
      totalPages: 2,
    });

    await request(app.getHttpServer())
      .get('/api/v1/vehicle-types')
      .query({ pageSize: 100 })
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .get('/api/v1/vehicle-types')
      .query({ pageSize: 101 })
      .set('Authorization', `Bearer ${superToken}`)
      .expect(400);
  });

  it('stores both phone spellings as +14035550100', async () => {
    const created = await request(app.getHttpServer())
      .post('/api/v1/drivers')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        branchId: homeBranchId,
        firstName: 'Phone',
        lastName: `Norm${tail}`,
        phone: '403-555-0100',
      })
      .expect(201);
    driverIds.push(created.body.id);
    userIds.push(created.body.user.id);
    expect(created.body.phone).toBe('+14035550100');
    expect(created.body.user.phone).toBe('+14035550100');

    await request(app.getHttpServer())
      .post('/api/v1/drivers')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        branchId: homeBranchId,
        firstName: 'Phone',
        lastName: 'Again',
        phone: '+14035550100',
      })
      .expect(409);
  });

  it('lets only one concurrent assignment claim a vehicle', async () => {
    const first = await createDriver(superToken, homeBranchId, 'RaceA', demoPhone());
    const second = await createDriver(superToken, homeBranchId, 'RaceB', demoPhone());
    await prisma.driver.updateMany({
      where: { id: { in: [first.id, second.id] } },
      data: { status: 'APPROVED', approvedAt: new Date() },
    });
    const vehicle = await createVehicle(superToken, homeBranchId, `R${tail}`);

    const [left, right] = await Promise.all([
      request(app.getHttpServer())
        .post(`/api/v1/drivers/${first.id}/assign-vehicle`)
        .set('Authorization', `Bearer ${superToken}`)
        .send({ vehicleId: vehicle.id }),
      request(app.getHttpServer())
        .post(`/api/v1/drivers/${second.id}/assign-vehicle`)
        .set('Authorization', `Bearer ${superToken}`)
        .send({ vehicleId: vehicle.id }),
    ]);
    expect([left.status, right.status].sort()).toEqual([201, 409]);

    const open = await prisma.driverVehicleAssignment.count({
      where: { vehicleId: vehicle.id, endedAt: null },
    });
    expect(open).toBe(1);

    const loserId = left.status === 409 ? first.id : second.id;
    const taken = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${loserId}/assign-vehicle`)
      .set('Authorization', `Bearer ${superToken}`)
      .send({ vehicleId: vehicle.id });
    expect(taken.status).toBe(409);
  });

  async function createDriver(
    token: string,
    branchId: string,
    firstName: string,
    phoneTail: string,
  ) {
    const response = await request(app.getHttpServer())
      .post('/api/v1/drivers')
      .set('Authorization', `Bearer ${token}`)
      .send({
        branchId,
        firstName,
        lastName: `Fleet${tail}`,
        phone: phoneTail,
      })
      .expect(201);
    driverIds.push(response.body.id);
    userIds.push(response.body.user.id);
    return response.body as { id: string; branchId: string };
  }

  function vehicleBody(branchId: string, plateNumber: string) {
    return { branchId, modelId, plateNumber, year: 2020 };
  }

  async function createVehicle(token: string, branchId: string, plateNumber: string) {
    const response = await request(app.getHttpServer())
      .post('/api/v1/vehicles')
      .set('Authorization', `Bearer ${token}`)
      .send(vehicleBody(branchId, plateNumber))
      .expect(201);
    vehicleIds.push(response.body.id);
    return response.body as { id: string; branchId: string };
  }

  async function createUser(roleName: string, branchId?: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-fleet-${roleName}-${stamp}@example.com`,
        passwordHash: await argon2.hash(password),
        roleId: role.id,
        branchId,
      },
    });
    userIds.push(user.id);
  }

  async function login(email: string) {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password })
      .expect(200);
    return response.body.accessToken as string;
  }
});

function demoPhone() {
  return `403${randomInt(2000000, 9999999)}`;
}

function daysFromNow(days: number) {
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000).toISOString();
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
