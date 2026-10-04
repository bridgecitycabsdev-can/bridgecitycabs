# How to test today

## Stack

```bash
docker compose up -d
pnpm --filter api start:dev
pnpm --filter api-client generate
pnpm --filter dispatch-web dev
```

`docker compose` brings up Postgres and Redis. The API watches on port 3000; dispatch-web is usually http://localhost:5173. Regenerate the OpenAPI client after the API is up (`/docs-json`).

## Automated tests

```bash
pnpm test
pnpm --filter api test:e2e
```

`pnpm test` runs API and dispatch-web unit suites. Flutter:

```bash
(cd packages/bridgecabs_core && flutter test)
(cd apps/driver-app && flutter test)
(cd apps/passenger-app && flutter test)
```

## Backend and ledger

```bash
pnpm --filter api test:e2e
docker compose exec postgres psql -U bridgecabs -d bridgecabs
```

```sql
-- the invariant: this must always be 0
select sum("amountCents") from "LedgerEntry";

-- one trip's postings
select a.key, e."amountCents" from "LedgerEntry" e
join "FinancialAccount" a on a.id = e."accountId" where e."transactionId" = '<id>';

-- balances, positive means the company owes the driver
select a.key, -sum(e."amountCents") as balance from "LedgerEntry" e
join "FinancialAccount" a on a.id = e."accountId" group by a.key;

-- these three must each ERROR
update "LedgerEntry" set "amountCents" = 1;
delete from "LedgerTransaction";
begin; insert into "LedgerEntry"(id,"transactionId","accountId","amountCents") values (gen_random_uuid(),'<txn>','<acct>',100); commit;
```

### Sim driver (full cash trip)

From `apps/api`, with the API up:

```bash
pnpm exec tsx scripts/sim-driver.ts --phone +14035550100 --behavior accept --vehicle LTH111
# After accept, walk arriving → arrived → start → complete → cash-collected and print balance:
pnpm exec tsx scripts/sim-driver.ts --phone +14035550100 --complete --vehicle LTH111
pnpm exec tsx scripts/sim-driver.ts --phone +14035550101 --behavior ignore --vehicle LTH112
```

## Push

1. Firebase console → Messaging → **Send test message** to a device token (quick sanity check).
2. Real payload (incl. TTL) through `PushService`:

```bash
cd apps/api
pnpm exec tsx scripts/send-test-push.ts <userId>
pnpm exec tsx scripts/send-test-push.ts <userId> --ttl-seconds 30
```

Uses `FIREBASE_SERVICE_ACCOUNT_JSON` when set; otherwise logs via the console provider. Android emulators need a **Google Play** image for FCM. iOS needs a **physical phone**.

## Background location (Android emulator)

```bash
adb -s emulator-5554 emu geo fix -112.8418 49.6935          # longitude first
adb -s emulator-5554 shell input keyevent KEYCODE_HOME       # send the app to the background
# should keep changing while on shift:
watch -n 2 "docker compose exec -T redis redis-cli HGET driver:<id> ts"
adb -s emulator-5554 shell dumpsys deviceidle force-idle     # simulate Doze
adb logcat | grep -i geolocator
```

Change the location with another `geo fix` and confirm the map on the web console follows it. Repeat once on a **real phone with the screen locked** — emulators are far more forgiving.

List devices, then run each app:

```bash
flutter devices
flutter run -d <id> --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Use `http://10.0.2.2:3000` on an Android emulator. On an iOS simulator use `http://localhost:3000`. A physical phone needs your LAN or tunnel URL for both `API_BASE_URL` and `WS_URL`.

## Stripe card payments (Day 10)

Needs the [Stripe CLI](https://stripe.com/docs/stripe-cli) and **test-mode** keys in `apps/api/.env` (`sk_test_…`, `pk_test_…`). Never commit secrets.

```bash
docker compose up -d && pnpm --filter api start:dev
```

Separate terminal (keep running):

```bash
stripe login
stripe listen --forward-to localhost:3000/api/v1/webhooks/stripe
```

Copy the printed `whsec_…` into `STRIPE_WEBHOOK_SECRET` and restart the API.

### Card booking walk

Use [Stripe’s test card numbers](https://docs.stripe.com/testing#cards) (e.g. `4242 4242 4242 4242`).

```bash
TOKEN=$(curl -s -X POST localhost:3000/api/v1/auth/otp/verify -H "Content-Type: application/json" \
  -d '{"phone":"+14035550199","code":"000000"}' | jq -r .accessToken)

# create a SetupIntent, then attach a test card via Stripe’s client SDK (or API) in test mode
curl -s -X POST localhost:3000/api/v1/passenger/payment-methods/setup-intent \
  -H "Authorization: Bearer $TOKEN" | jq

# after setup_intent.succeeded (watch stripe listen), list saved methods
curl -s localhost:3000/api/v1/passenger/payment-methods \
  -H "Authorization: Bearer $TOKEN" | jq

# book with the saved payment method once it exists (fill stops, vehicleTypeId, quoteToken)
curl -s -X POST localhost:3000/api/v1/passenger/bookings -H "Authorization: Bearer $TOKEN" \
  -H "Idempotency-Key: $(uuidgen)" -H "Content-Type: application/json" \
  -d '{"paymentMethod":"CARD","paymentMethodId":"<ppm-uuid>", ...stops, vehicleTypeId, quoteToken}'
```

Complete the trip with the Day 9 driver simulator `--complete` flag. Watch the `stripe listen` terminal: the booking must reach `CLOSED` only after `payment_intent.succeeded`, not immediately when the capture API returns.

Optional synthetic events (no real card):

```bash
stripe trigger payment_intent.succeeded
stripe trigger payment_intent.payment_failed
stripe trigger charge.refunded
```

### Postgres checks

```sql
-- confirm the ledger still balances globally after card trips
select sum("amountCents") from "LedgerEntry";

-- one driver's week, reconciled
select "accountKey","openingCents","movementCents","closingCents"
from "ClosingLine" cl join "ClosingPeriod" cp on cp.id = cl."closingPeriodId"
where cp."branchId" = '<id>' and cp."weekStart" = '<iso>';

-- these two must ERROR (after the week is FINALIZED)
update "ClosingLine" set "closingCents" = 0;
```

Re-finalizing an already-finalized week via the API should return **409**, not 200:

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X POST \
  localhost:3000/api/v1/finance/closing-periods/<id>/finalize \
  -H "Authorization: Bearer $ACCOUNTS_TOKEN"
```

### Webhook dedupe check

```bash
stripe trigger payment_intent.succeeded   # fire once
stripe events resend evt_...              # resend the same event id
```

Confirm in Postgres that only one `LedgerTransaction` exists for that booking’s `TRIP_CARD` kind despite two deliveries:

```sql
select count(*) from "LedgerTransaction"
where kind = 'TRIP_CARD' and "sourceType" = 'BOOKING' and "sourceId" = '<bookingId>';
```

### Finance / lease smoke (accounts token)

```bash
# on-demand previous-week close
curl -s -X POST "localhost:3000/api/v1/finance/closing-periods/run" \
  -H "Authorization: Bearer $ACCOUNTS_TOKEN" | jq

# settlement
curl -s -X POST "localhost:3000/api/v1/finance/payouts/run" \
  -H "Authorization: Bearer $ACCOUNTS_TOKEN" | jq
```

## Faster timeout drills

In local `apps/api/.env` (not committed), temporarily set:

```env
SEARCH_WINDOW_SECONDS=20
OFFER_TIMEOUT_SECONDS=8
```

Restart the API, run the timeout/no-driver flows, then put the values back (defaults are in `.env.example`: 120 and 15).

## End-of-day verification

Assume Day 9 (`money_*`) and Day 10 (`card_payments_*`) migrations are applied, and Google/Firebase/Stripe keys are restricted. Nothing secret belongs in git.

1. Run one **cash** trip with the simulator (`--complete`). Postgres shows exactly one balanced `TRIP_CASH` transaction.
2. Run one **card** trip (setup intent → book → sim `--complete`). Booking stays `PAYMENT_PENDING` until `payment_intent.succeeded`, then `CLOSED` with one `TRIP_CARD`.
3. Tap **Cash collected** twice quickly → a single payment and ledger transaction.
4. Driver balance matches your hand calculation (`GET /driver/earnings` or the SQL above).
5. Put the driver app in the background, create a job → notification arrives → tap opens the offer screen with the right countdown.
6. Kill the app during an active job, restart → returns to the trip or collect screen.
7. Reverse / refund as an accounts user → `paymentStatus=REFUNDED` and a balanced `REVERSAL`.
8. `select sum("amountCents") from "LedgerEntry";` → **0**.

### Web console (dispatch)

1. Book an **Auto** job → Unassigned → Assigned when a driver accepts.
2. Double-click Book → still one booking (idempotency).
3. Book a **Manual** job → Assign from details.
4. Edit notes on an assigned job → driver snapshot updates.
5. No drivers online → **NO_DRIVER_FOUND** timeout modal.

## Done when (Day 10)

- [ ] `card_payments_and_settlement` and `card_payments_guards` migrations applied
- [ ] Stripe webhook signature verification rejects tampered payloads
- [ ] Authorize, capture, decline, `REQUIRES_ACTION`, refund, and cancel-before-trip all behave correctly
- [ ] Webhook processing is idempotent under a simulated duplicate delivery
- [ ] Card-on-file save, list, default, and delete work
- [ ] Lease deductions post weekly, are idempotent per driver per week, and reduce balance correctly
- [ ] Settlement zeros out exactly the drivers with a positive balance, with no duplicate pending payouts
- [ ] Weekly closing reconciles against raw ledger sums and locks correctly once finalized
- [ ] All twelve tests pass
- [ ] No Stripe secret key or webhook secret in git; only test-mode keys used
- [ ] Committed as `feat(api): stripe card payments, webhooks, lease deductions, settlement and weekly closing`

## Corporate accounts & invoicing (Day 11)

```bash
docker compose up -d && pnpm --filter api start:dev
```

Non-prod seed includes **Prairie Hotel** on the Lethbridge branch (credit limit $250) with two contacts for New Job search.

```bash
# create an account with a small limit, a contact, then try to overshoot it
curl -s -X POST localhost:3000/api/v1/corporate-accounts -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" -d '{"name":"Prairie Hotel","creditLimitCents":10000,"billingCycle":"MONTHLY"}'

curl -s -X POST localhost:3000/api/v1/bookings -H "Authorization: Bearer $TOKEN" \
  -H "Idempotency-Key: $(uuidgen)" -H "Content-Type: application/json" \
  -d '{"paymentMethod":"ACCOUNT","corporateAccountId":"<id>", ...stops, vehicleTypeId}'
# run two or three of these until the limit is hit, confirm CREDIT_LIMIT_EXCEEDED on the one that tips it over

# complete one via the simulator's --complete flag (Day 9), then check its balance
curl -s localhost:3000/api/v1/corporate-accounts/<id>/balance -H "Authorization: Bearer $TOKEN"

# generate an invoice for the period covering today
curl -s -X POST localhost:3000/api/v1/finance/invoices/generate -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" -d '{"corporateAccountId":"<id>","periodStart":"2026-10-01","periodEnd":"2026-11-01"}'

curl -s -X POST localhost:3000/api/v1/finance/invoices/<invoiceId>/record-payment -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" -d '{"amountCents":5000,"method":"E_TRANSFER","reference":"INTERAC-123"}'
```

Confirm AR dropped by exactly the payment, and the global ledger still balances:

```sql
select sum("amountCents") from "LedgerEntry" where "accountId" = (
  select id from "FinancialAccount" where key = 'ACCOUNTS_RECEIVABLE:<accountId>'
);
select sum("amountCents") from "LedgerEntry";   -- always 0

-- this must ERROR (invoice totals trigger)
insert into "InvoiceLine" (id, "invoiceId", "bookingId", "corporateAccountId", "subtotalCents", "taxCents", "totalCents")
  values (gen_random_uuid(), '<invoiceId>', '<some-other-booking>', '<accountId>', 100, 5, 105);
```

```bash
pnpm --filter api exec vitest run src/corporate/day11.spec.ts
```

## Done when (Day 11)

- [ ] `corporate_accounts` and `corporate_guards` migrations applied, including the invoice-totals trigger
- [ ] Credit limit check blocks over-limit bookings; override path is permission-gated and audited
- [ ] Account trips post and close immediately on completion; driver paid regardless of invoice status
- [ ] Account, contact, and group CRUD and search work, branch-scoped
- [ ] Invoice generation is idempotent against double-invoicing a booking (single-account and consolidated)
- [ ] Invoice totals always match their lines, enforced at the database
- [ ] Partial and full payments correctly reduce AR and never touch revenue or GST accounts
- [ ] Overdue sweep runs and flips status correctly
- [ ] All fourteen tests pass (`src/corporate/day11.spec.ts`)
- [ ] Committed as `feat(api): corporate accounts, contacts, groups, invoicing and account billing`

## Promos, ratings, support & SOS (Day 12)

```bash
docker compose up -d && pnpm --filter api start:dev
```

Non-prod seed includes **WELCOME10** (10% off, $5 cap) and one sample resolved lost-item ticket on Lethbridge. Permissions: `promotions.manage`, `ratings.read`, `support.*`, `sos.*` (support/sos also on `customer_care` and `dispatcher`).

```bash
# promo
curl -s -X POST localhost:3000/api/v1/promo-codes -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"code":"WELCOME10","type":"PERCENT","valueBps":1000,"maxDiscountCents":500,"usageLimitTotal":5}'
curl -s -X POST localhost:3000/api/v1/passenger/fares/quotes -H "Authorization: Bearer $PTOKEN" \
  -H "Content-Type: application/json" -d '{..., "promoCode":"WELCOME10"}' | jq '.options[0].discountCents'

# rating, after closing a trip with the Day 9 simulator's --complete flag
curl -s -X POST localhost:3000/api/v1/passenger/bookings/<id>/rate-driver -H "Authorization: Bearer $PTOKEN" \
  -H "Content-Type: application/json" -d '{"stars":5,"comment":"Great ride"}'
curl -s localhost:3000/api/v1/drivers/<driverId> -H "Authorization: Bearer $TOKEN" | jq '.ratingAvg,.ratingCount'

# ticket
curl -s -X POST localhost:3000/api/v1/support/tickets -H "Authorization: Bearer $PTOKEN" \
  -H "Content-Type: application/json" -d '{"subject":"Left my bag","category":"LOST_ITEM","body":"In the back seat"}'
curl -s localhost:3000/api/v1/support/tickets/pending-count -H "Authorization: Bearer $TOKEN"

# sos, watch it arrive on the dispatch socket in another terminal
pnpm --filter api exec tsx scripts/watch-dispatch.ts --branch <branchId>
curl -s -X POST localhost:3000/api/v1/driver/sos -H "Authorization: Bearer $DTOKEN" \
  -H "Content-Type: application/json" -d '{"lat":49.6935,"lng":-112.8418}'
```

Confirm a ticket message can't be edited:

```sql
update "SupportTicketMessage" set body = 'x';   -- must ERROR
```

```bash
pnpm --filter api exec vitest run src/day12.spec.ts
```

## Done when (Day 12)

- [ ] `promos_ratings_support_sos` and `support_guards` migrations applied
- [ ] Promo discount flows through the existing quote-token mechanism with zero changes to Day 9/10/11 completion code
- [ ] Usage limits hold under concurrent redemption; cancellation releases the slot
- [ ] Ratings update the driver's average correctly under concurrent submissions and reject duplicates
- [ ] Notifications are strictly user-scoped
- [ ] Ticket numbering, assignment, status transitions, auto-reopen, and the pending-count endpoint all work
- [ ] SOS reaches the dispatch socket immediately, never auto-resolves, and every transition is audited
- [ ] All eleven tests pass (`src/day12.spec.ts`)
- [ ] Committed as `feat(api): promotions, ratings, notifications, support tickets and sos`

## Dashboard, reports & audit (Day 13)

```bash
docker compose up -d && pnpm --filter api start:dev

# backfill a week of history so the chart has something to show
pnpm --filter api exec tsx scripts/backfill-daily-stats.ts --branch <branchId> --from 2026-09-24 --to 2026-10-01

curl -s "localhost:3000/api/v1/dashboard/metrics?branchId=<id>" -H "Authorization: Bearer $TOKEN" | jq
curl -s "localhost:3000/api/v1/dashboard/daily-stats?date=2026-09-25&branchId=<id>" -H "Authorization: Bearer $TOKEN" | jq
curl -s "localhost:3000/api/v1/dashboard/rides-chart?from=2026-09-24&to=2026-10-01&branchId=<id>" -H "Authorization: Bearer $TOKEN" | jq

# a small synchronous report, as CSV
curl -s "localhost:3000/api/v1/reports/booking-report?from=2026-09-24&to=2026-10-01&branchId=<id>&format=csv" \
  -H "Authorization: Bearer $TOKEN" -o report.csv && head report.csv

# an invoice PDF, from a Day 11 invoice
curl -s -X POST "localhost:3000/api/v1/finance/invoices/<invoiceId>/generate-pdf" -H "Authorization: Bearer $TOKEN" | jq
# then fetch the returned signed URL and confirm it opens as a real PDF

# force the async path by lowering the threshold for a quick check
REPORT_ASYNC_THRESHOLD_ROWS=1 pnpm --filter api start:dev
curl -s "localhost:3000/api/v1/reports/booking-report?from=2026-01-01&to=2026-10-01&branchId=<id>" -H "Authorization: Bearer $TOKEN" | jq
# expect { "async": true, "reportId": "..." }, then poll GET /reports/:id until READY
```

Permissions seeded: `dashboard.read` (staff broadly), `reports.read`, `reports.generate` (`branch_admin` / `accounts_admin` / `super_admin`), `audit.read` (`super_admin` only). Audit review: `GET /audit-logs?entity=&entityId=&actorUserId=&from=&to=`.

```sql
-- confirm the rollup matches a direct count for a closed day
select * from "DailyBranchStat" where "branchId"='<id>' and date='2026-09-25';
select count(*) from "Booking" where "branchId"='<id>' and "createdAt" >= '2026-09-25' and "createdAt" < '2026-09-26';

-- confirm the newly-closed audit gaps are producing rows
select entity, action, "createdAt" from "AuditLog" order by "createdAt" desc limit 10;
```

```bash
pnpm --filter api exec vitest run src/day13.spec.ts
```

## Done when (Day 13)

- [ ] reporting migration applied, confirmed booking-report indexes exist
- [ ] All four dashboard endpoints return correct, branch-scoped numbers, with today always live
- [ ] Nightly rollup job and backfill script both work and are idempotent
- [ ] Custom booking report works synchronously under the threshold and asynchronously over it, in JSON, CSV, and PDF
- [ ] Invoice PDF generates from real Day 11 data and downloads via a signed, access-checked URL
- [ ] AuditInterceptor is registered globally and every gap from the Step 8 sweep now has a row
- [ ] GET /audit-logs works and is restricted to super_admin
- [ ] All ten tests pass (`src/day13.spec.ts`)
- [ ] Committed as `feat(api): dashboard analytics, custom reports, pdf generation and audit log completeness`

---

## Day 14 — Production hardening (how to verify end to end)

Design and runbooks: [`docs/production-hardening.md`](docs/production-hardening.md). Legacy surface: [`docs/legacy-route-mapping.md`](docs/legacy-route-mapping.md).

### Role restriction

```bash
# Must fail for bridgecabs_app (repeat for LedgerEntry, LedgerTransaction,
# BookingStatusHistory, SupportTicketMessage, ClosingLine; also try TRUNCATE / ALTER TABLE).
psql -h <host> -U bridgecabs_app -d bridgecabs -c "DELETE FROM \"AuditLog\";"
```

### Backup + restore drill

```bash
# produce or download backup.sql.gz (nightly job or pg_dump), then:
./infrastructure/restore-drill.sh backup.sql.gz
# or manually:
docker run -d --name restore-test -e POSTGRES_PASSWORD=test -p 5433:5432 postgis/postgis:16-3.4
gunzip -c backup.sql.gz | PGPASSWORD=test psql -h localhost -p 5433 -U postgres
DATABASE_URL="postgresql://postgres:test@localhost:5433/postgres" pnpm --filter api test:e2e
docker rm -f restore-test
```


### Observability

Trigger a deliberate 5xx locally; confirm Sentry shows the event with PII scrubbed and the same `correlationId` as a pino log line. Async jobs should carry the id through BullMQ.

### Health / ready / SIGTERM

```bash
curl -s localhost:3000/api/v1/health          # 200 always while process is up
curl -s localhost:3000/api/v1/health/ready    # 200 when DB+Redis ok
# stop Redis container → ready must 503; start it → 200 again
# automated: apps/api/test/app.e2e-spec.ts + graceful-shutdown.e2e-spec.ts
```

### Load test

```bash
THROTTLE_LIMIT=100000 BOOKING_THROTTLE_LIMIT=1000 pnpm --filter api start:dev
cd apps/api && pnpm exec tsx scripts/spawn-sim-drivers.ts --count 100 --branch <branchId> --behavior accept
API_URL=http://localhost:3000 BRANCH_ID=<branchId> VEHICLE_TYPE_ID=<sedanId> k6 run loadtest/booking-matching.js
# then: psql … -f loadtest/check-invariants.sql   # zero rows
```

### Security / secrets / env split

```bash
pnpm audit --prod
gitleaks detect --source . --log-opts="--all"
# Diff staging vs production host env lists — DB, Redis, Stripe, Firebase, maps keys must all differ.
```

### Full suite + deploy

```bash
pnpm --filter api test:e2e
git push origin main   # Actions: design-tokens + gitleaks + lint/typecheck/e2e → migrate → deploy → smoke
```

## Done when (Day 14)

- [ ] `bridgecabs_app` and `bridgecabs_migrator` exist in staging and production; restricted grants verified by direct `psql`
- [ ] A real backup was restored and e2e passed against the restored database
- [ ] Staging and production use fully separate credentials (DB, Redis, Stripe, Firebase, maps)
- [ ] Sentry captures errors with PII scrubbed; pino logs carry `correlationId` through async jobs
- [ ] Rate-limit sweep complete; SOS `@SkipThrottle` + `SOS_DEDUPE_WINDOW_SECONDS` documented
- [ ] Load test passes thresholds with zero double-assignment violations
- [ ] CI runs the full e2e suite against ephemeral Postgres/Redis and passes
- [ ] `/health` and `/health/ready` are distinct; graceful shutdown drains in-flight requests
- [ ] `docs/legacy-route-mapping.md` accounts for every Day 0–style endpoint
- [ ] Full-history gitleaks clean; Day 0 exposed credential confirmed rotated
- [ ] Committed as `chore(infra): production hardening — db roles, backups, environments, observability, load test, ci`
