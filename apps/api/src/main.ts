import { RequestMethod } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import cookieParser from 'cookie-parser';
import express from 'express';
import { AppModule } from './app.module.js';
import { assertOtpDevCode } from './config/otp-env.js';
import { assertFakePaymentsEnv } from './payments/fake-payments-env.js';
import { apiValidationPipe } from './common/validation-pipe.js';
import { allowedWsOrigins } from './realtime/allowed-origins.js';
import { RedisIoAdapter } from './realtime/redis-io.adapter.js';
import { REDIS, REDIS_SUBSCRIBER } from './redis/redis.constants.js';

async function bootstrap() {
  // Disable Nest's default parser so the Stripe webhook can receive a raw body
  // for signature verification; JSON parsing is re-enabled for every other route.
  const app = await NestFactory.create(AppModule, { bodyParser: false });
  app.use(
    '/api/v1/webhooks/stripe',
    express.raw({ type: 'application/json' }),
  );
  app.use(express.json({ limit: '2mb' }));
  app.use(express.urlencoded({ extended: true }));

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
  await app.listen(process.env.PORT ?? 3000);
}
await bootstrap();
