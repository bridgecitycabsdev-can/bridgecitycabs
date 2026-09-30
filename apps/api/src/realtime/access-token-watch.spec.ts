import { describe, expect, it } from 'vitest';
import { authExpiringDelayMs } from './access-token-watch.js';

describe('access token watch', () => {
  it('warns 60 seconds before exp and immediately once that window has started', () => {
    const exp = 1_800;
    expect(authExpiringDelayMs(exp, exp * 1000 - 90_000)).toBe(30_000);
    expect(authExpiringDelayMs(exp, exp * 1000 - 10_000)).toBe(0);
  });
});
