import {
  Controller,
  Get,
  HttpStatus,
  Inject,
  ServiceUnavailableException,
} from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import type { Redis } from 'ioredis';
import { AppService } from './app.service.js';
import { ApiCode } from './common/api-code.js';
import { Public } from './common/public.decorator.js';
import { PrismaService } from './prisma/prisma.service.js';
import { REDIS } from './redis/redis.constants.js';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly prisma: PrismaService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  /** Liveness: process is up. Host probes that only care about the PID use this. */
  @Public()
  @SkipThrottle()
  @Get('health')
  health() {
    return { status: 'ok' };
  }

  /**
   * Readiness: can actually serve traffic (DB + Redis).
   * Point Railway/Render health checks here so a Redis blip drains the instance.
   */
  @Public()
  @SkipThrottle()
  @Get('health/ready')
  async ready() {
    const [db, redis] = await Promise.allSettled([
      this.prisma.$queryRaw`SELECT 1`,
      this.redis.ping(),
    ]);
    const ok = db.status === 'fulfilled' && redis.status === 'fulfilled';
    if (!ok) {
      throw new ServiceUnavailableException({
        statusCode: HttpStatus.SERVICE_UNAVAILABLE,
        code: ApiCode.INTERNAL,
        message: 'Not ready',
        db: db.status,
        redis: redis.status,
      });
    }
    return { status: 'ready' };
  }

  /**
   * Test-only slow handler for SIGTERM drain checks (Step 11).
   * Not registered in production.
   */
  @Public()
  @SkipThrottle()
  @Get('health/slow')
  async slow() {
    if (process.env.NODE_ENV === 'production') {
      throw new ServiceUnavailableException('Not available');
    }
    await new Promise((resolve) => setTimeout(resolve, 1500));
    return { status: 'slow-ok' };
  }
}
