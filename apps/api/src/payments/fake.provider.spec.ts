import { describe, expect, it } from 'vitest';
import { FakeProvider } from './fake.provider.js';

describe('FakeProvider', () => {
  it('captures with a deterministic fake providerRef for card dry-runs', async () => {
    const provider = new FakeProvider();
    await expect(
      provider.createPayment({
        bookingId: 'b1',
        amountCents: 2100,
        idempotencyKey: 'idem-1',
      }),
    ).resolves.toEqual({
      providerRef: 'fake_b1_idem-1',
      status: 'CAPTURED',
    });
  });

  it('accepts refunds as a no-op', async () => {
    const provider = new FakeProvider();
    await expect(
      provider.refund!({
        providerRef: 'fake_b1_idem-1',
        amountCents: 2100,
        idempotencyKey: 'refund-1',
      }),
    ).resolves.toBeUndefined();
  });
});
