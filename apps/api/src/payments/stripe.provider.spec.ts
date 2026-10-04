import { describe, expect, it, vi } from 'vitest';
import type Stripe from 'stripe';
import {
  mapPaymentIntentStatus,
  StripeProvider,
} from './stripe.provider.js';

function mockStripe(overrides: {
  create?: ReturnType<typeof vi.fn>;
  capture?: ReturnType<typeof vi.fn>;
  cancel?: ReturnType<typeof vi.fn>;
  refundsCreate?: ReturnType<typeof vi.fn>;
} = {}) {
  return {
    paymentIntents: {
      create: overrides.create ?? vi.fn(),
      capture: overrides.capture ?? vi.fn(),
      cancel: overrides.cancel ?? vi.fn(),
    },
    refunds: {
      create: overrides.refundsCreate ?? vi.fn(),
    },
  } as unknown as Stripe;
}

describe('mapPaymentIntentStatus', () => {
  it('maps Stripe statuses onto PaymentRecordStatus', () => {
    expect(mapPaymentIntentStatus('requires_action')).toBe('REQUIRES_ACTION');
    expect(mapPaymentIntentStatus('requires_confirmation')).toBe(
      'REQUIRES_ACTION',
    );
    expect(mapPaymentIntentStatus('requires_capture')).toBe('AUTHORIZED');
    expect(mapPaymentIntentStatus('succeeded')).toBe('CAPTURED');
    expect(mapPaymentIntentStatus('canceled')).toBe('CANCELLED');
    expect(mapPaymentIntentStatus('processing')).toBe('PENDING');
    expect(mapPaymentIntentStatus('requires_payment_method')).toBe('PENDING');
  });
});

describe('StripeProvider', () => {
  it('creates a manual-capture PaymentIntent off-session when a PM is present', async () => {
    const create = vi.fn(async () => ({
      id: 'pi_123',
      status: 'requires_capture',
    }));
    const provider = new StripeProvider(mockStripe({ create }));

    await expect(
      provider.authorize({
        bookingId: 'b1',
        amountCents: 2500,
        customerId: 'cus_1',
        paymentMethodId: 'pm_1',
        idempotencyKey: 'auth:b1',
      }),
    ).resolves.toEqual({ providerRef: 'pi_123', status: 'AUTHORIZED' });

    expect(create).toHaveBeenCalledWith(
      {
        amount: 2500,
        currency: 'cad',
        capture_method: 'manual',
        customer: 'cus_1',
        payment_method: 'pm_1',
        confirm: true,
        off_session: true,
        metadata: { bookingId: 'b1' },
      },
      { idempotencyKey: 'auth:b1' },
    );
  });

  it('maps requires_action so the passenger app can handle 3DS', async () => {
    const create = vi.fn(async () => ({
      id: 'pi_action',
      status: 'requires_action',
    }));
    const provider = new StripeProvider(mockStripe({ create }));

    await expect(
      provider.authorize({
        bookingId: 'b2',
        amountCents: 1000,
        paymentMethodId: 'pm_2',
        idempotencyKey: 'auth:b2',
      }),
    ).resolves.toEqual({
      providerRef: 'pi_action',
      status: 'REQUIRES_ACTION',
    });
  });

  it('captures with amount_to_capture and the Payment idempotency key', async () => {
    const capture = vi.fn(async () => ({
      id: 'pi_123',
      status: 'succeeded',
    }));
    const provider = new StripeProvider(mockStripe({ capture }));

    await expect(
      provider.capture({
        providerRef: 'pi_123',
        amountCents: 2400,
        idempotencyKey: 'cap:b1',
      }),
    ).resolves.toEqual({ status: 'CAPTURED' });

    expect(capture).toHaveBeenCalledWith(
      'pi_123',
      { amount_to_capture: 2400 },
      { idempotencyKey: 'cap:b1' },
    );
  });

  it('cancels and refunds via Stripe APIs', async () => {
    const cancel = vi.fn(async () => ({ id: 'pi_123', status: 'canceled' }));
    const refundsCreate = vi.fn(async () => ({ id: 're_1' }));
    const provider = new StripeProvider(mockStripe({ cancel, refundsCreate }));

    await provider.cancel({ providerRef: 'pi_123' });
    expect(cancel).toHaveBeenCalledWith('pi_123');

    await provider.refund({
      providerRef: 'pi_123',
      amountCents: 2400,
      idempotencyKey: 'refund:b1',
    });
    expect(refundsCreate).toHaveBeenCalledWith(
      { payment_intent: 'pi_123', amount: 2400 },
      { idempotencyKey: 'refund:b1' },
    );
  });
});
