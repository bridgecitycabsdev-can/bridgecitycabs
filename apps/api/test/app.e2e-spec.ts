import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { afterEach, beforeEach, describe, it, vi } from 'vitest';
import { AppModule } from './../src/app.module.js';
import { REDIS } from './../src/redis/redis.constants.js';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
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
  });

  it('/api/v1 (GET) requires auth', () => {
    return request(app.getHttpServer()).get('/api/v1').expect(401);
  });

  it('/api/v1/health (GET) is public liveness', () => {
    return request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200)
      .expect((res) => {
        const body = res.body as { status?: string };
        if (body.status !== 'ok') {
          throw new Error(`unexpected health body: ${JSON.stringify(body)}`);
        }
      });
  });

  it('/api/v1/health/ready (GET) checks db and redis', () => {
    return request(app.getHttpServer())
      .get('/api/v1/health/ready')
      .expect(200)
      .expect((res) => {
        const body = res.body as { status?: string };
        if (body.status !== 'ready') {
          throw new Error(`unexpected ready body: ${JSON.stringify(body)}`);
        }
      });
  });

  it('/api/v1/health stays 200 when redis ping fails; ready returns 503', async () => {
    const redis = app.get(REDIS);
    const ping = vi.spyOn(redis, 'ping').mockRejectedValue(new Error('down'));

    await request(app.getHttpServer()).get('/api/v1/health').expect(200);
    await request(app.getHttpServer()).get('/api/v1/health/ready').expect(503);

    ping.mockRestore();
    await request(app.getHttpServer()).get('/api/v1/health/ready').expect(200);
  });

  afterEach(async () => {
    await app.close();
  });
});
