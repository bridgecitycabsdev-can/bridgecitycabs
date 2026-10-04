import { InjectQueue } from '@nestjs/bullmq';
import { Injectable } from '@nestjs/common';
import type { Queue } from 'bullmq';
import { JOB_NAMES, JOBS_QUEUE } from './job-names.js';

export const REPORT_QUEUE = Symbol('REPORT_QUEUE');

export type BuildBookingReportJob = {
  reportId: string;
  /** JSON-serialized Prisma where (Date → ISO string). */
  where: Record<string, unknown>;
  format: 'csv' | 'pdf' | 'json';
};

export interface ReportQueue {
  enqueueBookingReport(job: BuildBookingReportJob): Promise<void>;
}

@Injectable()
export class BullReportQueue implements ReportQueue {
  constructor(@InjectQueue(JOBS_QUEUE) private readonly queue: Queue) {}

  enqueueBookingReport(job: BuildBookingReportJob) {
    return this.queue
      .add(JOB_NAMES.buildBookingReport, job, {
        jobId: `booking-report:${job.reportId}`,
        removeOnComplete: 50,
        removeOnFail: 20,
        attempts: 3,
        backoff: { type: 'exponential', delay: 2_000 },
      })
      .then(() => undefined);
  }
}

@Injectable()
export class NoopReportQueue implements ReportQueue {
  async enqueueBookingReport() {}
}
