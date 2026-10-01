import { Module } from '@nestjs/common';
import { FleetModule } from '../fleet/fleet.module.js';
import { IdempotencyModule } from '../idempotency/idempotency.module.js';
import { DispatchModule } from '../dispatch/dispatch.module.js';
import { QueueModule } from './queue.module.js';
import { JobsScheduler } from './jobs.scheduler.js';
import { JobsWorker } from './jobs.worker.js';
import { LocationFlushService } from './location-flush.service.js';
import { LocationRetentionService } from './location-retention.service.js';
import { PresenceSweepService } from './presence-sweep.service.js';

const workersEnabled = process.env.NODE_ENV !== 'test';

@Module({
  imports: [
    QueueModule,
    FleetModule,
    IdempotencyModule,
    ...(workersEnabled ? [DispatchModule] : []),
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
