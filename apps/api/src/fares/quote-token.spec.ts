import { describe, expect, it } from 'vitest';
import {
  signQuote,
  stopsHash,
  verifyQuote,
  type QuotePayload,
} from './quote-token.js';

const secret = 'quote-secret';
const stops = [
  { lat: 49.6935, lng: -112.8418 },
  { lat: 49.7, lng: -112.84 },
];

function payload(overrides: Partial<QuotePayload> = {}): QuotePayload {
  return {
    branchId: 'branch-1',
    vehicleTypeId: 'suv',
    zone: 'INSIDE_TOWN',
    stopsHash: stopsHash(stops),
    distanceM: 8100,
    durationS: 1020,
    subtotalCents: 2510,
    taxCents: 126,
    totalCents: 2636,
    source: 'ROUTES',
    exp: Math.floor(Date.now() / 1000) + 600,
    ...overrides,
  };
}

const expected = {
  branchId: 'branch-1',
  vehicleTypeId: 'suv',
  zone: 'INSIDE_TOWN' as const,
  stopsHash: stopsHash(stops),
};

describe('quote tokens', () => {
  it('round-trips a payload signed with HMAC', () => {
    const token = signQuote(payload(), secret);
    expect(verifyQuote(token, secret, expected)?.subtotalCents).toBe(2510);
  });

  it('rejects a tampered signature, an expired token, and a different trip', () => {
    const token = signQuote(payload(), secret);
    const [body, sig] = token.split('.');
    const flipped = `${body}.${sig?.slice(0, -1)}x`;
    expect(verifyQuote(flipped, secret, expected)).toBeNull();
    expect(verifyQuote(token.slice(0, -2), secret, expected)).toBeNull();

    const expired = signQuote(
      payload({ exp: Math.floor(Date.now() / 1000) - 1 }),
      secret,
    );
    expect(verifyQuote(expired, secret, expected)).toBeNull();

    const otherStops = stopsHash([
      { lat: 0, lng: 0 },
      { lat: 1, lng: 1 },
    ]);
    const moved = signQuote(payload({ stopsHash: otherStops }), secret);
    expect(verifyQuote(moved, secret, expected)).toBeNull();
    expect(verifyQuote(token, 'other-secret', expected)).toBeNull();
    expect(
      verifyQuote(token, secret, { ...expected, vehicleTypeId: 'sedan' }),
    ).toBeNull();
  });
});
