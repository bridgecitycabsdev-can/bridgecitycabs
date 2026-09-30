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
const plateA = `A${String(stamp).slice(-8)}`;
const plateB = `B${String(stamp).slice(-8)}`;

describe('vehicles (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  const branchIds: string[] = [];
  const vehicleIds: string[] = [];
  let typeId: string;
  let otherTypeId: string;
  let makeId: string;
  let modelId: string;
  let homeBranchId: string;
  let otherBranchId: string;
  let superToken: string;
  let adminToken: string;
  let passengerToken: string;
  let driverId: string;

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
      data: { name: `E2E Vehicles ${stamp}`, city: 'Lethbridge' },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Vehicles Other ${stamp}`, city: 'Calgary' },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    branchIds.push(home.id, other.id);

    const type = await prisma.vehicleType.create({
      data: { name: `E2E Sedan ${stamp}` },
    });
    const otherType = await prisma.vehicleType.create({
      data: { name: `E2E Van ${stamp}` },
    });
    typeId = type.id;
    otherTypeId = otherType.id;
    const make = await prisma.vehicleMake.create({
      data: { name: `E2E Make ${stamp}` },
    });
    makeId = make.id;
    const model = await prisma.vehicleModel.create({
      data: { makeId, vehicleTypeId: typeId, name: `E2E Model ${stamp}` },
    });
    modelId = model.id;

    superToken = await login(await createUser('super_admin'));
    adminToken = await login(await createUser('branch_admin', homeBranchId));
    passengerToken = await login(await createUser('passenger'));
  });

  afterAll(async () => {
    await prisma.driverVehicleAssignment.deleteMany({
      where: { vehicleId: { in: vehicleIds } },
    });
    await prisma.vehicle.deleteMany({ where: { id: { in: vehicleIds } } });
    if (driverId) {
      await prisma.driver.delete({ where: { id: driverId } }).catch(() => undefined);
    }
    if (modelId) {
      await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    }
    if (makeId) {
      await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    }
    await prisma.vehicleType.deleteMany({
      where: { id: { in: [typeId, otherTypeId].filter(Boolean) } },
    });
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('rejects unauthenticated and non-staff callers', async () => {
    await request(app.getHttpServer()).get('/api/v1/vehicles').expect(401);
    await request(app.getHttpServer())
      .get('/api/v1/vehicles')
      .set('Authorization', `Bearer ${passengerToken}`)
      .expect(403);
  });

  it('derives type from the model and rejects a plate collision in the same branch', async () => {
    const created = await request(app.getHttpServer())
      .post('/api/v1/vehicles')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        branchId: homeBranchId,
        modelId,
        plateNumber: plateA,
        year: 2020,
        unitNumber: '111',
      })
      .expect(201);
    vehicleIds.push(created.body.id);
    expect(created.body.vehicleTypeId).toBe(typeId);
    expect(created.body.branchId).toBe(homeBranchId);

    await request(app.getHttpServer())
      .post('/api/v1/vehicles')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        branchId: homeBranchId,
        modelId,
        vehicleTypeId: otherTypeId,
        plateNumber: `X${plateA}`,
        year: 2021,
      })
      .expect(400);

    const collision = await request(app.getHttpServer())
      .post('/api/v1/vehicles')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        branchId: homeBranchId,
        modelId,
        plateNumber: plateA,
        year: 2020,
      })
      .expect(409);
    expect(collision.body.message).toBe(
      'A vehicle with that plate already exists in this branch',
    );

    const otherBranch = await request(app.getHttpServer())
      .post('/api/v1/vehicles')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        branchId: otherBranchId,
        modelId,
        plateNumber: plateA,
        year: 2019,
      })
      .expect(201);
    vehicleIds.push(otherBranch.body.id);
    expect(otherBranch.body.branchId).toBe(otherBranchId);
  });

  it('scopes reads and writes to the caller branch', async () => {
    const listed = await request(app.getHttpServer())
      .get('/api/v1/vehicles')
      .query({ branchId: otherBranchId, search: plateA })
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(listed.body.data).toHaveLength(1);
    expect(listed.body.data[0].branchId).toBe(homeBranchId);
    expect(listed.body.meta.total).toBe(1);

    const otherId = vehicleIds[1];
    await request(app.getHttpServer())
      .get(`/api/v1/vehicles/${otherId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(404);

    const created = await request(app.getHttpServer())
      .post('/api/v1/vehicles')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        branchId: otherBranchId,
        modelId,
        plateNumber: plateB,
        year: 2022,
      })
      .expect(201);
    vehicleIds.push(created.body.id);
    expect(created.body.branchId).toBe(homeBranchId);
  });

  it('filters unassigned vehicles and ends an open assignment on deactivate', async () => {
    const open = await request(app.getHttpServer())
      .post('/api/v1/vehicles')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        branchId: homeBranchId,
        modelId,
        plateNumber: `C${String(stamp).slice(-8)}`,
        year: 2018,
      })
      .expect(201);
    vehicleIds.push(open.body.id);

    const driverUser = await prisma.user.create({
      data: {
        email: `e2e-vehicle-driver-${stamp}@example.com`,
        passwordHash: await argon2.hash(password),
        roleId: (
          await prisma.role.upsert({
            where: { name: 'driver' },
            update: {},
            create: { name: 'driver' },
          })
        ).id,
        branchId: homeBranchId,
      },
    });
    userIds.push(driverUser.id);
    const driver = await prisma.driver.create({
      data: {
        userId: driverUser.id,
        branchId: homeBranchId,
        firstName: 'E2E',
        lastName: 'Driver',
        phone: `+1403555${String(stamp).slice(-4)}`,
      },
    });
    driverId = driver.id;
    const assignment = await prisma.driverVehicleAssignment.create({
      data: { driverId: driver.id, vehicleId: open.body.id },
    });

    const unassigned = await request(app.getHttpServer())
      .get('/api/v1/vehicles')
      .query({ branchId: homeBranchId, unassigned: 'true' })
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    const unassignedIds = unassigned.body.data.map((row: { id: string }) => row.id);
    expect(unassignedIds).toContain(vehicleIds[0]);
    expect(unassignedIds).not.toContain(open.body.id);

    const byType = await request(app.getHttpServer())
      .get('/api/v1/vehicles')
      .query({ branchId: homeBranchId, typeId, active: true, search: plateB })
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(byType.body.data).toHaveLength(1);
    expect(byType.body.data[0].plateNumber).toBe(plateB);

    const deactivated = await request(app.getHttpServer())
      .post(`/api/v1/vehicles/${open.body.id}/deactivate`)
      .set('Authorization', `Bearer ${superToken}`)
      .expect(200);
    expect(deactivated.body.active).toBe(false);

    const ended = await prisma.driverVehicleAssignment.findUnique({
      where: { id: assignment.id },
    });
    expect(ended?.endedAt).toBeTruthy();
  });

  async function createUser(roleName: string, branchId?: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-vehicles-${roleName}-${stamp}@example.com`,
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
