-- Day 10 guards (create-only; not expressible in Prisma schema alone).

-- Prefer the ops-friendly name; drop Prisma's auto name if present.
DROP INDEX IF EXISTS "WebhookEvent_provider_eventId_key";
CREATE UNIQUE INDEX one_webhook_event ON "WebhookEvent" ("provider", "eventId");

-- a driver can't be settled twice for the same pending amount simultaneously
CREATE UNIQUE INDEX one_pending_payout_per_driver
  ON "DriverPayout" ("driverId") WHERE status = 'PENDING';

-- closing lines are append-only once written, same pattern as the ledger
CREATE TRIGGER closing_line_immutable BEFORE UPDATE OR DELETE ON "ClosingLine"
  FOR EACH ROW EXECUTE FUNCTION forbid_ledger_mutation();
