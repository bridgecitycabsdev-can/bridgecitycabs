import { randomInt } from 'node:crypto';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import { Redis } from 'ioredis';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { AppModule } from '../src/app.module.js';
import { otpDailyPhoneKey, otpKey } from '../src/redis/redis.keys.js';
import { flushRedisPrefix } from './flush-redis-guards.js';

const prisma = new PrismaClient();
const stamp = Date.now();

describe('phone OTP (e2e)', () => {
  let app: INestApplication<App>;
  let redis: Redis;
  let branchId: string;
  const userIds: string[] = [];
  let driverPhone: string;
  let staffPhone: string;

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
    redis = new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379', {
      maxRetriesPerRequest: 2,
    });

    const driverRole = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    const staffRole = await prisma.role.upsert({
      where: { name: 'branch_admin' },
      update: {},
      create: { name: 'branch_admin' },
    });
    await prisma.role.upsert({
      where: { name: 'passenger' },
      update: {},
      create: { name: 'passenger' },
    });
    const branch = await prisma.branch.create({
      data: { name: `OTP ${stamp}`, city: 'Lethbridge' },
    });
    branchId = branch.id;
    driverPhone = nextPhone();
    staffPhone = nextPhone();
    const driverUser = await prisma.user.create({
      data: {
        phone: driverPhone,
        roleId: driverRole.id,
        branchId,
        driver: {
          create: {
            branchId,
            firstName: 'Priya',
            lastName: 'Shah',
            phone: driverPhone,
            status: 'APPROVED',
          },
        },
      },
    });
    const staffUser = await prisma.user.create({
      data: {
        phone: staffPhone,
        roleId: staffRole.id,
        branchId,
      },
    });
    userIds.push(driverUser.id, staffUser.id);
  });

  beforeEach(async () => {
    await flushRedisPrefix('otp:');
  });

  afterAll(async () => {
    await flushRedisPrefix('otp:');
    await prisma.refreshToken.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.passenger.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.driver.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await prisma.branch.delete({ where: { id: branchId } }).catch(() => undefined);
    await prisma.$disconnect();
    await redis.quit();
    await app.close();
  });

  it('returns the same 202 for a driver, a new passenger, and a staff phone', async () => {
    const fresh = nextPhone();
    const driver = await requestOtp(driverPhone);
    const unknown = await requestOtp(fresh);
    const staff = await requestOtp(staffPhone);

    expect(driver.status).toBe(202);
    expect(driver.body).toEqual({ accepted: true });
    expect(unknown.body).toEqual(driver.body);
    expect(staff.body).toEqual(driver.body);
    expect(await redis.exists(otpKey(driverPhone))).toBe(1);
    expect(await redis.exists(otpKey(fresh))).toBe(1);
    expect(await redis.exists(otpKey(staffPhone))).toBe(0);
    const stored = await redis.hget(otpKey(driverPhone), 'hash');
    expect(stored).not.toBe('000000');
    expect(stored).toHaveLength(64);
  });

  it('waits 60 seconds before sending another code and caps a phone for the day', async () => {
    const phone = nextPhone();
    await requestOtp(phone).expect(202);
    const again = await requestOtp(phone).expect(429);
    expect(again.body.message).toMatch(/60 seconds/);

    const capped = nextPhone();
    await redis.set(otpDailyPhoneKey(capped), '10');
    const limited = await requestOtp(capped).expect(429);
    expect(limited.body.message).toMatch(/Try again tomorrow/);
  });

  it('logs a driver in once, then rejects the used code', async () => {
    await requestOtp(driverPhone).expect(202);
    const verified = await verify(driverPhone, '000000').expect(200);
    expect(typeof verified.body.accessToken).toBe('string');
    expect(typeof verified.body.refreshToken).toBe('string');

    const me = await request(app.getHttpServer())
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${verified.body.accessToken}`)
      .expect(200);
    expect(me.body.role.name).toBe('driver');
    expect(me.body.branch.id).toBe(branchId);
    expect(await redis.exists(otpKey(driverPhone))).toBe(0);

    await verify(driverPhone, '000000').expect(401);
  });

  it('locks the code after five wrong attempts', async () => {
    const phone = nextPhone();
    const user = await prisma.user.create({
      data: {
        phone,
        roleId: (await prisma.role.findUniqueOrThrow({ where: { name: 'passenger' } })).id,
        passenger: {
          create: { firstName: 'Amira', phone },
        },
      },
    });
    userIds.push(user.id);
    await requestOtp(phone).expect(202);
    for (let attempt = 0; attempt < 5; attempt += 1) {
      await verify(phone, '111111').expect(401);
    }
    await verify(phone, '000000').expect(401);
  });

  it('creates a passenger with a placeholder name on first verify', async () => {
    const phone = nextPhone();
    await requestOtp(phone).expect(202);
    const verified = await verify(phone, '000000').expect(200);
    const passenger = await prisma.passenger.findFirstOrThrow({
      where: { phone },
      include: { user: { include: { role: true } } },
    });
    userIds.push(passenger.userId);
    expect(passenger.firstName).toBe('Passenger');
    expect(passenger.user.role.name).toBe('passenger');
    expect(passenger.user.branchId).toBeNull();

    const me = await request(app.getHttpServer())
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${verified.body.accessToken}`)
      .expect(200);
    expect(me.body.role.name).toBe('passenger');
    expect(me.body.branch).toBeNull();
  });

  function requestOtp(phone: string) {
    return request(app.getHttpServer()).post('/api/v1/auth/otp/request').send({ phone });
  }

  function verify(phone: string, code: string) {
    return request(app.getHttpServer()).post('/api/v1/auth/otp/verify').send({ phone, code });
  }
});

function nextPhone() {
  return `+1403${randomInt(2000000, 9999999)}`;
}
