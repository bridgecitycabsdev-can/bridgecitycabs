import { describe, expect, it } from 'vitest';
import { CashProvider } from './cash.provider.js';

describe('CashProvider', () => {
  it('captures immediately when the driver confirms cash received', async () => {
    const provider = new CashProvider();
    await expect(
      provider.createPayment({
        bookingId: 'b1',
        amountCents: 2100,
        idempotencyKey: 'idem-1',
      }),
    ).resolves.toEqual({ status: 'CAPTURED' });
  });
});
