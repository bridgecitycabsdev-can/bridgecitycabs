-- Restricted database roles for BridgeCabs.
--
-- Run ONCE per environment by hand, connected as the Postgres owner/admin
-- account your provider (Neon/Supabase) gives you. This is role management —
-- never run it via `prisma migrate`.
--
-- Generate passwords separately:
--   openssl rand -base64 32
--
-- Day 9 append-only triggers and these grants are two independent layers:
-- the trigger stops the statement; the missing grant stops the role from
-- ever issuing a statement (or DDL that could drop the trigger). Neither
-- alone is enough.

CREATE ROLE bridgecabs_app LOGIN PASSWORD '<generate with: openssl rand -base64 32>';
CREATE ROLE bridgecabs_migrator LOGIN PASSWORD '<generate separately>';

GRANT CONNECT ON DATABASE bridgecabs TO bridgecabs_app, bridgecabs_migrator;
GRANT USAGE ON SCHEMA public TO bridgecabs_app, bridgecabs_migrator;

-- migrator: full DDL + DML, used ONLY by `prisma migrate deploy` in CI,
-- never by the running app
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO bridgecabs_migrator;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO bridgecabs_migrator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO bridgecabs_migrator;

-- app: ordinary row-level DML everywhere, zero DDL rights, full stop
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO bridgecabs_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO bridgecabs_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO bridgecabs_app;

-- then strip write access entirely on the append-only tables; INSERT stays,
-- since that's how they grow
REVOKE UPDATE, DELETE, TRUNCATE ON
  "LedgerEntry", "LedgerTransaction", "BookingStatusHistory",
  "AuditLog", "SupportTicketMessage", "ClosingLine"
FROM bridgecabs_app;

-- ---------------------------------------------------------------------------
-- Verify locally after running against Neon/Supabase (expect permission denied):
--
--   PGPASSWORD=<app password> psql -h <host> -U bridgecabs_app -d bridgecabs \
--     -c "DELETE FROM \"AuditLog\";"
--   PGPASSWORD=<app password> psql -h <host> -U bridgecabs_app -d bridgecabs \
--     -c "ALTER TABLE \"AuditLog\" ADD COLUMN x text;"
--
-- In CI: DATABASE_URL for `prisma migrate deploy` = migrator connection string
-- (CI secret only). Deployed container DATABASE_URL = app role; never the migrator.
-- ---------------------------------------------------------------------------
