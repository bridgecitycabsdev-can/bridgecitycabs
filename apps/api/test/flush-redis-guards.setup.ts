import { flushRedisPrefix } from './flush-redis-guards.js';
import { assertIsolatedTestEnv } from './test-env.js';

assertIsolatedTestEnv();
await flushRedisPrefix('throttle:');
