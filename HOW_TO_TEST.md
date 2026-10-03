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

## Faster timeout drills

In local `apps/api/.env` (not committed), temporarily set:

```env
SEARCH_WINDOW_SECONDS=20
OFFER_TIMEOUT_SECONDS=8
```

Restart the API, run the timeout/no-driver flows, then put the values back (defaults are in `.env.example`: 120 and 15).

## End-of-day verification

Assume `money_core` and `money_guards` migrations are applied, and Google/Firebase keys are restricted. Nothing secret belongs in git.

1. Run one full trip with the simulator (`--complete`) or with the driver app open. The web Money section shows the final fare, and Postgres shows exactly one balanced `TRIP_CASH` transaction.
2. Tap **Cash collected** twice quickly → a single payment and ledger transaction.
3. Driver balance matches your hand calculation (`GET /driver/earnings` or the SQL above).
4. Put the driver app in the background, create a job → notification arrives → tap opens the offer screen with the right countdown.
5. Kill the app during an active job, restart → returns to the trip or collect screen.
6. Reverse the transaction as an accounts user → balance returns to zero.
7. `select sum("amountCents") from "LedgerEntry";` → **0**.

### Web console (dispatch)

1. Book an **Auto** job → Unassigned → Assigned when a driver accepts.
2. Double-click Book → still one booking (idempotency).
3. Book a **Manual** job → Assign from details.
4. Edit notes on an assigned job → driver snapshot updates.
5. No drivers online → **NO_DRIVER_FOUND** timeout modal.

## Done when

- [ ] `money_core` and `money_guards` migrations applied
- [ ] Balanced, immutable ledger with idempotent posting, proven by tests
- [ ] Property tests pass for fare splitting
- [ ] Trip completion finalizes fare server-side and the cash flow closes the booking
- [ ] Reversal, adjust-fare, and balance endpoints work with the right roles
- [ ] Driver snapshot carries `pendingPayment` and the collect screen survives an app restart
- [ ] Device tokens follow the logged-in user and are revoked on logout
- [ ] An offer push arrives with the app backgrounded and opens the right screen
- [ ] Driver location streams with the app backgrounded on Android, with consent recorded first
- [ ] No amount is ever accepted from a client, and no secrets are in git
- [ ] Committed as `feat(api,mobile): ledger, cash payments, push and background location`
