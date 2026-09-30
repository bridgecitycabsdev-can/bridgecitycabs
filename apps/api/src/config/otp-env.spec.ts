import { describe, expect, it } from 'vitest';
import { assertOtpDevCode } from './otp-env.js';

describe('assertOtpDevCode', () => {
  it('allows the simulator code outside production', () => {
    expect(() =>
      assertOtpDevCode({ NODE_ENV: 'development', OTP_DEV_CODE: '000000' }),
    ).not.toThrow();
    expect(() => assertOtpDevCode({ NODE_ENV: 'production' })).not.toThrow();
  });

  it('throws when the simulator code is set in production', () => {
    expect(() =>
      assertOtpDevCode({ NODE_ENV: 'production', OTP_DEV_CODE: '000000' }),
    ).toThrow(/OTP_DEV_CODE must not be set/);
  });
});
