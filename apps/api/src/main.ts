import { RequestMethod } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import cookieParser from 'cookie-parser';
import express from 'express';
import helmet from 'helmet';
import { Logger } from 'nestjs-pino';
import { AppModule } from './app.module.js';
import { assertOtpDevCode } from './config/otp-env.js';
import { assertFakePaymentsEnv } from './payments/fake-payments-env.js';
import { apiValidationPipe } from './common/validation-pipe.js';
import { correlationMiddleware } from './observability/logger.config.js';
import { initSentry } from './observability/sentry.js';
import { allowedWsOrigins } from './realtime/allowed-origins.js';
import { RedisIoAdapter } from './realtime/redis-io.adapter.js';
import { REDIS, REDIS_SUBSCRIBER } from './redis/redis.constants.js';

initSentry();

async function bootstrap() {
  console.log('[Boot] Step 1: creating Nest app...');
  // Disable Nest's default parser so the Stripe webhook can receive a raw body
  // for signature verification; JSON parsing is re-enabled for every other route.
  const app = await NestFactory.create(AppModule, {
    bodyParser: false,
    bufferLogs: true,
  });
  console.log('[Boot] Step 2: app created, setting up middleware...');
  app.useLogger(app.get(Logger));
  app.use(helmet());
  app.use(correlationMiddleware);
  app.use(
    '/api/v1/webhooks/stripe',
    // No per-IP Nest throttle on this route (SkipThrottle); size cap is the DoS control.
    // Separate from the global JSON limit below — Stripe events can be larger.
    express.raw({ type: 'application/json', limit: '1mb' }),
  );
  // Global API bodies stay small (fare quotes, status patches). Uploads use signed URLs, not this parser.
  app.use(express.json({ limit: '512kb' }));
  app.use(express.urlencoded({ extended: true, limit: '512kb' }));

  app.useWebSocketAdapter(
    new RedisIoAdapter(
      app.getHttpServer(),
      app.get(REDIS),
      app.get(REDIS_SUBSCRIBER),
      app.get(ConfigService),
    ),
  );
  assertOtpDevCode();
  assertFakePaymentsEnv();
  app.use(cookieParser());
  app.enableCors({
    origin: allowedWsOrigins(process.env.WS_ALLOWED_ORIGINS),
    credentials: true,
  });
  app.setGlobalPrefix('api/v1', {
    exclude: [
      { path: 'docs', method: RequestMethod.ALL },
      { path: 'docs-json', method: RequestMethod.ALL },
      { path: 'docs/{*path}', method: RequestMethod.ALL },
      { path: 'admin/queues', method: RequestMethod.ALL },
      { path: 'admin/queues/{*path}', method: RequestMethod.ALL },
    ],
  });
  app.useGlobalPipes(apiValidationPipe());
  if (process.env.NODE_ENV !== 'production') {
    const doc = SwaggerModule.createDocument(
      app,
      new DocumentBuilder().setTitle('BridgeCabs API').addBearerAuth().build(),
    );
    doc.security = [{ bearer: [] }];
    SwaggerModule.setup('docs', app, doc, { useGlobalPrefix: false });
  }

  // Drain in-flight HTTP work and close Prisma/Redis on deploy SIGTERM
  // (without this, Railway/Render can kill mid-request → half-written bookings).
  app.enableShutdownHooks();
  let shuttingDown = false;
  const onSignal = async (signal: string) => {
    if (shuttingDown) return;
    shuttingDown = true;
    app.get(Logger).log(`${signal}: closing Nest application`);
    await app.close();
    process.exit(0);
  };
  process.on('SIGTERM', () => {
    void onSignal('SIGTERM');
  });
  process.on('SIGINT', () => {
    void onSignal('SIGINT');
  });

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`[BridgeCabs API] Ready and listening on http://localhost:${port}`);
}
await bootstrap();

