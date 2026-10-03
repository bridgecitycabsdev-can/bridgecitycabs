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

## Emulator location

Emulators default to California, so Lethbridge drivers never match. Pin coordinates explicitly (longitude first, then latitude):

```bash
adb -s emulator-5554 emu geo fix -112.8418 49.6935    # driver
adb -s emulator-5556 emu geo fix -112.8300 49.6950    # passenger, ~1 km away
```

In the iOS Simulator: **Features → Location → Custom Location** (same lat/lng).

List devices, then run each app:

```bash
flutter devices
flutter run -d <id> --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Use `http://10.0.2.2:3000` on an Android emulator. On an iOS simulator use `http://localhost:3000` (or omit the define and rely on the app default). A physical phone needs your LAN or tunnel URL for both `API_BASE_URL` and `WS_URL`.

## Faster timeout drills

In local `apps/api/.env` (not committed), temporarily set:

```env
SEARCH_WINDOW_SECONDS=20
OFFER_TIMEOUT_SECONDS=8
```

Restart the API, run the timeout/no-driver flows, then put the values back (defaults are in `.env.example`: 120 and 15).

## End-of-day verification

Assume migrate + seed have been applied (`dispatch_ops`, `dispatch_guards`), and Google keys are restricted (Places/Routes server keys, Android Maps by package+SHA-1, iOS Maps by bundle ID) with quotas and a billing alert. Nothing secret belongs in git.

### Sim drivers (Lethbridge)

From `apps/api`, with the API up:

```bash
pnpm exec tsx scripts/sim-driver.ts --phone +14035550100 --behavior accept --vehicle LTH111
pnpm exec tsx scripts/sim-driver.ts --phone +14035550101 --behavior ignore --vehicle LTH112
```

Both loop near downtown Lethbridge. Keep one accepting and one ignoring for the Auto job path.

### Web console

1. Book an **Auto** job. Quote appears → Book succeeds → job under **Unassigned**, then **Assigned** when the accepting sim takes it.
2. Double-click Book → still one booking. DevTools Network → Offline → Book → Online → retry → still one booking (idempotency).
3. Book a **Manual** job → open details → **Assign** → pick a ranked candidate.
4. Edit notes on an assigned job → driver `driver:state` / snapshot shows the note change.
5. Stop both sims → book Auto → wait for **NO_DRIVER_FOUND**. Timeout modal fills; badge and beep fire (enable Sound alerts first). **Retry search** and **Cancel**.

### Driver app (Android emulator)

Accept sim off. Pin location (`geo fix -112.8418 49.6935`). Book from the web console. Offer shows a server-clock countdown → Accept → Navigate → Arrived → Start → Complete.

### Passenger app (second emulator)

Pin ~1 km away (`geo fix -112.8300 49.6950`). Search → choose a ride → book → see driver assigned. Try a second booking → UI explains the conflict. Cancel the active trip.

### Postgres AuditLog

```sql
SELECT action, entity, "createdAt" FROM "AuditLog" ORDER BY "createdAt" DESC LIMIT 20;
-- Expect booking.updated / booking.fixed_fare_set rows for edits and fixed fares.
UPDATE "AuditLog" SET action = 'tamper' WHERE id = '<any id>';  -- must fail or be disallowed by ops policy
```

There is no API to update or delete audit rows; the table is append-only.

### Done when

- [ ] `dispatch_ops` and `dispatch_guards` migrations applied; seeds updated
- [ ] Places proxy, batch quotes, and quote tokens work; no Google key reaches a client
- [ ] Routes failure falls back to ESTIMATE; dispatchers can still book
- [ ] List filters, candidates, PATCH with versioning, retry-search, dispatch-mode, and driver release work
- [ ] Web New Job: multiple drafts, quote, idempotent booking, server error mapping
- [ ] Details modal: assign by list and map, edit, cancel
- [ ] Unassigned and closed modals; audible timeout alert
- [ ] Driver app: offer with server-clock countdown; trip completes
- [ ] Passenger app: book and track (map may be a placeholder)
- [ ] Every audited action writes an immutable row
- [ ] All three key types restricted; quotas + billing alert; secrets out of git
