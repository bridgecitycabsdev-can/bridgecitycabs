import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module.js';
import { assertOtpDevCode } from './config/otp-env.js';
import { RedisIoAdapter } from './realtime/redis-io.adapter.js';
import { REDIS, REDIS_SUBSCRIBER } from './redis/redis.constants.js';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useWebSocketAdapter(
    new RedisIoAdapter(
      app.getHttpServer(),
      app.get(REDIS),
      app.get(REDIS_SUBSCRIBER),
      app.get(ConfigService),
    ),
  );
  assertOtpDevCode();
  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  await app.listen(process.env.PORT ?? 3000);
}
await bootstrap();
