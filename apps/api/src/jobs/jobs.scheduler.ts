import { InjectQueue } from '@nestjs/bullmq';
import { Injectable, OnModuleInit } from '@nestjs/common';
import type { Queue } from 'bullmq';
import {
  IDEMPOTENCY_PURGE_PATTERN,
  JOB_NAMES,
  JOBS_QUEUE,
  LOCATION_FLUSH_EVERY_MS,
  LOCATION_RETENTION_PATTERN,
  LEDGER_INTEGRITY_PATTERN,
  PAYMENT_PENDING_ALERT_PATTERN,
  PRESENCE_SWEEP_EVERY_MS,
  SCHEDULED_SWEEP_EVERY_MS,
} from './job-names.js';

const template = {
  removeOnComplete: 50,
  removeOnFail: 20,
  attempts: 3,
  backoff: { type: 'exponential' as const, delay: 1_000 },
};

@Injectable()
export class JobsScheduler implements OnModuleInit {
  constructor(@InjectQueue(JOBS_QUEUE) private readonly queue: Queue) {}

  async onModuleInit() {
    await this.queue.upsertJobScheduler(
      JOB_NAMES.presenceSweep,
      { every: PRESENCE_SWEEP_EVERY_MS },
      { name: JOB_NAMES.presenceSweep, opts: template },
    );
    await this.queue.upsertJobScheduler(
      JOB_NAMES.locationFlush,
      { every: LOCATION_FLUSH_EVERY_MS },
      { name: JOB_NAMES.locationFlush, opts: template },
    );
    await this.queue.upsertJobScheduler(
      JOB_NAMES.idempotencyPurge,
      { pattern: IDEMPOTENCY_PURGE_PATTERN, tz: 'UTC' },
      { name: JOB_NAMES.idempotencyPurge, opts: template },
    );
    await this.queue.upsertJobScheduler(
      JOB_NAMES.locationRetention,
      { pattern: LOCATION_RETENTION_PATTERN, tz: 'UTC' },
      { name: JOB_NAMES.locationRetention, opts: template },
    );
    await this.queue.upsertJobScheduler(
      JOB_NAMES.paymentPendingAlert,
      { pattern: PAYMENT_PENDING_ALERT_PATTERN, tz: 'UTC' },
      { name: JOB_NAMES.paymentPendingAlert, opts: template },
    );
    await this.queue.upsertJobScheduler(
      JOB_NAMES.ledgerIntegrity,
      { pattern: LEDGER_INTEGRITY_PATTERN, tz: 'UTC' },
      { name: JOB_NAMES.ledgerIntegrity, opts: template },
    );
    await this.queue.upsertJobScheduler(
      JOB_NAMES.scheduledSweep,
      { every: SCHEDULED_SWEEP_EVERY_MS },
      { name: JOB_NAMES.scheduledSweep, opts: template },
    );
  }
}
