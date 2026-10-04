import { Module } from '@nestjs/common';
import { ModuleRef } from '@nestjs/core';
import { BookingsModule } from '../bookings/bookings.module.js';
import {
  BullStripeWebhookQueue,
  STRIPE_WEBHOOK_QUEUE,
  SyncStripeWebhookQueue,
} from '../jobs/stripe-webhook-queue.js';
import { QueueModule } from '../jobs/queue.module.js';
import { LedgerModule } from '../ledger/ledger.module.js';
import { PaymentsModule } from '../payments/payments.module.js';
import { StripeWebhookController } from '../payments/stripe-webhook.controller.js';
import { StripeWebhookService } from '../payments/stripe-webhook.service.js';

const workersEnabled = process.env.NODE_ENV !== 'test';

@Module({
  imports: [
    PaymentsModule,
    BookingsModule,
    LedgerModule,
    ...(workersEnabled ? [QueueModule] : []),
  ],
  controllers: [StripeWebhookController],
  providers: [
    StripeWebhookService,
    workersEnabled
      ? { provide: STRIPE_WEBHOOK_QUEUE, useClass: BullStripeWebhookQueue }
      : {
          provide: STRIPE_WEBHOOK_QUEUE,
          inject: [ModuleRef],
          useFactory: (moduleRef: ModuleRef) =>
            new SyncStripeWebhookQueue((eventId) =>
              moduleRef.get(StripeWebhookService, { strict: false }).processEvent(
                eventId,
              ),
            ),
        },
  ],
  exports: [StripeWebhookService],
})
export class WebhooksModule {}
