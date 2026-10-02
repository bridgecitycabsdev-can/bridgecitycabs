import { describe, expect, it } from 'vitest';
import { assertIsolatedTestEnv } from './test-env.js';

describe('isolated test env', () => {
  it('accepts the test database and Redis database 1', () => {
    expect(() =>
      assertIsolatedTestEnv({
        DATABASE_URL: 'postgresql://bridgecabs:secret@127.0.0.1:5432/bridgecabs_test',
        REDIS_URL: 'redis://127.0.0.1:6379/1',
      }),
    ).not.toThrow();
  });

  it('refuses the dev database and the default Redis database', () => {
    expect(() =>
      assertIsolatedTestEnv({
        DATABASE_URL: 'postgresql://bridgecabs:secret@127.0.0.1:5432/bridgecabs',
        REDIS_URL: 'redis://127.0.0.1:6379/1',
      }),
    ).toThrow(/_test/);
    expect(() =>
      assertIsolatedTestEnv({
        DATABASE_URL: 'postgresql://bridgecabs:secret@127.0.0.1:5432/bridgecabs_test',
        REDIS_URL: 'redis://127.0.0.1:6379',
      }),
    ).toThrow(/\/1/);
  });
});
