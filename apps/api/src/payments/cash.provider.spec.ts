import { describe, expect, it } from 'vitest';
import { CashProvider } from './cash.provider.js';

describe('CashProvider', () => {
  const provider = new CashProvider();

  it('authorizes as CAPTURED when the driver confirms cash received', async () => {
    await expect(
      provider.authorize({
        bookingId: 'b1',
        amountCents: 2100,
        idempotencyKey: 'idem-1',
      }),
    ).resolves.toEqual({
      providerRef: 'cash_b1',
      status: 'CAPTURED',
    });
  });

  it('treats capture/cancel/refund as local no-ops', async () => {
    await expect(
      provider.capture({
        providerRef: 'cash_b1',
        amountCents: 2100,
        idempotencyKey: 'cap-1',
      }),
    ).resolves.toEqual({ status: 'CAPTURED' });
    await expect(provider.cancel({ providerRef: 'cash_b1' })).resolves.toBeUndefined();
    await expect(
      provider.refund({
        providerRef: 'cash_b1',
        amountCents: 2100,
        idempotencyKey: 'refund-1',
      }),
    ).resolves.toBeUndefined();
  });
});
