-- AuditLog rows can contain phone numbers and other personal information.
-- Agree a retention period with counsel before production. The log itself is append-only.
CREATE FUNCTION forbid_audit_mutation() RETURNS trigger AS $$
BEGIN RAISE EXCEPTION 'audit log is append-only'; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_log_immutable BEFORE UPDATE OR DELETE ON "AuditLog"
  FOR EACH ROW EXECUTE FUNCTION forbid_audit_mutation();
