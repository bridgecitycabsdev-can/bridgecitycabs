import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types.js';
import { AppModule } from '../src/app.module.js';

/**
 * Step 11: in-flight work must finish when the process is told to stop.
 * Mirrors production `enableShutdownHooks()` + `app.close()` on SIGTERM.
 */
describe('Graceful shutdown (e2e)', () => {
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
    app.enableShutdownHooks();
    await app.init();
  });

  it('drains an in-flight slow request before close completes', async () => {
    const started = Date.now();
    const pending = request(app.getHttpServer())
      .get('/api/v1/health/slow')
      .expect(200);

    // Let the handler enter its sleep, then close (same shape as SIGTERM → app.close()).
    await new Promise((r) => setTimeout(r, 200));
    const closePromise = app.close();
    const res = await pending;
    await closePromise;

    expect(res.body).toEqual({ status: 'slow-ok' });
    expect(Date.now() - started).toBeGreaterThanOrEqual(1400);
  });
});
