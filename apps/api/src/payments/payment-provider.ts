import type { PaymentRecordStatus } from '@prisma/client';

/**
 * Gateway-agnostic collection. Card numbers never touch BridgeCabs servers —
 * Day 10 integrations must use the provider's hosted fields or SDK.
 */
export interface PaymentProvider {
  readonly name: string;
  createPayment(i: {
    bookingId: string;
    amountCents: number;
    idempotencyKey: string;
  }): Promise<{ providerRef?: string; status: PaymentRecordStatus }>;
  refund?(i: {
    providerRef: string;
    amountCents: number;
    idempotencyKey: string;
  }): Promise<void>;
}

/** Map of provider name → implementation (CASH, FAKE, later STRIPE, …). */
export const PAYMENT_PROVIDERS = Symbol('PAYMENT_PROVIDERS');
