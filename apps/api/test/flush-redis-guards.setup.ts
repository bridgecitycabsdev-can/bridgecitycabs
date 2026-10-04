import { beforeAll } from 'vitest';
import { flushRedisPrefix } from './flush-redis-guards.js';
import { assertIsolatedTestEnv } from './test-env.js';

assertIsolatedTestEnv();

// setupFiles re-register this for each file — clears login/IP throttle leftovers
// so a Day 2 throttle e2e cannot 429 every later suite's beforeAll logins.
beforeAll(async () => {
  await flushRedisPrefix('throttle:');
});
