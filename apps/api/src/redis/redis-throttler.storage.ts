import type { ThrottlerStorage } from '@nestjs/throttler';
import type { Redis } from 'ioredis';
import { throttleBlockKey, throttleHitKey } from './redis.keys.js';

const INCREMENT = `
local hitKey = KEYS[1]
local blockKey = KEYS[2]
local ttl = tonumber(ARGV[1])
local limit = tonumber(ARGV[2])
local blockDuration = tonumber(ARGV[3])

local blockedFor = redis.call('PTTL', blockKey)
if blockedFor > 0 then
  local hits = tonumber(redis.call('GET', hitKey) or '0')
  local hitTtl = redis.call('PTTL', hitKey)
  if hitTtl < 0 then hitTtl = 0 end
  return { hits, hitTtl, 1, blockedFor }
end

local hits = redis.call('INCR', hitKey)
local hitTtl = redis.call('PTTL', hitKey)
if hits == 1 or hitTtl < 0 then
  redis.call('PEXPIRE', hitKey, ttl)
  hitTtl = ttl
end

local isBlocked = 0
local blockTtl = 0
if hits > limit then
  redis.call('SET', blockKey, '1', 'PX', blockDuration)
  isBlocked = 1
  blockTtl = blockDuration
end

return { hits, hitTtl, isBlocked, blockTtl }
`;

export class RedisThrottlerStorage implements ThrottlerStorage {
  constructor(private readonly redis: Redis) {}

  async increment(
    key: string,
    ttl: number,
    limit: number,
    blockDuration: number,
    throttlerName: string,
  ): Promise<Awaited<ReturnType<ThrottlerStorage['increment']>>> {
    const result = (await this.redis.eval(
      INCREMENT,
      2,
      throttleHitKey(throttlerName, key),
      throttleBlockKey(throttlerName, key),
      String(ttl),
      String(limit),
      String(blockDuration),
    )) as [number, number, number, number];
    const [totalHits, timeToExpireMs, isBlocked, timeToBlockExpireMs] = result;
    return {
      totalHits: Number(totalHits),
      timeToExpire: seconds(Number(timeToExpireMs)),
      isBlocked: Number(isBlocked) === 1,
      timeToBlockExpire: seconds(Number(timeToBlockExpireMs)),
    };
  }
}

function seconds(milliseconds: number) {
  return Math.max(0, Math.ceil(milliseconds / 1000));
}
