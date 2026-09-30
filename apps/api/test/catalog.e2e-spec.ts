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

describe('catalog (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  let typeId: string;
  let makeId: string;
  let modelId: string;
  let superToken: string;
  let staffToken: string;
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

    superToken = await login(await createUser('super_admin'));
    staffToken = await login(await createUser('dispatcher'));
    passengerToken = await login(await createUser('passenger'));
  });

  afterAll(async () => {
    if (modelId) {
      await prisma.vehicleModel.delete({ where: { id: modelId } }).catch(() => undefined);
    }
    if (makeId) {
      await prisma.vehicleMake.delete({ where: { id: makeId } }).catch(() => undefined);
    }
    if (typeId) {
      await prisma.vehicleType.delete({ where: { id: typeId } }).catch(() => undefined);
    }
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('rejects catalog reads without a token', () => {
    return request(app.getHttpServer()).get('/api/v1/vehicle-types').expect(401);
  });

  it('rejects a passenger and allows staff to read', async () => {
    await request(app.getHttpServer())
      .get('/api/v1/vehicle-makes')
      .set('Authorization', `Bearer ${passengerToken}`)
      .expect(403);

    const response = await request(app.getHttpServer())
      .get('/api/v1/vehicle-types')
      .set('Authorization', `Bearer ${staffToken}`)
      .expect(200);

    expect(response.body.meta).toMatchObject({ page: 1, pageSize: 20 });
    expect(Array.isArray(response.body.data)).toBe(true);
  });

  it('lets only a super admin create and update catalog rows', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/vehicle-types')
      .set('Authorization', `Bearer ${staffToken}`)
      .send({ name: `E2E Type ${stamp}` })
      .expect(403);

    const type = await request(app.getHttpServer())
      .post('/api/v1/vehicle-types')
      .set('Authorization', `Bearer ${superToken}`)
      .send({ name: `E2E Type ${stamp}` })
      .expect(201);
    typeId = type.body.id;

    const make = await request(app.getHttpServer())
      .post('/api/v1/vehicle-makes')
      .set('Authorization', `Bearer ${superToken}`)
      .send({ name: `E2E Make ${stamp}` })
      .expect(201);
    makeId = make.body.id;

    const model = await request(app.getHttpServer())
      .post('/api/v1/vehicle-models')
      .set('Authorization', `Bearer ${superToken}`)
      .send({
        makeId,
        vehicleTypeId: typeId,
        name: `E2E Model ${stamp}`,
        bodyType: 'sedan',
      })
      .expect(201);
    modelId = model.body.id;

    await request(app.getHttpServer())
      .post('/api/v1/vehicle-types')
      .set('Authorization', `Bearer ${superToken}`)
      .send({ name: `E2E Type ${stamp}` })
      .expect(409);

    const renamed = await request(app.getHttpServer())
      .patch(`/api/v1/vehicle-types/${typeId}`)
      .set('Authorization', `Bearer ${superToken}`)
      .send({ name: `E2E Type Renamed ${stamp}` })
      .expect(200);
    expect(renamed.body.name).toBe(`E2E Type Renamed ${stamp}`);

    const models = await request(app.getHttpServer())
      .get(`/api/v1/vehicle-makes/${makeId}/models`)
      .query({ search: `E2E Model ${stamp}`, pageSize: 1 })
      .set('Authorization', `Bearer ${staffToken}`)
      .expect(200);

    expect(models.body.data).toHaveLength(1);
    expect(models.body.data[0].id).toBe(modelId);
    expect(models.body.data[0].vehicleType.id).toBe(typeId);
    expect(models.body.meta).toMatchObject({
      page: 1,
      pageSize: 1,
      total: 1,
      totalPages: 1,
    });
  });

  async function createUser(roleName: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-catalog-${roleName}-${stamp}@example.com`,
        passwordHash: await argon2.hash(password),
        roleId: role.id,
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
