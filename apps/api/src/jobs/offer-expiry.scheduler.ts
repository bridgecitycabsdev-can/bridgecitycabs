import { InjectQueue } from '@nestjs/bullmq';
import { Injectable } from '@nestjs/common';
import type { Queue } from 'bullmq';
import { JOB_NAMES, JOBS_QUEUE } from './job-names.js';

export const OFFER_EXPIRY_SCHEDULER = Symbol('OFFER_EXPIRY_SCHEDULER');

export type OfferExpiryJob = {
  offerId: string;
  bookingId: string;
  driverId: string;
  delayMs: number;
};

export interface OfferExpiryScheduler {
  schedule(job: OfferExpiryJob): Promise<void>;
  cancel(offerId: string): Promise<void>;
}

@Injectable()
export class BullOfferExpiryScheduler implements OfferExpiryScheduler {
  constructor(@InjectQueue(JOBS_QUEUE) private readonly queue: Queue) {}

  async schedule(job: OfferExpiryJob) {
    const delay = Math.max(0, Math.floor(job.delayMs));
    try {
      await this.queue.add(
        JOB_NAMES.offerExpire,
        { offerId: job.offerId, bookingId: job.bookingId, driverId: job.driverId },
        {
          delay,
          jobId: job.offerId,
          removeOnComplete: 50,
          removeOnFail: 20,
        },
      );
    } catch (error) {
      const message = error instanceof Error ? error.message : '';
      if (!/already exists|jobid/i.test(message)) throw error;
    }
  }

  async cancel(offerId: string) {
    try {
      await this.queue.remove(offerId);
    } catch (error) {
      const message = error instanceof Error ? error.message : '';
      if (/locked|active|missing|not exist/i.test(message)) return;
      throw error;
    }
  }
}

@Injectable()
export class NoopOfferExpiryScheduler implements OfferExpiryScheduler {
  async schedule() {}

  async cancel() {}
}
