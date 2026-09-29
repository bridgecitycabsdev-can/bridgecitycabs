import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { AppModule } from './../src/app.module.js';

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

  it('/api/v1/health (GET) is public', () => {
    return request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200)
      .expect((res) => {
        const body = res.body as { status?: string; db?: string };
        if (body.status !== 'ok' || body.db !== 'connected') {
          throw new Error(`unexpected health body: ${JSON.stringify(body)}`);
        }
      });
  });

  afterEach(async () => {
    await app.close();
  });
});
