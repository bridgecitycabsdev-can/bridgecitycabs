import { resolve } from 'node:path';
import { loadEnvFile } from './load-env-file.js';
import {
  BadRequestException,
  Controller,
  HttpCode,
  HttpStatus,
  INestApplication,
  Post,
  Body,
  ValidationPipe,
} from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import argon2 from 'argon2';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { AppModule } from '../src/app.module.js';
import { Idempotent } from '../src/idempotency/idempotency.decorator.js';
import {
  IDEMPOTENCY_IN_PROGRESS,
  IDEMPOTENCY_REUSED,
} from '../src/idempotency/idempotency.service.js';

loadEnvFile();

const prisma = new PrismaClient();
const password = 'correct-password';
const stamp = Date.now();

let handled = 0;
let slowEntered = 0;
let flakyAttempts = 0;
let releaseSlow = () => undefined as void;
let slowGate: Promise<void> = Promise.resolve();

function armSlow() {
  slowEntered = 0;
  slowGate = new Promise((resolve) => {
    releaseSlow = resolve;
  });
}

@Controller('idempotency-probe')
class IdempotencyProbeController {
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @Idempotent()
  create(@Body() body: { n: number }) {
    handled += 1;
    return { n: body.n, handled };
  }

  @Post('open')
  @HttpCode(HttpStatus.CREATED)
  open() {
    return { ok: true };
  }

  @Post('slow')
  @HttpCode(HttpStatus.CREATED)
  @Idempotent()
  async slow(@Body() body: { n: number }) {
    slowEntered += 1;
    await slowGate;
    return { n: body.n };
  }

  @Post('flaky')
  @HttpCode(HttpStatus.CREATED)
  @Idempotent()
  flaky() {
    flakyAttempts += 1;
    if (flakyAttempts === 1) throw new BadRequestException('transient');
    return { ok: true, attempts: flakyAttempts };
  }
}

describe('idempotency (e2e)', () => {
  let app: INestApplication<App>;
  const userIds: string[] = [];
  let token: string;
  let otherToken: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
      controllers: [IdempotencyProbeController],
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
    token = await login(await createUser('dispatcher', 'idem'));
    otherToken = await login(await createUser('dispatcher', 'idem2'));
  });

  afterAll(async () => {
    releaseSlow();
    await prisma.idempotencyKey.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.$disconnect();
    await app.close();
  });

  it('requires the header only on idempotent routes', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe')
      .set('Authorization', `Bearer ${token}`)
      .send({ n: 1 })
      .expect(400);

    await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe/open')
      .set('Authorization', `Bearer ${token}`)
      .send({ n: 1 })
      .expect(201);
  });

  it('replays the stored response and rejects a reused key with a different body', async () => {
    handled = 0;
    const key = `quote-${stamp}`;
    const created = await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe')
      .set('Authorization', `Bearer ${token}`)
      .set('Idempotency-Key', key)
      .send({ n: 7 })
      .expect(201);
    expect(created.body).toEqual({ n: 7, handled: 1 });

    const replay = await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe')
      .set('Authorization', `Bearer ${token}`)
      .set('Idempotency-Key', key)
      .send({ n: 7 })
      .expect(201);
    expect(replay.body).toEqual(created.body);
    expect(handled).toBe(1);

    const reused = await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe')
      .set('Authorization', `Bearer ${token}`)
      .set('Idempotency-Key', key)
      .send({ n: 8 })
      .expect(422);
    expect(reused.body.message).toBe(IDEMPOTENCY_REUSED);

    const otherUser = await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe')
      .set('Authorization', `Bearer ${otherToken}`)
      .set('Idempotency-Key', key)
      .send({ n: 7 })
      .expect(201);
    expect(otherUser.body.handled).toBe(2);
  });

  it('returns 409 while the same request is still running, then replays', async () => {
    armSlow();
    const key = `race-${stamp}`;
    const first = request(app.getHttpServer())
      .post('/api/v1/idempotency-probe/slow')
      .set('Authorization', `Bearer ${token}`)
      .set('Idempotency-Key', key)
      .send({ n: 1 });
    const completion = first.then((response) => response);
    await waitFor(() => slowEntered === 1);

    const second = await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe/slow')
      .set('Authorization', `Bearer ${token}`)
      .set('Idempotency-Key', key)
      .send({ n: 1 });
    expect(second.status).toBe(409);
    expect(second.body.message).toBe(IDEMPOTENCY_IN_PROGRESS);

    releaseSlow();
    const created = await completion;
    expect(created.status).toBe(201);
    const replay = await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe/slow')
      .set('Authorization', `Bearer ${token}`)
      .set('Idempotency-Key', key)
      .send({ n: 1 })
      .expect(201);
    expect(replay.body).toEqual(created.body);
    expect(slowEntered).toBe(1);
  });

  it('drops the claim when the handler fails so the same key can succeed', async () => {
    flakyAttempts = 0;
    const key = `flaky-${stamp}`;
    await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe/flaky')
      .set('Authorization', `Bearer ${token}`)
      .set('Idempotency-Key', key)
      .send({ n: 1 })
      .expect(400);

    const recovered = await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe/flaky')
      .set('Authorization', `Bearer ${token}`)
      .set('Idempotency-Key', key)
      .send({ n: 1 })
      .expect(201);
    expect(recovered.body).toEqual({ ok: true, attempts: 2 });

    const replay = await request(app.getHttpServer())
      .post('/api/v1/idempotency-probe/flaky')
      .set('Authorization', `Bearer ${token}`)
      .set('Idempotency-Key', key)
      .send({ n: 1 })
      .expect(201);
    expect(replay.body).toEqual(recovered.body);
    expect(flakyAttempts).toBe(2);
  });

  async function createUser(roleName: string, label: string) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-${label}-${stamp}@example.com`,
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

async function waitFor(predicate: () => boolean) {
  const start = Date.now();
  while (!predicate()) {
    if (Date.now() - start > 2000) throw new Error('timed out waiting for the handler');
    await new Promise((resolve) => setTimeout(resolve, 15));
  }
}

