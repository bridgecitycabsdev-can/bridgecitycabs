/** E2E must not share the dev database or the dev Redis database number. */
export function assertIsolatedTestEnv(
  env: NodeJS.ProcessEnv = process.env,
) {
  const databaseUrl = env.DATABASE_URL ?? '';
  const redisUrl = env.REDIS_URL ?? '';
  if (!databaseUrl.includes('_test')) {
    throw new Error('Refusing to run tests unless DATABASE_URL contains _test');
  }
  if (!redisUrl.endsWith('/1')) {
    throw new Error('Refusing to run tests unless REDIS_URL ends in /1');
  }
}
