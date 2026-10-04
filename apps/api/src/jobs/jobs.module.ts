import { Module, forwardRef } from '@nestjs/common';
import { FleetModule } from '../fleet/fleet.module.js';
import { IdempotencyModule } from '../idempotency/idempotency.module.js';
import { DispatchModule } from '../dispatch/dispatch.module.js';
import { FinanceModule } from '../finance/finance.module.js';
import { LeaseModule } from '../lease/lease.module.js';
import { ReportingModule } from '../reporting/reporting.module.js';
import { StorageModule } from '../storage/storage.module.js';
import { WebhooksModule } from '../webhooks/webhooks.module.js';
import { DatabaseBackupService } from './database-backup.service.js';
import { QueueModule } from './queue.module.js';
import { JobsScheduler } from './jobs.scheduler.js';
import { JobsWorker } from './jobs.worker.js';
import { LedgerIntegrityService } from './ledger-integrity.service.js';
import { LocationFlushService } from './location-flush.service.js';
import { LocationRetentionService } from './location-retention.service.js';
import { PaymentPendingAlertService } from './payment-pending-alert.service.js';
import { PresenceSweepService } from './presence-sweep.service.js';

const workersEnabled = process.env.NODE_ENV !== 'test';

@Module({
  imports: [
    QueueModule,
    FleetModule,
    IdempotencyModule,
    LeaseModule,
    FinanceModule,
    ReportingModule,
    StorageModule,
    ...(workersEnabled
      ? [DispatchModule, forwardRef(() => WebhooksModule)]
      : []),
  ],
  providers: [
    PresenceSweepService,
    LocationFlushService,
    LocationRetentionService,
    PaymentPendingAlertService,
    LedgerIntegrityService,
    DatabaseBackupService,
    ...(workersEnabled ? [JobsScheduler, JobsWorker] : []),
  ],
  exports: [
    PresenceSweepService,
    LocationFlushService,
    LocationRetentionService,
    PaymentPendingAlertService,
    LedgerIntegrityService,
    DatabaseBackupService,
  ],
})
export class JobsModule {}
