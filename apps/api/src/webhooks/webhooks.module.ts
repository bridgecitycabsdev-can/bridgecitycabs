import { Module } from '@nestjs/common';
import { BookingsModule } from '../bookings/bookings.module.js';
import { LedgerModule } from '../ledger/ledger.module.js';
import { PaymentsModule } from '../payments/payments.module.js';
import { StripeWebhookController } from '../payments/stripe-webhook.controller.js';
import { StripeWebhookService } from '../payments/stripe-webhook.service.js';

@Module({
  imports: [PaymentsModule, BookingsModule, LedgerModule],
  controllers: [StripeWebhookController],
  providers: [StripeWebhookService],
})
export class WebhooksModule {}
