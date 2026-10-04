# Day 14 — Production hardening (design)

## Design decisions

- **A compromised app credential must not disable the ledger's safety net.** Day 9 triggers stop `UPDATE`/`DELETE` on ledger and audit tables at the database level, but a role with `ALTER TABLE` could drop those triggers. The fix is a second role with no DDL privileges for the running app (`bridgecabs_app`), and a separate migration-only role (`bridgecabs_migrator`) used exclusively by the deploy pipeline — never embedded in a running container. Triggers and grants are independent layers: neither alone is enough.

- **Backups aren't real until a restore has been tested.** A managed Postgres provider's point-in-time recovery is a feature you're trusting, not one you've verified. Day 14 includes restoring a dump into a clean database and running the suite against it.

- **Staging must not be production with different paint.** Separate database, separate Redis, separate payment gateway keys, separate push credentials. Sharing any of these means a staging bug can touch real money or send a real driver a real push notification.

- **Observability should answer "what happened to this one request,"** not just "an error occurred." A correlation ID that threads from the HTTP request through the async matching job through the webhook handler is what makes the Day 6/10 async flows debuggable in production, where you can't watch three terminal windows.

- **Load testing targets the hard concurrency paths** — the Day 6 Lua reservation and the Day 4 optimistic lock — not just raw request throughput, which is the less interesting question for this system.

- **The legacy route sweep is a checklist, not a rebuild.** Its job is to surface anything missed, not to force building features the project deliberately chose not to carry forward.

## Restricted database roles

Script: [`infrastructure/db-roles.sql`](../infrastructure/db-roles.sql).

Run once per environment as the provider admin account (not via Prisma migrations). Afterward:

| Role | Used by | Rights |
|---|---|---|
| `bridgecabs_migrator` | `prisma migrate deploy` in CI only | Full DDL + DML |
| `bridgecabs_app` | Running API container `DATABASE_URL` | DML only; no `UPDATE`/`DELETE`/`TRUNCATE` on append-only tables; no DDL |

Append-only revoke list: `LedgerEntry`, `LedgerTransaction`, `BookingStatusHistory`, `AuditLog`, `SupportTicketMessage`, `ClosingLine`.

## Backups and restore drill

### Confirm the host's PITR window first

Managed Postgres PITR retention differs sharply by plan. Confirm the real number for your plan before relying on it:

| Provider | Typical PITR / history window (confirm in console) |
|---|---|
| **Neon** | Free: **6 hours** (1 GB history cap). Launch: up to **7 days**. Scale: up to **30 days**. |
| **Supabase** | Daily backups on Pro; PITR is a **paid add-on** (commonly 7 / 14 / 28 days). Free tier is not a multi-day safety net. |

A free tier's window may be hours, not days.

### Independent nightly dump to R2

BullMQ job `nightly-db-backup` (03:00 UTC), same scheduler pattern as lease deductions / integrity checks:

1. `pg_dump` using `MIGRATE_DATABASE_URL` (migrator role — read access to everything; dump does not write).
2. gzip → upload to `backups/bridgecabs_yyyy-MM-dd.sql.gz` via object storage (R2 in prod).
3. Prune objects older than `BACKUP_RETENTION_DAYS` (default 30).

The migrator URL lives only on the job worker / CI secrets — never on the public API container as the app `DATABASE_URL`.

### Restore drill (do this, do not just plan it)

```bash
# download today's object from R2, or produce a local dump:
#   pg_dump "$MIGRATE_DATABASE_URL" | gzip > backup.sql.gz

./infrastructure/restore-drill.sh backup.sql.gz
```

Manual equivalent:

```bash
docker run -d --name restore-test -e POSTGRES_PASSWORD=test -p 5433:5432 postgis/postgis:16-3.4
# wait until ready, then:
gunzip -c backup.sql.gz | PGPASSWORD=test psql -h localhost -p 5433 -U postgres

DATABASE_URL="postgresql://postgres:test@localhost:5433/postgres" pnpm --filter api test:e2e
docker rm -f restore-test
```

If e2e does not pass against the restored database, the backup process has a problem worth finding **today**, while there is no real data riding on it.

## Environment split

Staging must not be production with different paint. Sharing any of Postgres, Redis, Stripe, Firebase, or R2 means a staging bug can touch real money or notify a real driver.

| | Dev | Staging | Production |
|---|---|---|---|
| Postgres | local Docker | separate Neon project/branch | separate Neon project |
| Redis | local Docker | separate Upstash DB | separate Upstash DB |
| Stripe | test keys | test keys | **live** keys |
| Firebase | shared dev project | separate staging project | separate production project |
| R2 bucket | n/a or local | `bridgecabs-staging` | `bridgecabs-production` |
| Google Maps keys | dev-restricted | staging-restricted | production-restricted |
| Domain | localhost | `staging-api.bridgecitycabs.com` | `api.bridgecitycabs.com` |

Canonical templates (empty values only, committed):

- [`infrastructure/env/.env.staging.example`](../infrastructure/env/.env.staging.example)
- [`infrastructure/env/.env.production.example`](../infrastructure/env/.env.production.example)

Actual secrets live only in Railway/Render’s environment variable UI per environment — never in a filled file in git.

### Staging data sanitization

If you use Neon’s branching to seed staging from a production-shaped schema, **never** leave real passenger phones, driver documents, or payment references in it. After any data-bearing branch/restore:

```bash
cd apps/api
DATABASE_URL="<staging migrator/admin url>" pnpm exec tsx scripts/sanitize-staging.ts --confirm-staging
```

The script replaces names/phones/emails with synthetic values, rewrites document `storageKey`s and Stripe refs, clears sessions/device tokens, and truncates append-only tables that may hold PII (`AuditLog`, ticket messages, webhook payloads). It refuses URLs that look like production.

## Observability

- **Sentry** — `initSentry()` before Nest bootstrap; `ApiExceptionFilter` calls `Sentry.captureException` for 5xx. No ad hoc `captureException` in handlers. `beforeSend` strips `password` / `code` from request data and drops `user.ip_address`. Env: `SENTRY_DSN`.
- **Pino** (`nestjs-pino`) — `genReqId` from `x-request-id` (or a new UUID), redacts `authorization`, `password`, `code`, `phone`, `email`. Each log line carries `correlationId`.
- **Correlation through async work** — `AsyncLocalStorage` + `withCorrelationId()` on BullMQ payloads for `dispatch-attempt`, `offer-expire`, `scheduled-release`, booking reports, and `stripe-webhook`. The worker rebinds ALS and logs `correlationId` on every job start so matching → webhook is one thread in production logs.

## Rate-limit audit (Day 14 Step 6)

Global default: Nest `ThrottlerGuard` as `APP_GUARD`, **100 req / 60s**, storage = `RedisThrottlerStorage` (not in-memory). Controllers without an explicit `@Throttle` rely on this deliberately — glance the `@Throttle`/`@Public`-less list if adding expensive endpoints.

| Endpoint class | Control |
|---|---|
| `POST /auth/login` | `@Throttle(5/60s)` + Redis storage |
| `POST /auth/otp/*` | Redis daily caps / resend cooldown / max attempts in `AuthService` (on top of global IP default) |
| `/places/*` | `@Throttle(40/60s)` + `UserThrottlerGuard` (Google-billed) |
| `POST /bookings`, `POST /passenger/bookings` | `@Throttle(10/60s)` + `UserThrottlerGuard` beside idempotency keys |
| `POST /driver/sos`, `POST /passenger/sos` | `@SkipThrottle` — not throttled for panic UX; `SOS_DEDUPE_WINDOW_SECONDS` (default 30) updates lat/lng on the open alert instead of inserting another |
| `POST /webhooks/stripe` | `@SkipThrottle` (Stripe IPs are legitimate; signature is the auth control); `express.raw({ limit: '1mb' })` body cap |
| List/search | `PageQuery.pageSize` `@Max(100)` via `normalizePage` on Day 3 modules and later lists (invoices, payouts, leases, promo-codes); corporate typeahead uses a hard `take: 25` |

## Load test (Day 14 Step 7)

Target the Day 6 matching path (Redis Lua `reserveOffer` + optimistic accept), not raw CRUD throughput.

### Install k6

```bash
# macOS
brew install k6
# Windows: winget install k6 --source winget   (or see https://k6.io)
```

### Raise throttles for the run only

Default Redis throttles (100/min global, 10/min booking create) will 429 a 50-VU script. Restart the API with:

```bash
THROTTLE_LIMIT=100000 BOOKING_THROTTLE_LIMIT=1000 pnpm --filter api start:dev
```

Do **not** ship those values to production.

### Seed far more available drivers than a real fleet

```bash
cd apps/api
pnpm exec tsx scripts/spawn-sim-drivers.ts --count 100 --branch <branchId> --behavior accept
```

This upserts load drivers/vehicles, mints JWTs (avoids OTP IP caps), starts shifts, opens **N sockets in one process**, and writes `loadtest/passenger-tokens.json` for k6. Leave the process running so location pings keep drivers in the geo set.

### Run k6

```bash
# from repo root — BRANCH_ID / VEHICLE_TYPE_ID from seed (Sedan)
API_URL=http://localhost:3000 BRANCH_ID=<branchId> VEHICLE_TYPE_ID=<sedanId> \
  k6 run loadtest/booking-matching.js
```

### Pass condition (Postgres, not just p95)

Zero constraint-violation noise in API logs, **and** this query returns **no rows**:

```sql
select "driverId", count(*) from "Booking"
where status in ('MATCHED','DRIVER_ASSIGNED','DRIVER_ARRIVING','DRIVER_ARRIVED','TRIP_STARTED')
group by "driverId" having count(*) > 1;
```

Same check for open offers: `loadtest/check-invariants.sql`.

## CI and deploy (Day 14 Step 8)

Workflow: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml).

| Job | When | What |
|---|---|---|
| `design-tokens` | every PR/push | Build tokens; fail if generated files are stale |
| `test` | every PR/push | PostGIS + Redis services → lint → typecheck → `prisma migrate deploy` → unit + **full** `test:e2e` |
| `deploy-staging` | push to `main` after green | Migrator-role migrate → host deploy → `scripts/smoke-test.ts` against staging |
| `deploy-production` | `workflow_dispatch` + approval (`environment: production`) | Same shape as staging; **not** automatic on every main push |

Smoke test (`apps/api/scripts/smoke-test.ts`): `GET /health/ready`, login with the dedicated smoke account, `GET /branches` — each must 200 within a few seconds. Catches “deployed but `DATABASE_URL` wrong” before real traffic.

## Health and graceful shutdown (Day 14 Step 9)

| Path | Meaning | Host probe |
|---|---|---|
| `GET /api/v1/health` | Liveness — process is up | Optional |
| `GET /api/v1/health/ready` | Readiness — `SELECT 1` + Redis `PING` both succeed | **Use this** on Railway/Render |

`enableShutdownHooks()` plus `SIGTERM`/`SIGINT` handlers call `app.close()` so in-flight requests drain and Prisma/Redis pools close before exit — required for zero-downtime deploys that would otherwise kill mid-booking.

Required GitHub secrets (staging/production): `STAGING_MIGRATE_DATABASE_URL`, `STAGING_SMOKE_EMAIL`, `STAGING_SMOKE_PASSWORD`, `PRODUCTION_MIGRATE_DATABASE_URL`, `PRODUCTION_SMOKE_EMAIL`, `PRODUCTION_SMOKE_PASSWORD`, optional `RAILWAY_TOKEN` / `STRIPE_TEST_KEY`.

## Security sweep (Day 14 Step 10)

| Control | Implementation |
|---|---|
| CORS / WS origins | `WS_ALLOWED_ORIGINS` → `allowedWsOrigins()` for HTTP CORS and Socket.IO. Rejects `*` and embedded wildcards. Templates: localhost + staging/prod web domains only. |
| Security headers | `helmet()` in `main.ts` |
| Body size | Global `express.json` / `urlencoded` **512kb**; Stripe webhook `express.raw({ limit: '1mb' })` on `/api/v1/webhooks/stripe` only |
| Raw SQL | All `$queryRaw` / `$executeRaw` in `apps/api/src` use Prisma tagged templates (optimistic locks, invoice/ticket seq, promo redeem, rating avg, ledger integrity). No string-concat SQL. |
| Dependency updates | `.github/dependabot.yml` (weekly npm + Actions). Track `pnpm audit` high/critical; transitive `braces` / `uuid` / `deepmerge-ts` findings as of Day 14 are upstream of firebase-admin / shadcn — re-check after Dependabot PRs. |
| Secret scan | `.gitleaks.toml` + CI job `gitleaks (full history)` (`fetch-depth: 0`). Local: `gitleaks detect --source . --log-opts="--all"`. |
| Legacy routes | [`docs/legacy-route-mapping.md`](./legacy-route-mapping.md) — every Day 0–style surface accounted for (done / deferred / not applicable). |

### Throttle exceptions (documented)

| Route | Why skipped |
|---|---|
| `POST /driver/sos`, `POST /passenger/sos` | Panic UX must not 429; `SOS_DEDUPE_WINDOW_SECONDS` (default 30) collapses duplicates |
| `POST /webhooks/stripe` | Stripe retries from many IPs; signature + 1mb raw body are the controls |
| `GET /health`, `GET /health/ready` | Probe endpoints |

Every other mutating controller relies on `APP_GUARD` `ThrottlerGuard` (100/60s Redis) and/or a tighter `@Throttle` (login, bookings, places).

## Verify checklist (Day 14 Steps 11–12)

Ops items that cannot be fully automated in unit tests — run against staging/prod once, then keep the scripts:

1. **Role restriction** — as `bridgecabs_app`: `DELETE FROM "AuditLog";` (and the other append-only tables) must fail; DDL must fail.
2. **Backup restore** — `./infrastructure/restore-drill.sh backup.sql.gz` then e2e against the restored DB.
3. **Env credential split** — diff staging vs production host env lists; Stripe/Firebase/DB/Redis/maps keys must all differ.
4. **Sentry + correlation** — trigger a 5xx locally; confirm Sentry event and pino line share the same `correlationId`.
5. **Load test** — 100 sim drivers + `k6 run loadtest/booking-matching.js`; `loadtest/check-invariants.sql` returns zero rows.
6. **gitleaks** — full history clean; Day 0 exposed credential confirmed rotated out-of-band.
7. **CI** — `pnpm --filter api test:e2e` green on ephemeral PostGIS + Redis; deploy order lint → typecheck → e2e → migrate → deploy → smoke.
