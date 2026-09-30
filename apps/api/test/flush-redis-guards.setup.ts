import { flushRedisPrefix } from './flush-redis-guards.js';

await flushRedisPrefix('throttle:');
