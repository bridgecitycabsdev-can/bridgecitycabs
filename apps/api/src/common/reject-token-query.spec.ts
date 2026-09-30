import { describe, expect, it } from 'vitest';
import { queryCarriesToken } from './reject-token-query.middleware.js';

describe('token query rejection', () => {
  it('flags access and refresh tokens in the query string', () => {
    expect(queryCarriesToken({ token: 'secret' })).toBe(true);
    expect(queryCarriesToken({ access_token: 'secret' })).toBe(true);
    expect(queryCarriesToken({ refreshToken: 'secret' })).toBe(true);
    expect(queryCarriesToken({ branchId: '4940aa0c-0477-4b0b-8a79-e2a88583de97' })).toBe(false);
  });
});
