import { Inject, Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Redis } from 'ioredis';
import { REDIS } from '../redis/redis.constants.js';
import { socketConnKey, socketRateKey } from '../redis/redis.keys.js';

const CLAIM_CONNECTION = `
redis.call('ZREMRANGEBYSCORE', KEYS[1], '-inf', ARGV[2])
redis.call('ZADD', KEYS[1], ARGV[3], ARGV[1])
local count = redis.call('ZCARD', KEYS[1])
if count > tonumber(ARGV[4]) then
  redis.call('ZREM', KEYS[1], ARGV[1])
  return 0
end
redis.call('PEXPIRE', KEYS[1], ARGV[5])
return 1
`;

const TAKE_EVENT = `
local count = redis.call('INCR', KEYS[1])
if count == 1 then
  redis.call('EXPIRE', KEYS[1], ARGV[2])
end
if count > tonumber(ARGV[1]) then
  return 0
end
return 1
`;

@Injectable()
export class SocketLimits implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(SocketLimits.name);
  private readonly local = new Map<string, string>();
  private timer?: ReturnType<typeof setInterval>;

  constructor(
    private readonly config: ConfigService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  onModuleInit() {
    this.timer = setInterval(() => void this.refresh(), 20_000);
    this.timer.unref?.();
  }

  onModuleDestroy() {
    if (this.timer) clearInterval(this.timer);
  }

  async claim(userId: string, socketId: string) {
    const ttlMs = this.connTtlMs();
    const now = Date.now();
    try {
      const allowed = await this.redis.eval(
        CLAIM_CONNECTION,
        1,
        socketConnKey(userId),
        socketId,
        String(now),
        String(now + ttlMs),
        String(this.maxConnections()),
        String(ttlMs),
      );
      if (Number(allowed) !== 1) return false;
      this.local.set(socketId, userId);
      return true;
    } catch {
      this.logger.warn('socket connection cap unavailable');
      return false;
    }
  }

  async release(userId: string, socketId: string) {
    this.local.delete(socketId);
    try {
      await this.redis.zrem(socketConnKey(userId), socketId);
    } catch {
      this.logger.warn('socket connection release unavailable');
    }
  }

  async allowEvent(userId: string) {
    try {
      const allowed = await this.redis.eval(
        TAKE_EVENT,
        1,
        socketRateKey(userId),
        String(this.eventLimit()),
        String(this.eventWindowSeconds()),
      );
      return Number(allowed) === 1;
    } catch {
      this.logger.warn('socket rate limit unavailable');
      return false;
    }
  }

  maxConnections() {
    return positiveInt(this.config.get('SOCKET_MAX_CONNECTIONS_PER_USER'), 4);
  }

  private eventLimit() {
    return positiveInt(this.config.get('SOCKET_EVENT_LIMIT'), 30);
  }

  private eventWindowSeconds() {
    return positiveInt(this.config.get('SOCKET_EVENT_WINDOW_SECONDS'), 10);
  }

  private connTtlMs() {
    return positiveInt(this.config.get('SOCKET_CONN_TTL_MS'), 90_000);
  }

  private async refresh() {
    const now = Date.now();
    const ttlMs = this.connTtlMs();
    for (const [socketId, userId] of this.local) {
      try {
        const key = socketConnKey(userId);
        await this.redis.zadd(key, now + ttlMs, socketId);
        await this.redis.pexpire(key, ttlMs);
      } catch {
        this.logger.warn('socket connection refresh unavailable');
      }
    }
  }
}

function positiveInt(value: unknown, fallback: number) {
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? Math.floor(parsed) : fallback;
}
