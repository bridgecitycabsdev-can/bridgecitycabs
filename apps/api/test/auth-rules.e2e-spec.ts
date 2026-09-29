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
const email = `e2e-branch-admin-${stamp}@example.com`;
const unknownEmail = `e2e-missing-${stamp}@example.com`;

async function createApp() {
  const moduleFixture: TestingModule = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();
  const app = moduleFixture.createNestApplication();
  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  await app.init();
  return app;
}

describe('auth and branch rules (e2e)', () => {
  let app: INestApplication<App>;
  let homeBranchId: string;
  let otherBranchId: string;
  let userId: string;

  beforeAll(async () => {
    app = await createApp();
    const role = await prisma.role.upsert({
      where: { name: 'branch_admin' },
      update: {},
      create: { name: 'branch_admin' },
    });
    const home = await prisma.branch.create({
      data: { name: `E2E Home ${stamp}`, city: 'Lethbridge' },
    });
    const other = await prisma.branch.create({
      data: { name: `E2E Other ${stamp}`, city: 'Calgary' },
    });
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash: await argon2.hash(password),
        roleId: role.id,
        branchId: home.id,
      },
    });
    homeBranchId = home.id;
    otherBranchId = other.id;
    userId = user.id;
  });

  afterAll(async () => {
    await prisma.refreshToken.deleteMany({ where: { userId } });
    await prisma.user.delete({ where: { id: userId } }).catch(() => undefined);
    await prisma.branch.deleteMany({
      where: { id: { in: [homeBranchId, otherBranchId] } },
    });
    await prisma.$disconnect();
    await app.close();
  });

  it('returns tokens for the correct password', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password })
      .expect(200);

    expect(typeof response.body.accessToken).toBe('string');
    expect(response.body.accessToken.length).toBeGreaterThan(0);
    expect(typeof response.body.refreshToken).toBe('string');
    expect(response.body.refreshToken.length).toBeGreaterThan(0);
  });

  it('returns the same 401 message for a wrong password and an unknown email', async () => {
    const wrong = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: 'wrong-password' })
      .expect(401);
    const unknown = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email: unknownEmail, password })
      .expect(401);

    expect(wrong.body.message).toBe(unknown.body.message);
    expect(wrong.body.message).toBe('Invalid credentials');
  });

  it('rejects /branches without a token', () => {
    return request(app.getHttpServer()).get('/api/v1/branches').expect(401);
  });

  it("rejects a branch_admin reading another branch", async () => {
    const login = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password })
      .expect(200);

    await request(app.getHttpServer())
      .get(`/api/v1/branches/${otherBranchId}`)
      .set('Authorization', `Bearer ${login.body.accessToken}`)
      .expect(403);
  });

  it('rotates a refresh token and rejects reuse of the old one', async () => {
    const login = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password })
      .expect(200);
    const original = login.body.refreshToken as string;

    const refreshed = await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: original })
      .expect(200);

    expect(refreshed.body.refreshToken).not.toBe(original);
    expect(typeof refreshed.body.accessToken).toBe('string');

    await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: original })
      .expect(401);
  });
});

describe('login throttling (e2e)', () => {
  let app: INestApplication<App>;

  beforeAll(async () => {
    app = await createApp();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns 429 on the sixth rapid login attempt', async () => {
    const statuses: number[] = [];
    for (let attempt = 0; attempt < 6; attempt += 1) {
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ email: unknownEmail, password: 'wrong-password' });
      statuses.push(response.status);
    }

    expect(statuses.slice(0, 5)).toEqual([401, 401, 401, 401, 401]);
    expect(statuses[5]).toBe(429);
  });
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
