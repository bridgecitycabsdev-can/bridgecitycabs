ALTER TABLE "LedgerEntry" ADD CONSTRAINT entry_nonzero CHECK ("amountCents" <> 0);

CREATE UNIQUE INDEX one_captured_payment_per_booking
  ON "Payment" ("bookingId") WHERE status = 'CAPTURED';

-- every transaction must balance, checked at commit
CREATE FUNCTION assert_txn_balanced() RETURNS trigger AS $$
DECLARE s bigint;
BEGIN
  SELECT COALESCE(SUM("amountCents"),0) INTO s FROM "LedgerEntry" WHERE "transactionId" = NEW."transactionId";
  IF s <> 0 THEN RAISE EXCEPTION 'ledger transaction % is unbalanced (sum=%)', NEW."transactionId", s; END IF;
  RETURN NULL;
END $$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER ledger_entry_balanced
  AFTER INSERT ON "LedgerEntry" DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION assert_txn_balanced();

-- immutability (reuse for both tables)
CREATE FUNCTION forbid_ledger_mutation() RETURNS trigger AS $$
BEGIN RAISE EXCEPTION 'ledger is append-only'; END $$ LANGUAGE plpgsql;

CREATE TRIGGER ledger_entry_immutable BEFORE UPDATE OR DELETE ON "LedgerEntry"
  FOR EACH ROW EXECUTE FUNCTION forbid_ledger_mutation();
CREATE TRIGGER ledger_txn_immutable BEFORE UPDATE OR DELETE ON "LedgerTransaction"
  FOR EACH ROW EXECUTE FUNCTION forbid_ledger_mutation();
CREATE TRIGGER ledger_entry_no_truncate BEFORE TRUNCATE ON "LedgerEntry"
  FOR EACH STATEMENT EXECUTE FUNCTION forbid_ledger_mutation();
