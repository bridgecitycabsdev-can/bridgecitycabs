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
const phoneA = `4032${tail}`;
const phoneB = `4033${tail}`;
const licenceCode = `E2E_LICENCE_${stamp}`;
const policeCode = `E2E_POLICE_${stamp}`;
const optionalCode = `E2E_OPTIONAL_${stamp}`;
const vehicleDocCode = `E2E_VEHICLE_DOC_${stamp}`;

describe('drivers (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  const driverIds: string[] = [];
  const branchIds: string[] = [];
  let homeBranchId: string;
  let otherBranchId: string;
  let superToken: string;
  let adminToken: string;
  let dispatcherToken: string;
  let passengerToken: string;
  let superUserId: string;
  let driverId: string;
  let typeId: string;
  let makeId: string;
  let modelId: string;
  let vehicleId: string;
  let licenceTypeId: string;

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

    await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });

    const home = await prisma.branch.create({
      data: { name: `E2E Drivers ${stamp}`, city: 'Lethbridge' },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Drivers Other ${stamp}`, city: 'Calgary' },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    branchIds.push(home.id, other.id);

    const vehicleType = await prisma.vehicleType.create({
      data: { name: `E2E Driver Type ${stamp}` },
    });
    typeId = vehicleType.id;
    const make = await prisma.vehicleMake.create({
      data: { name: `E2E Driver Make ${stamp}` },
    });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: { makeId, vehicleTypeId: typeId, name: `E2E Driver Model ${stamp}` },
    });
    modelId = model.id;
    const vehicle = await prisma.vehicle.create({
      data: {
        branchId: homeBranchId,
        modelId,
        vehicleTypeId: typeId,
        plateNumber: `D${tail}`,
        year: 2020,
      },
    });
    vehicleId = vehicle.id;

    const licence = await prisma.documentType.create({
      data: {
        code: licenceCode,
        name: 'E2E licence',
        owner: 'DRIVER',
        required: true,
      },
    });
    await prisma.documentType.create({
      data: {
        code: policeCode,
        name: 'E2E police check',
        owner: 'DRIVER',
        required: true,
      },
    });
    licenceTypeId = licence.id;
    await prisma.documentType.create({
      data: {
        code: optionalCode,
        name: 'E2E optional',
        owner: 'DRIVER',
        required: false,
      },
    });
    await prisma.documentType.create({
      data: {
        code: vehicleDocCode,
        name: 'E2E vehicle doc',
        owner: 'VEHICLE',
        required: true,
      },
    });

    superUserId = await createUser('super_admin');
    superToken = await login(`e2e-drivers-super_admin-${stamp}@example.com`);
    await createUser('branch_admin', homeBranchId);
    adminToken = await login(`e2e-drivers-branch_admin-${stamp}@example.com`);
    await createUser('dispatcher', homeBranchId);
    dispatcherToken = await login(`e2e-drivers-dispatcher-${stamp}@example.com`);
    await createUser('passenger');
    passengerToken = await login(`e2e-drivers-passenger-${stamp}@example.com`);
  });

  afterAll(async () => {
    await prisma.document.deleteMany({ where: { driverId: { in: driverIds } } });
    await prisma.driverVehicleAssignment.deleteMany({
      where: { driverId: { in: driverIds } },
    });
    await prisma.driver.deleteMany({ where: { id: { in: driverIds } } });
    await prisma.vehicle.deleteMany({ where: { id: vehicleId } });
    if (modelId) {
      await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    }
    if (makeId) {
      await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    }
    if (typeId) {
      await prisma.vehicleType.delete({ where: { id: typeId } }).catch(() => undefined);
    }
    await prisma.documentType.deleteMany({
      where: { code: { in: [licenceCode, policeCode, optionalCode, vehicleDocCode] } },
    });
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('rejects unauthenticated callers, passengers, and non-approvers', async () => {
    await request(app.getHttpServer()).get('/api/v1/drivers').expect(401);
    await request(app.getHttpServer())
      .get('/api/v1/drivers')
      .set('Authorization', `Bearer ${passengerToken}`)
      .expect(403);
  });

  it('creates a passwordless driver user in the caller branch', async () => {
    const created = await request(app.getHttpServer())
      .post('/api/v1/drivers')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        branchId: otherBranchId,
        firstName: 'Ada',
        lastName: `Lovelace${tail}`,
        phone: phoneA,
        email: `Ada.Driver.${stamp}@Example.com`,
      })
      .expect(201);
    driverId = created.body.id;
    driverIds.push(driverId);
    userIds.push(created.body.user.id);
    expect(created.body.branchId).toBe(homeBranchId);
    expect(created.body.phone).toBe(`+1${phoneA}`);
    expect(created.body.status).toBe('PENDING_DOCUMENTS');
    expect(created.body.user.email).toBe(`ada.driver.${stamp}@example.com`);
    expect(created.body.user.passwordHash).toBeUndefined();

    const account = await prisma.user.findUnique({
      where: { id: created.body.user.id },
      include: { role: true },
    });
    expect(account?.passwordHash).toBeNull();
    expect(account?.role.name).toBe('driver');
    expect(account?.phone).toBe(`+1${phoneA}`);

    await request(app.getHttpServer())
      .post('/api/v1/drivers')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        branchId: homeBranchId,
        firstName: 'Ada',
        lastName: 'Duplicate',
        phone: `(403) 2${tail}`,
      })
      .expect(409);
  });

  it('lists, searches, and returns options and detail', async () => {
    const other = await request(app.getHttpServer())
      .post('/api/v1/drivers')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        branchId: otherBranchId,
        firstName: 'Grace',
        lastName: `Hopper${tail}`,
        phone: phoneB,
      })
      .expect(201);
    driverIds.push(other.body.id);
    userIds.push(other.body.user.id);

    const listed = await request(app.getHttpServer())
      .get('/api/v1/drivers')
      .query({ search: `Ada Lovelace${tail}`, status: 'PENDING_DOCUMENTS' })
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(listed.body.data.map((row: { id: string }) => row.id)).toEqual([driverId]);
    expect(listed.body.meta.total).toBe(1);

    await request(app.getHttpServer())
      .get(`/api/v1/drivers/${other.body.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(404);

    await prisma.driverVehicleAssignment.create({
      data: { driverId, vehicleId },
    });
    const detail = await request(app.getHttpServer())
      .get(`/api/v1/drivers/${driverId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(detail.body.currentVehicle.plateNumber).toBe(`D${tail}`);
    expect(detail.body.documents).toEqual([]);

    const options = await request(app.getHttpServer())
      .get('/api/v1/drivers/options')
      .query({ withoutVehicle: 'true' })
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    const ids = options.body.map((row: { id: string; name: string }) => row.id);
    expect(ids).not.toContain(driverId);
    expect(ids).toContain(other.body.id);

    const renamed = await request(app.getHttpServer())
      .patch(`/api/v1/drivers/${driverId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ firstName: 'Augusta' })
      .expect(200);
    expect(renamed.body.firstName).toBe('Augusta');
  });

  it('blocks illegal approval and suspends only from an approved driver', async () => {
    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/approve`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .expect(403);

    const blocked = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/approve`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(422);
    expect(blocked.body.message).toBe('Missing documents');

    await prisma.driver.update({
      where: { id: driverId },
      data: { status: 'PENDING_APPROVAL' },
    });

    const missing = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/approve`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(422);
    expect(missing.body.message).toBe('Missing documents');
    expect(missing.body.missing).toEqual(expect.arrayContaining([licenceCode, policeCode]));
    expect(missing.body.missing).not.toContain(optionalCode);
    expect(missing.body.missing).not.toContain(vehicleDocCode);

    await prisma.document.create({
      data: {
        documentTypeId: licenceTypeId,
        driverId,
        storageKey: `e2e/${stamp}/licence-expired`,
        status: 'APPROVED',
        expiresAt: new Date('2020-01-01T00:00:00.000Z'),
      },
    });
    const stillMissing = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/approve`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(422);
    expect(stillMissing.body.missing).toContain(licenceCode);

    const required = await prisma.documentType.findMany({
      where: { owner: 'DRIVER', required: true },
    });
    for (const documentType of required) {
      await prisma.document.create({
        data: {
          documentTypeId: documentType.id,
          driverId,
          storageKey: `e2e/${stamp}/${documentType.code}`,
          status: 'APPROVED',
          expiresAt: null,
        },
      });
    }

    const approved = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/approve`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(approved.body.status).toBe('APPROVED');
    expect(approved.body.approvedById).toBe(superUserId);
    expect(approved.body.approvedAt).toBeTruthy();

    await prisma.driver.update({
      where: { id: driverId },
      data: { status: 'REJECTED' },
    });
    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/approve`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(400);

    await prisma.driver.update({
      where: { id: driverId },
      data: { status: 'APPROVED' },
    });
    const suspended = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/suspend`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ reason: 'Failed a roadside inspection' })
      .expect(200);
    expect(suspended.body.status).toBe('SUSPENDED');
    expect(suspended.body.suspensionReason).toBe('Failed a roadside inspection');

    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/suspend`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ reason: 'Already suspended' })
      .expect(400);

    const reinstated = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/approve`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(reinstated.body.status).toBe('APPROVED');
    expect(reinstated.body.suspensionReason).toBeNull();
  });

  async function createUser(roleName: string, branchId?: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-drivers-${roleName}-${stamp}@example.com`,
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
