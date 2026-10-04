import type { PaymentRecordStatus } from '@prisma/client';

/**
 * Gateway-agnostic collection. Card numbers never touch BridgeCabs servers —
 * Stripe integrations use PaymentSheet / Elements (hosted fields).
 *
 * Stripe idempotency keys are passed on every gateway call and should reuse
 * `Payment.idempotencyKey` so retries are deduplicated at Stripe as well as
 * in our API (`Idempotency-Key` header) and Payment row.
 */
export interface PaymentProvider {
  readonly name: string;
  authorize(i: {
    bookingId: string;
    amountCents: number;
    customerId?: string;
    paymentMethodId?: string;
    idempotencyKey: string;
  }): Promise<{ providerRef: string; status: PaymentRecordStatus }>;
  capture(i: {
    providerRef: string;
    amountCents: number;
    idempotencyKey: string;
  }): Promise<{ status: PaymentRecordStatus }>;
  cancel(i: { providerRef: string }): Promise<void>;
  refund(i: {
    providerRef: string;
    amountCents: number;
    idempotencyKey: string;
  }): Promise<void>;
}

/** Map of provider name → implementation (CASH, FAKE, STRIPE, …). */
export const PAYMENT_PROVIDERS = Symbol('PAYMENT_PROVIDERS');
