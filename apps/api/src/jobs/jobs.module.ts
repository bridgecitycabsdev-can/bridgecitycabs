import { BullModule } from '@nestjs/bullmq';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { FleetModule } from '../fleet/fleet.module.js';
import { IdempotencyModule } from '../idempotency/idempotency.module.js';
import { JOBS_QUEUE } from './job-names.js';
import { JobsScheduler } from './jobs.scheduler.js';
import { JobsWorker } from './jobs.worker.js';
import { LocationFlushService } from './location-flush.service.js';
import { LocationRetentionService } from './location-retention.service.js';
import { PresenceSweepService } from './presence-sweep.service.js';

const workersEnabled = process.env.NODE_ENV !== 'test';

@Module({
  imports: [
    FleetModule,
    IdempotencyModule,
    ...(workersEnabled
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
      : []),
  ],
  providers: [
    PresenceSweepService,
    LocationFlushService,
    LocationRetentionService,
    ...(workersEnabled ? [JobsScheduler, JobsWorker] : []),
  ],
  exports: [PresenceSweepService, LocationFlushService, LocationRetentionService],
})
export class JobsModule {}
