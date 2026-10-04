import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import type { Job } from 'bullmq';
import { IdempotencyService } from '../idempotency/idempotency.service.js';
import { DispatchJobsService } from '../dispatch/dispatch-jobs.service.js';
import { InvoiceService } from '../finance/invoice.service.js';
import { WeeklyClosingService } from '../finance/weekly-closing.service.js';
import { LeaseDeductionService } from '../lease/lease-deduction.service.js';
import { JOB_NAMES, JOBS_QUEUE } from './job-names.js';
import { LocationFlushService } from './location-flush.service.js';
import { LocationRetentionService } from './location-retention.service.js';
import { LedgerIntegrityService } from './ledger-integrity.service.js';
import { PaymentPendingAlertService } from './payment-pending-alert.service.js';
import { PresenceSweepService } from './presence-sweep.service.js';

@Processor(JOBS_QUEUE, { concurrency: 1 })
export class JobsWorker extends WorkerHost {
  private readonly logger = new Logger(JobsWorker.name);

  constructor(
    private readonly presence: PresenceSweepService,
    private readonly locations: LocationFlushService,
    private readonly idempotency: IdempotencyService,
    private readonly retention: LocationRetentionService,
    private readonly paymentPendingAlert: PaymentPendingAlertService,
    private readonly ledgerIntegrity: LedgerIntegrityService,
    private readonly leaseDeduction: LeaseDeductionService,
    private readonly weeklyClosing: WeeklyClosingService,
    private readonly invoices: InvoiceService,
    private readonly dispatch: DispatchJobsService,
  ) {
    super();
  }

  async process(job: Job) {
    switch (job.name) {
      case JOB_NAMES.presenceSweep:
        await this.presence.sweep();
        return;
      case JOB_NAMES.locationFlush:
        await this.locations.flush();
        return;
      case JOB_NAMES.idempotencyPurge:
        await this.idempotency.purgeExpired();
        return;
      case JOB_NAMES.locationRetention:
        await this.retention.purge();
        return;
      case JOB_NAMES.paymentPendingAlert:
        await this.paymentPendingAlert.sweep();
        return;
      case JOB_NAMES.ledgerIntegrity:
        await this.ledgerIntegrity.check();
        return;
      case JOB_NAMES.leaseDeduction: {
        const timezone = jobTimezone(job);
        await this.leaseDeduction.run(
          timezone ? { timezone } : {},
        );
        return;
      }
      case JOB_NAMES.weeklyClose: {
        const timezone = jobTimezone(job);
        if (!timezone) return;
        await this.weeklyClosing.closePreviousWeekForTimezone(timezone);
        return;
      }
      case JOB_NAMES.invoiceOverdue:
        await this.invoices.sweepOverdue();
        return;
      case JOB_NAMES.dispatchAttempt: {
        const data = jobData(job);
        if (!data.bookingId) return;
        await this.dispatch.runAttempt(data.bookingId, data.n ?? 0);
        return;
      }
      case JOB_NAMES.offerExpire: {
        const data = jobData(job);
        if (!data.offerId) return;
        await this.dispatch.expireOffer(data.offerId);
        return;
      }
      case JOB_NAMES.scheduledRelease: {
        const data = jobData(job);
        if (!data.bookingId) return;
        await this.dispatch.releaseScheduled(data.bookingId);
        return;
      }
      case JOB_NAMES.scheduledSweep:
        await this.dispatch.sweepScheduled();
        return;
      default:
        this.logger.warn(`Ignored unknown job ${job.name}`);
    }
  }
}

function jobData(job: Job) {
  const data = job.data as { bookingId?: unknown; offerId?: unknown; n?: unknown };
  return {
    bookingId: typeof data?.bookingId === 'string' ? data.bookingId : '',
    offerId: typeof data?.offerId === 'string' ? data.offerId : '',
    n: typeof data?.n === 'number' && Number.isFinite(data.n) ? data.n : 0,
  };
}

function jobTimezone(job: Job) {
  const data = job.data as { timezone?: unknown };
  return typeof data?.timezone === 'string' && data.timezone.trim()
    ? data.timezone.trim()
    : '';
}
