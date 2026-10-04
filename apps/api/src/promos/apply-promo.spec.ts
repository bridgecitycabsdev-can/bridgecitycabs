import { describe, expect, it } from 'vitest';
import { applyPromo } from './apply-promo.js';

describe('applyPromo', () => {
  it('applies a percent discount in basis points', () => {
    expect(
      applyPromo(10_000, { type: 'PERCENT', valueBps: 1500 }),
    ).toEqual({ discountCents: 1500, netSubtotalCents: 8500 });
  });

  it('applies a fixed discount capped by max and subtotal', () => {
    expect(
      applyPromo(2000, {
        type: 'FIXED',
        valueCents: 5000,
        maxDiscountCents: 800,
      }),
    ).toEqual({ discountCents: 800, netSubtotalCents: 1200 });
    expect(
      applyPromo(300, { type: 'FIXED', valueCents: 500 }),
    ).toEqual({ discountCents: 300, netSubtotalCents: 0 });
  });

  it('never returns a negative discount', () => {
    expect(
      applyPromo(1000, { type: 'FIXED', valueCents: -50 }),
    ).toEqual({ discountCents: 0, netSubtotalCents: 1000 });
  });
});
