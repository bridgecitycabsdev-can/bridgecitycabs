import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import type { Job } from 'bullmq';
import { IdempotencyService } from '../idempotency/idempotency.service.js';
import { JOB_NAMES, JOBS_QUEUE } from './job-names.js';
import { LocationFlushService } from './location-flush.service.js';
import { LocationRetentionService } from './location-retention.service.js';
import { PresenceSweepService } from './presence-sweep.service.js';

@Processor(JOBS_QUEUE, { concurrency: 1 })
export class JobsWorker extends WorkerHost {
  private readonly logger = new Logger(JobsWorker.name);

  constructor(
    private readonly presence: PresenceSweepService,
    private readonly locations: LocationFlushService,
    private readonly idempotency: IdempotencyService,
    private readonly retention: LocationRetentionService,
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
      default:
        this.logger.warn(`Ignored unknown job ${job.name}`);
    }
  }
}
