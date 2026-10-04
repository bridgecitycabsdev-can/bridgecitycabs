# Legacy → modern route mapping

Day 14 Step 10 reconciliation. The Day 0 PDF Section 20 table is not checked into this repo; the only explicit example named in the Day 14 brief is `/Auth/login` → `/api/v1/auth/login`. This document maps that example plus the broader ASP.NET-style endpoint surface implied by Days 1–13 (PascalCase `/Controller/action`) onto what the Nest API exposes today under `/api/v1`.

Status meanings:

| Status | Meaning |
|---|---|
| **done** | Equivalent modern route exists and is the client target |
| **deferred** | Intentionally not carried forward yet (or covered by a different flow) |
| **not applicable** | Legacy concept removed / replaced (no 1:1 route needed) |

## Auth and session

| Legacy route | New route | Status |
|---|---|---|
| `POST /Auth/login` | `POST /api/v1/auth/login` | done |
| `POST /Auth/logout` | `POST /api/v1/auth/logout` | done |
| `POST /Auth/refresh` / `refresh-token` | `POST /api/v1/auth/refresh` | done |
| `POST /Auth/otp-request` (or equivalent SMS login) | `POST /api/v1/auth/otp/request` | done |
| `POST /Auth/otp-verify` | `POST /api/v1/auth/otp/verify` | done |
| Cookie / query-string bearer tokens | Bearer header only (`reject-token-query` middleware) | not applicable |

## Bookings and dispatch

| Legacy route | New route | Status |
|---|---|---|
| `POST /Booking/Create` (staff) | `POST /api/v1/bookings` | done |
| `POST /Booking/Create` (passenger app) | `POST /api/v1/passenger/bookings` | done |
| `GET /Booking/{id}` | `GET /api/v1/bookings/:id` / `GET /api/v1/passenger/bookings/:id` | done |
| `POST /Booking/Cancel` | `POST /api/v1/bookings/:id/cancel`, `…/passenger/bookings/:id/cancel` | done |
| `POST /Booking/Assign` | `POST /api/v1/bookings/:id/assign` | done |
| `POST /Booking/Unassign` | `POST /api/v1/bookings/:id/unassign` | done |
| `POST /Booking/Status` / trip lifecycle | `POST /api/v1/bookings/:id/status`, driver `…/arriving|arrived|start|complete` | done |
| `POST /Booking/RetrySearch` | `POST /api/v1/bookings/:id/retry-search`, passenger `…/retry` | done |
| `POST /Booking/DispatchMode` | `POST /api/v1/bookings/:id/dispatch-mode` | done |
| `POST /Booking/AdjustFare` | `POST /api/v1/bookings/:id/adjust-fare` | done |
| `POST /Booking/CashCollected` / confirm cash | `POST /api/v1/bookings/:id/payment/cash`, driver `…/cash-collected` | done |
| `POST /Booking/Refund` | `POST /api/v1/bookings/:id/refund` | done |
| `GET /Booking/Candidates` | `GET /api/v1/bookings/:id/candidates` | done |
| Manual radio / phone-only assign screens | Same assign APIs + realtime sockets | not applicable |

## Driver / fleet

| Legacy route | New route | Status |
|---|---|---|
| `POST /Driver/StartShift` | `POST /api/v1/driver/shift/start` | done |
| `POST /Driver/EndShift` | `POST /api/v1/driver/shift/end` | done |
| `POST /Driver/Away` / `Back` | `POST /api/v1/driver/away`, `…/back` | done |
| `POST /Driver/UpdateLocation` | `POST /api/v1/driver/location/batch` + socket presence | done |
| `POST /Driver/AcceptOffer` / `DeclineOffer` | `POST /api/v1/driver/offers/:id/accept\|decline` | done |
| `GET /Driver/List` / detail | `GET /api/v1/drivers`, `GET /api/v1/drivers/:id` | done |
| `POST /Driver/Approve` / `Suspend` / `ForceOffline` | matching `POST /api/v1/drivers/:id/…` | done |
| `POST /Driver/AssignVehicle` | `POST /api/v1/drivers/:id/assign-vehicle` | done |
| `GET /Driver/Earnings` | `GET /api/v1/driver/earnings` | done |
| Legacy GPS polling-only clients | Socket + batch; polling clients must migrate | deferred |

## Passenger

| Legacy route | New route | Status |
|---|---|---|
| `POST /Passenger/Register` / CRUD | `POST/PATCH /api/v1/passengers`, block/unblock | done |
| `POST /Passenger/Quote` | `POST /api/v1/passenger/fares/quote(s)` | done |
| `GET /Passenger/ActiveTrip` | `GET /api/v1/passenger/bookings/…` trip endpoints | done |
| `POST /Passenger/RateDriver` | `POST /api/v1/passenger/bookings/:id/rate-driver` | done |
| `POST /Passenger/PaymentMethod` | `POST /api/v1/passenger/payment-methods/setup-intent` + list/default/delete | done |

## Vehicles, catalog, documents

| Legacy route | New route | Status |
|---|---|---|
| `GET/POST /Vehicle/…` | `/api/v1/vehicles` | done |
| `GET/POST /VehicleType` / Make / Model | `/api/v1/vehicle-types`, `vehicle-makes`, `vehicle-models` | done |
| `POST /Document/Upload` / review | `/api/v1/drivers|vehicles/:id/documents`, `POST /api/v1/documents/:id/review` | done |
| Direct binary upload to API | Signed object-storage URLs | not applicable |

## Branches, users, corporate, lease

| Legacy route | New route | Status |
|---|---|---|
| `GET/POST /Branch/…` | `/api/v1/branches` | done |
| `POST /User/SetRole` | `PATCH /api/v1/users/:id/role` | done |
| `GET/POST /CorporateAccount/…` | `/api/v1/corporate-accounts`, groups, contacts | done |
| `GET/POST /LeaseAgreement/…` | `/api/v1/lease-agreements` | done |
| Legacy “search account” free-text only | Typeahead on corporate list (`take: 25`) | done |

## Fares, promos, places

| Legacy route | New route | Status |
|---|---|---|
| `POST /Fare/Quote` | `POST /api/v1/fares/quote(s)` + passenger fares | done |
| `CRUD /FareRule` | `/api/v1/fare-rules` | done |
| `CRUD /PromoCode` | `/api/v1/promo-codes` | done |
| Client-side Google Places key | `GET /api/v1/places/…` (server proxy) | done |

## Finance, closing, invoices, payouts

| Legacy route | New route | Status |
|---|---|---|
| Weekly ledger closing screens | `POST /api/v1/finance/closing-periods/run`, finalize | done |
| Lease deduction / payout run | `POST /api/v1/finance/payouts/run`, mark-sent/failed | done |
| Invoice generate / send / void / record payment | `/api/v1/finance/invoices/…` | done |
| Invoice PDF | `POST …/generate-pdf` + signed download | done |
| Ledger reverse | `POST /api/v1/finance/transactions/:id/reverse` | done |
| Driver “Weekly Ledger” screen parity | API + reports; full UI polish outside API scope | deferred |

## Support, SOS, notifications, devices

| Legacy route | New route | Status |
|---|---|---|
| `POST /Support/Ticket` / messages / assign | `/api/v1/support/tickets…` | done |
| Pending-ticket badge | `GET /api/v1/support/tickets/pending-count` | done |
| `POST /SOS` (driver/passenger) | `POST /api/v1/driver/sos`, `/api/v1/passenger/sos` | done |
| SOS ack / resolve | `POST /api/v1/sos/:id/acknowledge\|resolve` | done |
| Push device register | `POST /api/v1/devices`, `DELETE /api/v1/devices/:token` | done |
| In-app notification inbox | `/api/v1/notifications` | done |

## Reporting, dashboard, audit

| Legacy route | New route | Status |
|---|---|---|
| Dashboard metrics / daily / rides chart | `/api/v1/dashboard/…` | done |
| Booking report export | `GET /api/v1/reports/booking-report` | done |
| Audit log viewer | `GET /api/v1/audit-logs` | done |

## Payments / webhooks / health

| Legacy route | New route | Status |
|---|---|---|
| Client “I paid” callback as source of truth | **not applicable** — Stripe webhook is source of truth: `POST /api/v1/webhooks/stripe` | not applicable |
| Process ping / keep-alive | `GET /api/v1/health` (liveness), `GET /api/v1/health/ready` (readiness) | done |

## Deliberately not rebuilt

| Legacy surface | Status | Notes |
|---|---|---|
| ASP.NET MVC razor admin HTML | not applicable | Replaced by `dispatch-web` + mobile apps |
| Query-string `?token=` auth | not applicable | Rejected at middleware |
| Shared staging/prod Stripe or Firebase | not applicable | Forbidden by env split (see `docs/production-hardening.md`) |
| Wildcard CORS (`*`) | not applicable | `allowedWsOrigins` throws if `*` appears |

If a passenger or driver client still calls a PascalCase path above and gets 404, point it at the **New route** column — do not add ASP.NET compatibility shims unless a specific client cannot be updated.
