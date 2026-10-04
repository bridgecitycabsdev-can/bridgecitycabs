import { Injectable } from '@nestjs/common';
import type { PaymentProvider } from './payment-provider.js';

/** Cash settles when the driver confirms receipt — no gateway round-trip. */
@Injectable()
export class CashProvider implements PaymentProvider {
  readonly name = 'CASH';

  async authorize(i: {
    bookingId: string;
    amountCents: number;
    customerId?: string;
    paymentMethodId?: string;
    idempotencyKey: string;
  }) {
    return {
      providerRef: `cash_${i.bookingId}`,
      status: 'CAPTURED' as const,
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
    // Nothing held at the gateway.
  }

  async refund(_i: {
    providerRef: string;
    amountCents: number;
    idempotencyKey: string;
  }) {
    // Cash refunds are handled out-of-band (ledger REVERSAL).
  }
}
