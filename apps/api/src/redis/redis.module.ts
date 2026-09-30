import { Global, Inject, Module, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Redis } from 'ioredis';
import { REDIS, REDIS_BULLMQ, REDIS_SUBSCRIBER } from './redis.constants.js';
import { registerLocationCommand } from './update-driver-location.js';

function connect(url: string, maxRetriesPerRequest: number | null) {
  const redis = new Redis(url, { maxRetriesPerRequest });
  redis.on('error', () => undefined);
  const commands = redis as unknown as Record<string, (...args: unknown[]) => unknown>;
  for (const method of ['subscribe', 'psubscribe', 'unsubscribe', 'punsubscribe', 'publish']) {
    const original = commands[method].bind(redis);
    commands[method] = (...args: unknown[]) => {
      const result = original(...args);
      if (result instanceof Promise) {
        return result.catch((error: Error) => {
          if (error?.message === 'Connection is closed.') return 0;
          throw error;
        });
      }
      return result;
    };
  }
  return redis;
}

@Global()
@Module({
  providers: [
    {
      provide: REDIS,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const redis = connect(config.getOrThrow<string>('REDIS_URL'), 2);
        registerLocationCommand(redis);
        return redis;
      },
    },
    {
      provide: REDIS_SUBSCRIBER,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        return connect(config.getOrThrow<string>('REDIS_URL'), 2);
      },
    },
    {
      provide: REDIS_BULLMQ,
      inject: [ConfigService],
      useFactory: (config: ConfigService) =>
        connect(config.getOrThrow<string>('REDIS_URL'), null),
    },
  ],
  exports: [REDIS, REDIS_SUBSCRIBER, REDIS_BULLMQ],
})
export class RedisModule implements OnModuleDestroy {
  constructor(
    @Inject(REDIS) private readonly redis: Redis,
    @Inject(REDIS_SUBSCRIBER) private readonly subscriber: Redis,
    @Inject(REDIS_BULLMQ) private readonly bullmq: Redis,
  ) {}

  async onModuleDestroy() {
    await Promise.all([
      this.redis.quit().catch(() => undefined),
      this.subscriber.quit().catch(() => undefined),
      this.bullmq.quit().catch(() => undefined),
    ]);
  }
}
