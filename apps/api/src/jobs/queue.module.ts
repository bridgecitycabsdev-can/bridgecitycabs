import { BullModule } from '@nestjs/bullmq';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import {
  BullOfferExpiryScheduler,
  NoopOfferExpiryScheduler,
  OFFER_EXPIRY_SCHEDULER,
} from './offer-expiry.scheduler.js';
import { BullDispatchQueue, DISPATCH_QUEUE, NoopDispatchQueue } from './dispatch-queue.js';
import { JOBS_QUEUE } from './job-names.js';
import {
  BullReportQueue,
  NoopReportQueue,
  REPORT_QUEUE,
} from './report-queue.js';

const workersEnabled = process.env.NODE_ENV !== 'test';

@Module({
  imports: workersEnabled
    ? [
        BullModule.forRootAsync({
          imports: [ConfigModule],
          inject: [ConfigService],
          useFactory: (config: ConfigService) => ({
            connection: {
              url: config.getOrThrow<string>('REDIS_URL'),
              maxRetriesPerRequest: null,
            },
          }),
        }),
        BullModule.registerQueue({ name: JOBS_QUEUE }),
      ]
    : [],
  providers: [
    workersEnabled
      ? { provide: OFFER_EXPIRY_SCHEDULER, useClass: BullOfferExpiryScheduler }
      : { provide: OFFER_EXPIRY_SCHEDULER, useClass: NoopOfferExpiryScheduler },
    workersEnabled
      ? { provide: DISPATCH_QUEUE, useClass: BullDispatchQueue }
      : { provide: DISPATCH_QUEUE, useClass: NoopDispatchQueue },
    workersEnabled
      ? { provide: REPORT_QUEUE, useClass: BullReportQueue }
      : { provide: REPORT_QUEUE, useClass: NoopReportQueue },
  ],
  exports: [
    OFFER_EXPIRY_SCHEDULER,
    DISPATCH_QUEUE,
    REPORT_QUEUE,
    ...(workersEnabled ? [BullModule] : []),
  ],
})
export class QueueModule {}
