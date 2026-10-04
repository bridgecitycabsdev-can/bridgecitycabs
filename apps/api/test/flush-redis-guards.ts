import { Redis } from 'ioredis';
import { loadEnvFile } from './load-env-file.js';

loadEnvFile();

export async function flushRedisPrefix(prefix: string) {
  const redis = new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379', {
    maxRetriesPerRequest: 2,
  });
  try {
    let cursor = '0';
    do {
      const [next, keys] = await redis.scan(cursor, 'MATCH', `${prefix}*`, 'COUNT', 200);
      cursor = next;
      if (keys.length) {
        await redis.del(...keys);
      }
    } while (cursor !== '0');
  } finally {
    await redis.quit();
  }
}
