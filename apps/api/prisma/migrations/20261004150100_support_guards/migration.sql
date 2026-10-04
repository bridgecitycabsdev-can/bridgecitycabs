-- Day 12 guards (create-only; not expressible in Prisma schema alone).

-- Support ticket messages are append-only (reuses Day 9 forbid_ledger_mutation).
CREATE TRIGGER ticket_message_immutable
  BEFORE UPDATE OR DELETE ON "SupportTicketMessage"
  FOR EACH ROW EXECUTE FUNCTION forbid_ledger_mutation();
