import { Injectable } from '@nestjs/common';
import type { PaymentProvider } from './payment-provider.js';

/** Cash settles when the driver confirms receipt — no gateway round-trip. */
@Injectable()
export class CashProvider implements PaymentProvider {
  readonly name = 'CASH';

  async createPayment(_i: {
    bookingId: string;
    amountCents: number;
    idempotencyKey: string;
  }) {
    return { status: 'CAPTURED' as const };
  }
}
