export const JOBS_QUEUE = 'bridgecabs';

export const JOB_NAMES = {
  presenceSweep: 'presence-sweep',
  locationFlush: 'location-flush',
  idempotencyPurge: 'idempotency-purge',
  locationRetention: 'location-retention',
  offerExpire: 'offer-expire',
  dispatchAttempt: 'dispatch-attempt',
  scheduledRelease: 'scheduled-release',
  scheduledSweep: 'scheduled-sweep',
} as const;

export const PRESENCE_SWEEP_EVERY_MS = 15_000;
export const LOCATION_FLUSH_EVERY_MS = 10_000;
export const LOCATION_FLUSH_BATCH = 500;
export const SCHEDULED_SWEEP_EVERY_MS = 60_000;
export const DISPATCH_RETRY_MS = 5_000;

/** Midnight UTC. Retention follows ten minutes later. */
export const IDEMPOTENCY_PURGE_PATTERN = '0 0 * * *';
export const LOCATION_RETENTION_PATTERN = '10 0 * * *';
