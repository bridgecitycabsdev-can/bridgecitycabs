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
const phone = `4032${tail}`;

describe('passengers (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  const passengerIds: string[] = [];
  let homeBranchId: string;
  let otherBranchId: string;
  let adminToken: string;
  let careToken: string;
  let dispatcherToken: string;
  let passengerToken: string;
  let passengerId: string;

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
      where: { name: 'passenger' },
      update: {},
      create: { name: 'passenger' },
    });
    const home = await prisma.branch.create({
      data: { name: `E2E Pax ${stamp}`, city: 'Lethbridge' },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Pax Other ${stamp}`, city: 'Calgary' },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;

    await createUser('branch_admin', homeBranchId);
    adminToken = await login(`e2e-pax-branch_admin-${stamp}@example.com`);
    await createUser('customer_care', otherBranchId);
    careToken = await login(`e2e-pax-customer_care-${stamp}@example.com`);
    await createUser('dispatcher', otherBranchId);
    dispatcherToken = await login(`e2e-pax-dispatcher-${stamp}@example.com`);
    await createUser('passenger');
    passengerToken = await login(`e2e-pax-passenger-${stamp}@example.com`);
  });

  afterAll(async () => {
    await prisma.passenger.deleteMany({ where: { id: { in: passengerIds } } });
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.deleteMany({
      where: { id: { in: [homeBranchId, otherBranchId].filter(Boolean) } },
    });
    await prisma.$disconnect();
    await app.close();
  });

  it('rejects unauthenticated and non-staff callers', async () => {
    await request(app.getHttpServer()).get('/api/v1/passengers').expect(401);
    await request(app.getHttpServer())
      .get('/api/v1/passengers')
      .set('Authorization', `Bearer ${passengerToken}`)
      .expect(403);
  });

  it('creates a passwordless passenger visible to every branch', async () => {
    const created = await request(app.getHttpServer())
      .post('/api/v1/passengers')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        firstName: 'Ada',
        lastName: `Rider${tail}`,
        phone,
        email: `Ada.Rider.${stamp}@Example.com`,
      })
      .expect(201);
    passengerId = created.body.id;
    passengerIds.push(passengerId);
    userIds.push(created.body.user.id);
    expect(created.body.phone).toBe(`+1${phone}`);
    expect(created.body.email).toBe(`ada.rider.${stamp}@example.com`);
    expect(created.body.blocked).toBe(false);
    expect(created.body.user.passwordHash).toBeUndefined();

    const account = await prisma.user.findUnique({
      where: { id: created.body.user.id },
      include: { role: true },
    });
    expect(account?.passwordHash).toBeNull();
    expect(account?.branchId).toBeNull();
    expect(account?.role.name).toBe('passenger');

    await request(app.getHttpServer())
      .post('/api/v1/passengers')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        firstName: 'Ada',
        lastName: 'Duplicate',
        phone: `(403) 2${tail}`,
      })
      .expect(409);

    const listed = await request(app.getHttpServer())
      .get('/api/v1/passengers')
      .query({ search: `Ada Rider${tail}` })
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .expect(200);
    expect(listed.body.data.map((row: { id: string }) => row.id)).toContain(passengerId);
    expect(listed.body.meta.total).toBeGreaterThan(0);

    const byPhone = await request(app.getHttpServer())
      .get('/api/v1/passengers')
      .query({ search: `+1${phone}` })
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .expect(200);
    expect(byPhone.body.data.map((row: { id: string }) => row.id)).toContain(passengerId);

    const renamed = await request(app.getHttpServer())
      .patch(`/api/v1/passengers/${passengerId}`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send({ firstName: 'Augusta' })
      .expect(200);
    expect(renamed.body.firstName).toBe('Augusta');
  });

  it('blocks and unblocks with a reason for the allowed roles', async () => {
    await request(app.getHttpServer())
      .post(`/api/v1/passengers/${passengerId}/block`)
      .set('Authorization', `Bearer ${dispatcherToken}`)
      .send({ reason: 'No-show on three bookings' })
      .expect(403);

    const blocked = await request(app.getHttpServer())
      .post(`/api/v1/passengers/${passengerId}/block`)
      .set('Authorization', `Bearer ${careToken}`)
      .send({ reason: 'No-show on three bookings' })
      .expect(200);
    expect(blocked.body.blocked).toBe(true);
    expect(blocked.body.blockReason).toBe('No-show on three bookings');
    expect(blocked.body.blockedAt).toBeTruthy();

    await request(app.getHttpServer())
      .post(`/api/v1/passengers/${passengerId}/block`)
      .set('Authorization', `Bearer ${careToken}`)
      .send({ reason: 'Already blocked' })
      .expect(409);

    const unblocked = await request(app.getHttpServer())
      .post(`/api/v1/passengers/${passengerId}/unblock`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ reason: 'Paid the outstanding fare' })
      .expect(200);
    expect(unblocked.body.blocked).toBe(false);
    expect(unblocked.body.unblockReason).toBe('Paid the outstanding fare');
    expect(unblocked.body.blockReason).toBe('No-show on three bookings');
    expect(unblocked.body.blockedAt).toBeNull();

    await request(app.getHttpServer())
      .post(`/api/v1/passengers/${passengerId}/unblock`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ reason: 'Already open' })
      .expect(409);
  });

  async function createUser(roleName: string, branchId?: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-pax-${roleName}-${stamp}@example.com`,
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
