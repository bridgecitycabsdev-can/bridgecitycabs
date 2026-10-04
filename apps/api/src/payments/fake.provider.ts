import { Injectable } from '@nestjs/common';
import type { PaymentProvider } from './payment-provider.js';

/**
 * Dev-only card stand-in. Registered only when ALLOW_FAKE_PAYMENTS is set, and
 * that flag is forbidden in production (same pattern as OTP_DEV_CODE).
 */
@Injectable()
export class FakeProvider implements PaymentProvider {
  readonly name = 'FAKE';

  async authorize(i: {
    bookingId: string;
    amountCents: number;
    customerId?: string;
    paymentMethodId?: string;
    idempotencyKey: string;
  }) {
    return {
      providerRef: `fake_${i.bookingId}_${i.idempotencyKey}`,
      status: 'AUTHORIZED' as const,
    };
  }

  async capture(_i: {
    providerRef: string;
    amountCents: number;
    idempotencyKey: string;
  }) {
    return { status: 'CAPTURED' as const };
  }

  async cancel(_i: { providerRef: string }) {
    // No-op: there is no external hold to release.
  }

  async refund(_i: {
    providerRef: string;
    amountCents: number;
    idempotencyKey: string;
  }) {
    // No-op: there is no external capture to reverse.
  }
}
