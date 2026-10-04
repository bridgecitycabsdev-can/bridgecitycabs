import { Injectable } from '@nestjs/common';
import type { PaymentRecordStatus } from '@prisma/client';
import Stripe from 'stripe';
import type { PaymentProvider } from './payment-provider.js';

/**
 * Stripe PaymentIntents with manual capture (authorize at booking, capture at
 * completion). Card numbers never touch this API — PaymentSheet / Elements
 * collect them client-side.
 */
@Injectable()
export class StripeProvider implements PaymentProvider {
  readonly name = 'STRIPE';

  constructor(private readonly stripe: Stripe) {}

  static fromSecretKey(secretKey: string) {
    return new StripeProvider(new Stripe(secretKey));
  }

  async authorize(i: {
    bookingId: string;
    amountCents: number;
    customerId?: string;
    paymentMethodId?: string;
    idempotencyKey: string;
  }) {
    const pi = await this.stripe.paymentIntents.create(
      {
        amount: i.amountCents,
        currency: 'cad',
        capture_method: 'manual',
        customer: i.customerId,
        payment_method: i.paymentMethodId,
        confirm: Boolean(i.paymentMethodId),
        // Saved card charged without the passenger present — affects 3DS rules.
        off_session: Boolean(i.paymentMethodId),
        metadata: { bookingId: i.bookingId },
      },
      { idempotencyKey: i.idempotencyKey },
    );
    return {
      providerRef: pi.id,
      status: mapPaymentIntentStatus(pi.status),
    };
  }

  async capture(i: {
    providerRef: string;
    amountCents: number;
    idempotencyKey: string;
  }) {
    const pi = await this.stripe.paymentIntents.capture(
      i.providerRef,
      { amount_to_capture: i.amountCents },
      { idempotencyKey: i.idempotencyKey },
    );
    return { status: mapPaymentIntentStatus(pi.status) };
  }

  async cancel(i: { providerRef: string }) {
    await this.stripe.paymentIntents.cancel(i.providerRef);
  }

  async refund(i: {
    providerRef: string;
    amountCents: number;
    idempotencyKey: string;
  }) {
    await this.stripe.refunds.create(
      {
        payment_intent: i.providerRef,
        amount: i.amountCents,
      },
      { idempotencyKey: i.idempotencyKey },
    );
  }
}

export function mapPaymentIntentStatus(
  status: Stripe.PaymentIntent.Status,
): PaymentRecordStatus {
  switch (status) {
    case 'requires_action':
    case 'requires_confirmation':
      return 'REQUIRES_ACTION';
    case 'requires_capture':
      return 'AUTHORIZED';
    case 'succeeded':
      return 'CAPTURED';
    case 'canceled':
      return 'CANCELLED';
    case 'processing':
    case 'requires_payment_method':
    default:
      return 'PENDING';
  }
}
