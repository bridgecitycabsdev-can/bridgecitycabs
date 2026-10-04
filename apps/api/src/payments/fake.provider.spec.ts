import { describe, expect, it } from 'vitest';
import { FakeProvider } from './fake.provider.js';

describe('FakeProvider', () => {
  const provider = new FakeProvider();

  it('authorizes a deterministic fake providerRef for card dry-runs', async () => {
    await expect(
      provider.authorize({
        bookingId: 'b1',
        amountCents: 2100,
        idempotencyKey: 'idem-1',
      }),
    ).resolves.toEqual({
      providerRef: 'fake_b1_idem-1',
      status: 'AUTHORIZED',
    });
  });

  it('captures and accepts cancel/refund as no-ops', async () => {
    await expect(
      provider.capture({
        providerRef: 'fake_b1_idem-1',
        amountCents: 2100,
        idempotencyKey: 'cap-1',
      }),
    ).resolves.toEqual({ status: 'CAPTURED' });
    await expect(
      provider.cancel({ providerRef: 'fake_b1_idem-1' }),
    ).resolves.toBeUndefined();
    await expect(
      provider.refund({
        providerRef: 'fake_b1_idem-1',
        amountCents: 2100,
        idempotencyKey: 'refund-1',
      }),
    ).resolves.toBeUndefined();
  });
});
