export const JOBS_QUEUE = 'bridgecabs';

export const JOB_NAMES = {
  presenceSweep: 'presence-sweep',
  locationFlush: 'location-flush',
  idempotencyPurge: 'idempotency-purge',
  locationRetention: 'location-retention',
  paymentPendingAlert: 'payment-pending-alert',
  ledgerIntegrity: 'ledger-integrity',
  leaseDeduction: 'lease-deduction',
  weeklyClose: 'weekly-close',
  dailyStatsRollup: 'daily-stats-rollup',
  buildBookingReport: 'build-booking-report',
  invoiceOverdue: 'invoice-overdue',
  nightlyDbBackup: 'nightly-db-backup',
  offerExpire: 'offer-expire',
  dispatchAttempt: 'dispatch-attempt',
  stripeWebhook: 'stripe-webhook',
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
/** 06:00 UTC — count stuck PAYMENT_PENDING bookings for the dispatch header. */
export const PAYMENT_PENDING_ALERT_PATTERN = '0 6 * * *';
/** 06:15 UTC — global ledger sum must be zero. */
export const LEDGER_INTEGRITY_PATTERN = '15 6 * * *';
/** 06:30 UTC — flip past-due SENT/PARTIALLY_PAID invoices to OVERDUE. */
export const INVOICE_OVERDUE_PATTERN = '30 6 * * *';
/** 03:00 UTC — independent pg_dump → R2 (migrator URL; not the app role). */
export const NIGHTLY_DB_BACKUP_PATTERN = '0 3 * * *';
