import { InjectQueue } from '@nestjs/bullmq';
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Queue } from 'bullmq';
import {
  leaseDeductionCronPattern,
  weeklyCloseCronPattern,
} from '../lease/lease-week.js';
import { PrismaService } from '../prisma/prisma.service.js';
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
  private readonly logger = new Logger(JobsScheduler.name);

  constructor(
    @InjectQueue(JOBS_QUEUE) private readonly queue: Queue,
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

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
    await this.scheduleBranchTimezoneJobs();
  }

  /**
   * One scheduler per distinct branch timezone for lease deductions (LEASE_DEDUCTION_DAY
   * local midnight) and weekly close (the following local midnight).
   */
  private async scheduleBranchTimezoneJobs() {
    const day = this.config.get<string>('LEASE_DEDUCTION_DAY');
    const leasePattern = leaseDeductionCronPattern(day);
    const closePattern = weeklyCloseCronPattern(day);
    const branches = await this.prisma.branch.findMany({
      select: { timezone: true },
      distinct: ['timezone'],
    });
    const timezones = [
      ...new Set(
        branches.map((b) => b.timezone?.trim() || 'America/Edmonton'),
      ),
    ];
    if (timezones.length === 0) {
      timezones.push('America/Edmonton');
    }
    for (const timezone of timezones) {
      await this.queue.upsertJobScheduler(
        `${JOB_NAMES.leaseDeduction}:${timezone}`,
        { pattern: leasePattern, tz: timezone },
        {
          name: JOB_NAMES.leaseDeduction,
          data: { timezone },
          opts: template,
        },
      );
      await this.queue.upsertJobScheduler(
        `${JOB_NAMES.weeklyClose}:${timezone}`,
        { pattern: closePattern, tz: timezone },
        {
          name: JOB_NAMES.weeklyClose,
          data: { timezone },
          opts: template,
        },
      );
    }
    this.logger.log(
      `Lease deduction @ ${leasePattern}; weekly close @ ${closePattern} for ${timezones.join(', ')}`,
    );
  }
}
