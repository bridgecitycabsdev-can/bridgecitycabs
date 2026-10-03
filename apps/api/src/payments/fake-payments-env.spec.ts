import { describe, expect, it } from 'vitest';
import {
  assertFakePaymentsEnv,
  fakePaymentsAllowed,
} from './fake-payments-env.js';

describe('fakePaymentsAllowed', () => {
  it('accepts common truthy strings', () => {
    expect(fakePaymentsAllowed({ ALLOW_FAKE_PAYMENTS: 'true' })).toBe(true);
    expect(fakePaymentsAllowed({ ALLOW_FAKE_PAYMENTS: '1' })).toBe(true);
    expect(fakePaymentsAllowed({ ALLOW_FAKE_PAYMENTS: 'yes' })).toBe(true);
    expect(fakePaymentsAllowed({ ALLOW_FAKE_PAYMENTS: 'false' })).toBe(false);
    expect(fakePaymentsAllowed({})).toBe(false);
  });
});

describe('assertFakePaymentsEnv', () => {
  it('allows the fake provider outside production', () => {
    expect(() =>
      assertFakePaymentsEnv({
        NODE_ENV: 'development',
        ALLOW_FAKE_PAYMENTS: 'true',
      }),
    ).not.toThrow();
    expect(() => assertFakePaymentsEnv({ NODE_ENV: 'production' })).not.toThrow();
  });

  it('throws when fake payments are enabled in production', () => {
    expect(() =>
      assertFakePaymentsEnv({
        NODE_ENV: 'production',
        ALLOW_FAKE_PAYMENTS: 'true',
      }),
    ).toThrow(/ALLOW_FAKE_PAYMENTS must not be set/);
  });
});
