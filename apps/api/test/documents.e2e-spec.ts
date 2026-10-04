import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import argon2 from 'argon2';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { AppModule } from '../src/app.module.js';
import { loadEnvFile } from './load-env-file.js';

loadEnvFile();

const prisma = new PrismaClient();
const password = 'correct-password';
const stamp = Date.now();
const tail = String(stamp).slice(-6);
const licenceCode = `E2E_DOC_LICENCE_${stamp}`;
const registrationCode = `E2E_DOC_REG_${stamp}`;
const noteCode = `E2E_DOC_NOTE_${stamp}`;

describe('documents (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  const driverIds: string[] = [];
  const vehicleIds: string[] = [];
  const branchIds: string[] = [];
  let homeBranchId: string;
  let otherBranchId: string;
  let adminToken: string;
  let adminUserId: string;
  let dispatcherToken: string;
  let superToken: string;
  let passengerToken: string;
  let driverId: string;
  let otherDriverId: string;
  let vehicleId: string;
  let licenceTypeId: string;
  let registrationTypeId: string;
  let noteTypeId: string;

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
      data: { name: `E2E Docs ${stamp}`, city: 'Lethbridge' },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Docs Other ${stamp}`, city: 'Calgary' },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    branchIds.push(home.id, other.id);

    const vehicleType = await prisma.vehicleType.create({
      data: { name: `E2E Docs Type ${stamp}` },
    });
    const make = await prisma.vehicleMake.create({
      data: { name: `E2E Docs Make ${stamp}` },
    });
    const model = await prisma.vehicleModel.create({
      data: {
        makeId: make.id,
        vehicleTypeId: vehicleType.id,
        name: `E2E Docs Model ${stamp}`,
      },
    });
    const vehicle = await prisma.vehicle.create({
      data: {
        branchId: homeBranchId,
        modelId: model.id,
        vehicleTypeId: vehicleType.id,
        plateNumber: `K${tail}`,
        year: 2020,
      },
    });
    vehicleId = vehicle.id;
    vehicleIds.push(vehicle.id);

    const driverRole = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    driverId = await createDriver(driverRole.id, homeBranchId, 'Ada', `4032${tail}`);
    otherDriverId = await createDriver(
      driverRole.id,
      otherBranchId,
      'Grace',
      `4033${tail}`,
    );

    licenceTypeId = (
      await prisma.documentType.create({
        data: {
          code: licenceCode,
          name: 'E2E licence',
          owner: 'DRIVER',
          required: true,
          hasExpiry: true,
        },
      })
    ).id;
    registrationTypeId = (
      await prisma.documentType.create({
        data: {
          code: registrationCode,
          name: 'E2E registration',
          owner: 'VEHICLE',
          required: true,
          hasExpiry: true,
        },
      })
    ).id;
    noteTypeId = (
      await prisma.documentType.create({
        data: {
          code: noteCode,
          name: 'E2E note',
          owner: 'DRIVER',
          required: false,
          hasExpiry: false,
        },
      })
    ).id;

    adminUserId = await createUser('branch_admin', homeBranchId);
    adminToken = await login(`e2e-docs-branch_admin-${stamp}@example.com`);
    await createUser('dispatcher', homeBranchId);
    dispatcherToken = await login(`e2e-docs-dispatcher-${stamp}@example.com`);
    await createUser('super_admin');
    superToken = await login(`e2e-docs-super_admin-${stamp}@example.com`);
    await createUser('passenger');
    passengerToken = await login(`e2e-docs-passenger-${stamp}@example.com`);
  });

  afterAll(async () => {
    await prisma.document.deleteMany({
      where: {
        OR: [
          { driverId: { in: driverIds } },
          { vehicleId: { in: vehicleIds } },
        ],
      },
    });
    await prisma.driver.deleteMany({ where: { id: { in: driverIds } } });
    await prisma.vehicle.deleteMany({ where: { id: { in: vehicleIds } } });
    await prisma.vehicleModel.deleteMany({ where: { name: `E2E Docs Model ${stamp}` } });
    await prisma.vehicleMake.deleteMany({ where: { name: `E2E Docs Make ${stamp}` } });
    await prisma.vehicleType.deleteMany({ where: { name: `E2E Docs Type ${stamp}` } });
    await prisma.documentType.deleteMany({
      where: { code: { in: [licenceCode, registrationCode, noteCode] } },
    });
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('rejects unauthenticated and non-staff callers', async () => {
    await request(app.getHttpServer())
      .get('/api/v1/documents/expiring')
      .expect(401);
    await request(app.getHttpServer())
      .get('/api/v1/documents/expiring')
      .set('Authorization', `Bearer ${passengerToken}`)
      .expect(403);
  });

  it('stores an object key and rejects a public URL or the wrong owner', async () => {
    const created = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/documents`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send({
        documentTypeId: licenceTypeId,
        expiresAt: daysFromNow(10),
        storageKey: `drivers/${driverId}/licence.pdf`,
      })
      .expect(201);
    expect(created.body.storageKey).toBe(`drivers/${driverId}/licence.pdf`);
    expect(created.body.status).toBe('PENDING');
    expect(created.body.driverId).toBe(driverId);
    expect(created.body.vehicleId).toBeNull();

    const url = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/documents`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send({
        documentTypeId: licenceTypeId,
        expiresAt: daysFromNow(10),
        storageKey: 'https://files.example.com/licence.pdf',
      })
      .expect(400);
    expect(url.body.message).toBe('storageKey must be an object key, not a URL');

    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/documents`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send({
        documentTypeId: registrationTypeId,
        expiresAt: daysFromNow(10),
        storageKey: `drivers/${driverId}/registration.pdf`,
      })
      .expect(400);

    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/documents`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send({
        documentTypeId: licenceTypeId,
        storageKey: `drivers/${driverId}/missing-expiry.pdf`,
      })
      .expect(400);

    const note = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/documents`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        documentTypeId: noteTypeId,
        storageKey: `drivers/${driverId}/note.pdf`,
      })
      .expect(201);
    expect(note.body.expiresAt).toBeNull();

    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${otherDriverId}/documents`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        documentTypeId: licenceTypeId,
        expiresAt: daysFromNow(10),
        storageKey: `drivers/${otherDriverId}/licence.pdf`,
      })
      .expect(404);

    const vehicleDoc = await request(app.getHttpServer())
      .post(`/api/v1/vehicles/${vehicleId}/documents`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        documentTypeId: registrationTypeId,
        expiresAt: daysFromNow(5),
        storageKey: `vehicles/${vehicleId}/registration.pdf`,
      })
      .expect(201);
    expect(vehicleDoc.body.vehicleId).toBe(vehicleId);
    expect(vehicleDoc.body.driverId).toBeNull();
  });

  it('lets approvers accept or reject a document', async () => {
    const created = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/documents`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        documentTypeId: licenceTypeId,
        expiresAt: daysFromNow(20),
        storageKey: `drivers/${driverId}/review.pdf`,
      })
      .expect(201);

    await request(app.getHttpServer())
      .post(`/api/v1/documents/${created.body.id}/review`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send({ status: 'APPROVED' })
      .expect(403);

    await request(app.getHttpServer())
      .post(`/api/v1/documents/${created.body.id}/review`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'REJECTED' })
      .expect(400);

    const rejected = await request(app.getHttpServer())
      .post(`/api/v1/documents/${created.body.id}/review`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'REJECTED', note: 'Photo is unreadable' })
      .expect(200);
    expect(rejected.body.status).toBe('REJECTED');
    expect(rejected.body.rejectionNote).toBe('Photo is unreadable');
    expect(rejected.body.reviewedById).toBe(adminUserId);

    const approved = await request(app.getHttpServer())
      .post(`/api/v1/documents/${created.body.id}/review`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'APPROVED' })
      .expect(200);
    expect(approved.body.status).toBe('APPROVED');
    expect(approved.body.rejectionNote).toBeNull();
    expect(approved.body.reviewedAt).toBeTruthy();
  });

  it('lists documents that expire within the requested window', async () => {
    const soon = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/documents`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        documentTypeId: licenceTypeId,
        expiresAt: daysFromNow(12),
        storageKey: `drivers/${driverId}/soon.pdf`,
      })
      .expect(201);
    const later = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${driverId}/documents`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        documentTypeId: licenceTypeId,
        expiresAt: daysFromNow(90),
        storageKey: `drivers/${driverId}/later.pdf`,
      })
      .expect(201);
    const other = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${otherDriverId}/documents`)
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        documentTypeId: licenceTypeId,
        expiresAt: daysFromNow(8),
        storageKey: `drivers/${otherDriverId}/soon.pdf`,
      })
      .expect(201);

    const home = await request(app.getHttpServer())
      .get('/api/v1/documents/expiring')
      .query({ days: 30, search: licenceCode })
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    const homeIds = home.body.data.map((row: { id: string }) => row.id);
    expect(homeIds).toContain(soon.body.id);
    expect(homeIds).not.toContain(later.body.id);
    expect(homeIds).not.toContain(other.body.id);
    expect(
      home.body.data.every(
        (row: { expiresAt: string }) =>
          new Date(row.expiresAt).getTime() <= Date.now() + 30 * 24 * 60 * 60 * 1000,
      ),
    ).toBe(true);
    expect(home.body.meta.page).toBe(1);

    const all = await request(app.getHttpServer())
      .get('/api/v1/documents/expiring')
      .query({ days: 30, search: `drivers/${otherDriverId}/soon.pdf` })
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(all.body.data.map((row: { id: string }) => row.id)).toContain(other.body.id);
  });

  async function createDriver(
    roleId: string,
    branchId: string,
    firstName: string,
    phoneTail: string,
  ) {
    const account = await prisma.user.create({
      data: {
        email: `e2e-docs-driver-${firstName}-${stamp}@example.com`,
        phone: `+1${phoneTail}`,
        roleId,
        branchId,
      },
    });
    userIds.push(account.id);
    const driver = await prisma.driver.create({
      data: {
        userId: account.id,
        branchId,
        firstName,
        lastName: `Docs${tail}`,
        phone: `+1${phoneTail}`,
        status: 'APPROVED',
      },
    });
    driverIds.push(driver.id);
    return driver.id;
  }

  async function createUser(roleName: string, branchId?: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-docs-${roleName}-${stamp}@example.com`,
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

function daysFromNow(days: number) {
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000).toISOString();
}

