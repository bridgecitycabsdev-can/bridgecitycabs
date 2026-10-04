import { InjectQueue } from '@nestjs/bullmq';
import { Injectable } from '@nestjs/common';
import type { Queue } from 'bullmq';
import { withCorrelationId } from '../observability/correlation.js';
import { JOB_NAMES, JOBS_QUEUE } from './job-names.js';

export const STRIPE_WEBHOOK_QUEUE = Symbol('STRIPE_WEBHOOK_QUEUE');

export type StripeWebhookJob = {
  eventId: string;
  correlationId?: string;
};

export interface StripeWebhookQueue {
  enqueue(job: StripeWebhookJob): Promise<void>;
}

@Injectable()
export class BullStripeWebhookQueue implements StripeWebhookQueue {
  constructor(@InjectQueue(JOBS_QUEUE) private readonly queue: Queue) {}

  enqueue(job: StripeWebhookJob) {
    return this.queue
      .add(
        JOB_NAMES.stripeWebhook,
        withCorrelationId({ eventId: job.eventId }),
        {
          jobId: `stripe-webhook:${job.eventId}`,
          removeOnComplete: 50,
          removeOnFail: 50,
          attempts: 5,
          backoff: { type: 'exponential', delay: 2_000 },
        },
      )
      .then(() => undefined);
  }
}

/** Unit tests / NODE_ENV=test — process synchronously via injected handler. */
@Injectable()
export class SyncStripeWebhookQueue implements StripeWebhookQueue {
  constructor(
    private readonly processEvent: (eventId: string) => Promise<void>,
  ) {}

  async enqueue(job: StripeWebhookJob) {
    await this.processEvent(job.eventId);
  }
}
