import { InjectQueue } from '@nestjs/bullmq';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Queue } from 'bullmq';
import { DISPATCH_RETRY_MS, JOB_NAMES, JOBS_QUEUE } from './job-names.js';

export const DISPATCH_QUEUE = Symbol('DISPATCH_QUEUE');

export interface DispatchQueue {
  enqueueAttempt(bookingId: string, n: number, delayMs?: number): Promise<void>;
  scheduleRelease(bookingId: string, scheduledAt: Date): Promise<void>;
}

export function dispatchAttemptJobId(bookingId: string, n: number) {
  return `dispatch:${bookingId}:${n}`;
}

export function scheduledReleaseJobId(bookingId: string) {
  return `scheduled:${bookingId}`;
}

@Injectable()
export class BullDispatchQueue implements DispatchQueue {
  constructor(
    @InjectQueue(JOBS_QUEUE) private readonly queue: Queue,
    private readonly config: ConfigService,
  ) {}

  enqueueAttempt(bookingId: string, n: number, delayMs = 0) {
    return addOnce(this.queue, JOB_NAMES.dispatchAttempt, { bookingId, n }, {
      jobId: dispatchAttemptJobId(bookingId, n),
      delay: Math.max(0, Math.floor(delayMs)),
      removeOnComplete: true,
      removeOnFail: 20,
    });
  }

  scheduleRelease(bookingId: string, scheduledAt: Date) {
    const leadMs = leadMinutes(this.config) * 60_000;
    const delay = Math.max(0, scheduledAt.getTime() - leadMs - Date.now());
    return addOnce(this.queue, JOB_NAMES.scheduledRelease, { bookingId }, {
      jobId: scheduledReleaseJobId(bookingId),
      delay,
      removeOnComplete: true,
      removeOnFail: 20,
    });
  }
}

@Injectable()
export class NoopDispatchQueue implements DispatchQueue {
  async enqueueAttempt() {}

  async scheduleRelease() {}
}

export function leadMinutes(config: ConfigService) {
  const scheduled = readInt(config, 'SCHEDULE_LEAD_MINUTES');
  if (scheduled != null) return scheduled;
  return readInt(config, 'BOOKING_MIN_LEAD_MINUTES') ?? 15;
}

function readInt(config: ConfigService, key: string) {
  const raw = config.get<string | number>(key);
  if (raw === undefined || raw === '') return null;
  const value = typeof raw === 'number' ? raw : Number(raw);
  if (!Number.isFinite(value) || value < 0) return null;
  return Math.floor(value);
}

async function addOnce(
  queue: Queue,
  name: string,
  data: Record<string, unknown>,
  opts: {
    jobId: string;
    delay: number;
    removeOnComplete: boolean;
    removeOnFail: number;
  },
) {
  try {
    await queue.add(name, data, opts);
  } catch (error) {
    const message = error instanceof Error ? error.message : '';
    if (!/already exists|job.?id|duplicate/i.test(message)) throw error;
  }
}

export { DISPATCH_RETRY_MS };
