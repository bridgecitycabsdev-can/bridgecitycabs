-- Allow ClosingLine rewrite while ClosingPeriod is DRAFT; keep FINALIZED immutable.

CREATE OR REPLACE FUNCTION forbid_finalized_closing_line_mutation() RETURNS trigger AS $$
DECLARE st text;
BEGIN
  SELECT status::text INTO st
  FROM "ClosingPeriod"
  WHERE id = COALESCE(OLD."closingPeriodId", NEW."closingPeriodId");
  IF st = 'FINALIZED' THEN
    RAISE EXCEPTION 'closing lines are immutable once finalized';
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS closing_line_immutable ON "ClosingLine";
CREATE TRIGGER closing_line_immutable BEFORE UPDATE OR DELETE ON "ClosingLine"
  FOR EACH ROW EXECUTE FUNCTION forbid_finalized_closing_line_mutation();
