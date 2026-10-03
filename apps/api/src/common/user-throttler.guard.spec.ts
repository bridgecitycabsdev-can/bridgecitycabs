import { Reflector } from '@nestjs/core';
import type { ThrottlerStorage } from '@nestjs/throttler';
import { describe, expect, it } from 'vitest';
import { UserThrottlerGuard } from './user-throttler.guard.js';

describe('UserThrottlerGuard', () => {
  const storage: ThrottlerStorage = {
    increment: () => {
      throw new Error('unused');
    },
  };
  const guard = new UserThrottlerGuard(
    { throttlers: [{ ttl: 60_000, limit: 40 }] },
    storage,
    new Reflector(),
  );

  it('counts requests by the signed-in user', async () => {
    await expect(
      guard['getTracker']({ user: { userId: 'user-1' }, ip: '203.0.113.5' }),
    ).resolves.toBe('user-1');
  });

  it('falls back to the client address when no user is attached', async () => {
    await expect(guard['getTracker']({ ip: '203.0.113.5' })).resolves.toBe(
      '203.0.113.5',
    );
  });
});
