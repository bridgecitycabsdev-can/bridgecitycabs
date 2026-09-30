import { describe, expect, it } from 'vitest';
import { hashOtp, newOtpCode, useDevOtp } from './otp.policy.js';

describe('otp policy', () => {
  it('stores a peppered hash instead of the code', () => {
    const hash = hashOtp('pepper', '000000');
    expect(hash).toHaveLength(64);
    expect(hash).not.toContain('000000');
    expect(hashOtp('other-pepper', '000000')).not.toBe(hash);
  });

  it('uses the simulator code outside production only', () => {
    expect(useDevOtp('000000', 'development')).toBe(true);
    expect(useDevOtp('000000', 'production')).toBe(false);
    expect(useDevOtp('12', 'development')).toBe(false);
    expect(newOtpCode('000000', 'development')).toBe('000000');
    expect(newOtpCode('000000', 'production')).toMatch(/^\d{6}$/);
  });
});
