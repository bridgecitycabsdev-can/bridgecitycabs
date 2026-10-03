import { Injectable } from '@nestjs/common';
import type { PaymentProvider } from './payment-provider.js';

/**
 * Dev-only card stand-in. Registered only when ALLOW_FAKE_PAYMENTS is set, and
 * that flag is forbidden in production (same pattern as OTP_DEV_CODE).
 */
@Injectable()
export class FakeProvider implements PaymentProvider {
  readonly name = 'FAKE';

  async createPayment(i: {
    bookingId: string;
    amountCents: number;
    idempotencyKey: string;
  }) {
    return {
      providerRef: `fake_${i.bookingId}_${i.idempotencyKey}`,
      status: 'CAPTURED' as const,
    };
  }

  async refund(_i: {
    providerRef: string;
    amountCents: number;
    idempotencyKey: string;
  }) {
    // No-op: there is no external capture to reverse.
  }
}
