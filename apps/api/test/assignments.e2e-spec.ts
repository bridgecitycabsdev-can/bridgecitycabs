import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { Prisma, PrismaClient } from '@prisma/client';
import argon2 from 'argon2';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { AppModule } from '../src/app.module.js';

loadEnvFile();

const prisma = new PrismaClient();
const password = 'correct-password';
const stamp = Date.now();
const tail = String(stamp).slice(-6);

describe('assignments (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  const driverIds: string[] = [];
  const vehicleIds: string[] = [];
  const branchIds: string[] = [];
  let homeBranchId: string;
  let otherBranchId: string;
  let adminToken: string;
  let superToken: string;
  let passengerToken: string;
  let adaId: string;
  let graceId: string;
  let pendingId: string;
  let vehicleAId: string;
  let vehicleBId: string;
  let inactiveVehicleId: string;
  let otherVehicleId: string;

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
      data: { name: `E2E Assign ${stamp}`, city: 'Lethbridge' },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Assign Other ${stamp}`, city: 'Calgary' },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    branchIds.push(home.id, other.id);

    const vehicleType = await prisma.vehicleType.create({
      data: { name: `E2E Assign Type ${stamp}` },
    });
    const make = await prisma.vehicleMake.create({
      data: { name: `E2E Assign Make ${stamp}` },
    });
    const model = await prisma.vehicleModel.create({
      data: {
        makeId: make.id,
        vehicleTypeId: vehicleType.id,
        name: `E2E Assign Model ${stamp}`,
      },
    });
    vehicleAId = await createVehicle(homeBranchId, model.id, vehicleType.id, `A${tail}`, true);
    vehicleBId = await createVehicle(homeBranchId, model.id, vehicleType.id, `B${tail}`, true);
    inactiveVehicleId = await createVehicle(
      homeBranchId,
      model.id,
      vehicleType.id,
      `I${tail}`,
      false,
    );
    otherVehicleId = await createVehicle(
      otherBranchId,
      model.id,
      vehicleType.id,
      `O${tail}`,
      true,
    );

    const driverRole = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    adaId = await createDriver(driverRole.id, homeBranchId, 'Ada', 'APPROVED', `4032${tail}`);
    graceId = await createDriver(driverRole.id, homeBranchId, 'Grace', 'APPROVED', `4033${tail}`);
    pendingId = await createDriver(
      driverRole.id,
      homeBranchId,
      'Pending',
      'PENDING_DOCUMENTS',
      `4034${tail}`,
    );
    await createDriver(driverRole.id, otherBranchId, 'Other', 'APPROVED', `4035${tail}`);

    await createUser('branch_admin', homeBranchId);
    adminToken = await login(`e2e-assign-branch_admin-${stamp}@example.com`);
    await createUser('super_admin');
    superToken = await login(`e2e-assign-super_admin-${stamp}@example.com`);
    await createUser('passenger');
    passengerToken = await login(`e2e-assign-passenger-${stamp}@example.com`);
  });

  afterAll(async () => {
    await prisma.driverVehicleAssignment.deleteMany({
      where: { driverId: { in: driverIds } },
    });
    await prisma.driver.deleteMany({ where: { id: { in: driverIds } } });
    await prisma.vehicle.deleteMany({ where: { id: { in: vehicleIds } } });
    await prisma.vehicleModel.deleteMany({
      where: { name: `E2E Assign Model ${stamp}` },
    });
    await prisma.vehicleMake.deleteMany({
      where: { name: `E2E Assign Make ${stamp}` },
    });
    await prisma.vehicleType.deleteMany({
      where: { name: `E2E Assign Type ${stamp}` },
    });
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({ where: { id: { in: branchIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('rejects unauthenticated and non-staff callers', async () => {
    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${adaId}/assign-vehicle`)
      .send({ vehicleId: vehicleAId })
      .expect(401);
    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${adaId}/assign-vehicle`)
      .set('Authorization', `Bearer ${passengerToken}`)
      .send({ vehicleId: vehicleAId })
      .expect(403);
  });

  it('rejects drivers who are not approved, inactive vehicles, and cross-branch pairs', async () => {
    const pending = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${pendingId}/assign-vehicle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ vehicleId: vehicleAId })
      .expect(422);
    expect(pending.body.message).toBe('Only approved drivers can be assigned');

    const inactive = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${adaId}/assign-vehicle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ vehicleId: inactiveVehicleId })
      .expect(400);
    expect(inactive.body.message).toBe('Vehicle is not active');

    const otherBranch = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${adaId}/assign-vehicle`)
      .set('Authorization', `Bearer ${superToken}`)
      .send({ vehicleId: otherVehicleId })
      .expect(400);
    expect(otherBranch.body.message).toBe(
      'Driver and vehicle must belong to the same branch',
    );

    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${adaId}/assign-vehicle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ vehicleId: otherVehicleId })
      .expect(404);
  });

  it('closes the previous assignment and reassigns a taken vehicle only when asked', async () => {
    const first = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${adaId}/assign-vehicle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ vehicleId: vehicleAId })
      .expect(201);
    expect(first.body.endedAt).toBeNull();
    expect(first.body.vehicleId).toBe(vehicleAId);

    const moved = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${adaId}/assign-vehicle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ vehicleId: vehicleBId })
      .expect(201);
    expect(moved.body.vehicleId).toBe(vehicleBId);
    const closed = await prisma.driverVehicleAssignment.findUnique({
      where: { id: first.body.id },
    });
    expect(closed?.endedAt).toBeTruthy();

    const blocked = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${graceId}/assign-vehicle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ vehicleId: vehicleBId })
      .expect(409);
    expect(blocked.body.message).toBe(
      'Vehicle is already assigned to another driver',
    );

    const reassigned = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${graceId}/assign-vehicle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ vehicleId: vehicleBId, reassign: true })
      .expect(201);
    expect(reassigned.body.driverId).toBe(graceId);
    const adaClosed = await prisma.driverVehicleAssignment.findUnique({
      where: { id: moved.body.id },
    });
    expect(adaClosed?.endedAt).toBeTruthy();

    const unassigned = await request(app.getHttpServer())
      .post(`/api/v1/drivers/${graceId}/unassign-vehicle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(unassigned.body.endedAt).toBeTruthy();

    await request(app.getHttpServer())
      .post(`/api/v1/drivers/${graceId}/unassign-vehicle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(404);
  });

  it('keeps one open assignment per driver and per vehicle in the database', async () => {
    const indexes = await prisma.$queryRaw<Array<{ indexname: string }>>`
      SELECT indexname FROM pg_indexes
      WHERE indexname IN (
        'one_open_assignment_per_vehicle',
        'one_open_assignment_per_driver'
      )
    `;
    expect(indexes.map((row) => row.indexname).sort()).toEqual([
      'one_open_assignment_per_driver',
      'one_open_assignment_per_vehicle',
    ]);

    await prisma.driverVehicleAssignment.create({
      data: { driverId: adaId, vehicleId: vehicleAId },
    });
    await expect(
      prisma.driverVehicleAssignment.create({
        data: { driverId: adaId, vehicleId: vehicleBId },
      }),
    ).rejects.toBeInstanceOf(Prisma.PrismaClientKnownRequestError);
    await expect(
      prisma.driverVehicleAssignment.create({
        data: { driverId: graceId, vehicleId: vehicleAId },
      }),
    ).rejects.toBeInstanceOf(Prisma.PrismaClientKnownRequestError);
  });

  async function createVehicle(
    branchId: string,
    modelId: string,
    vehicleTypeId: string,
    plateNumber: string,
    active: boolean,
  ) {
    const vehicle = await prisma.vehicle.create({
      data: { branchId, modelId, vehicleTypeId, plateNumber, year: 2020, active },
    });
    vehicleIds.push(vehicle.id);
    return vehicle.id;
  }

  async function createDriver(
    roleId: string,
    branchId: string,
    firstName: string,
    status: 'APPROVED' | 'PENDING_DOCUMENTS',
    phoneTail: string,
  ) {
    const account = await prisma.user.create({
      data: {
        email: `e2e-assign-driver-${firstName}-${stamp}@example.com`,
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
        lastName: `Assign${tail}`,
        phone: `+1${phoneTail}`,
        status,
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
        email: `e2e-assign-${roleName}-${stamp}@example.com`,
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
