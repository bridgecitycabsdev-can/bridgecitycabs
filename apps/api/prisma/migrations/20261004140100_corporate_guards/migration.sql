-- Day 11 guards (create-only; not expressible in Prisma schema alone).

-- Prefer the ops-friendly name; drop Prisma's auto name if present.
DROP INDEX IF EXISTS "InvoiceLine_bookingId_key";
CREATE UNIQUE INDEX one_invoice_line_per_booking ON "InvoiceLine" ("bookingId");

-- an invoice's lines must sum to its stated totals (defence in depth, mirrors the ledger balance trigger)
CREATE FUNCTION assert_invoice_totals() RETURNS trigger AS $$
DECLARE s_sub bigint; s_tax bigint;
BEGIN
  SELECT COALESCE(SUM("subtotalCents"),0), COALESCE(SUM("taxCents"),0)
    INTO s_sub, s_tax FROM "InvoiceLine" WHERE "invoiceId" = NEW."invoiceId";
  IF s_sub <> (SELECT "subtotalCents" FROM "Invoice" WHERE id = NEW."invoiceId")
     OR s_tax <> (SELECT "taxCents" FROM "Invoice" WHERE id = NEW."invoiceId") THEN
    RAISE EXCEPTION 'invoice % lines do not match stated totals', NEW."invoiceId";
  END IF;
  RETURN NULL;
END $$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER invoice_lines_match_totals
  AFTER INSERT ON "InvoiceLine" DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION assert_invoice_totals();
