# Part B: Trip completion, payments, ledger

## Design decisions

### Money

- Integer **cents** everywhere; currency is **CAD** only (`Branch.currency`).
- Every fare split assigns all cents: `driverEarningCents = finalSubtotalCents - commissionCents`. Nothing is lost to floating-point or uneven rounding.
- The client never sends an amount. The server computes and stores every figure. The driver app only confirms “cash received”.

### Ledger

- **Double-entry, append-only.** Every money movement is one transaction whose entries sum to zero.
- Mistakes are fixed with a **reversing** transaction, never an edit.
- The database enforces invariants: balanced transactions, immutability, and one posting per source are constraints—not application hope.

### Payments vs booking status

- A **Payment** row tracks each attempt.
- `Booking.paymentStatus` is a denormalised summary, updated in the **same** DB transaction as the payment row.
- Booking trip status (`TRIP_COMPLETED`, etc.) stays separate from payment settlement.
- `POST /driver/bookings/:id/complete` finalizes fare + commission in one txn, then `TRIP_STARTED → TRIP_COMPLETED → PAYMENT_PENDING`. Events emit after commit in that order. Fleet frees the driver at `TRIP_COMPLETED`. Non-cash methods stay in `PAYMENT_PENDING` until Day 10; today every booking is cash. The response carries the cent breakdown so the app never calculates.
- Cash confirmation: `POST /driver/bookings/:id/cash-collected` (and staff `POST /bookings/:id/payment/cash`) creates a `CAPTURED` Payment, posts `TRIP_CASH`, sets `paymentStatus=PAID`, then `PAYMENT_PENDING → PAYMENT_COMPLETED → CLOSED`. Retries are idempotent once CLOSED with a captured payment. Staff writes an audit row.
- `POST /bookings/:id/adjust-fare` (branch/accounts admin) may change the subtotal only while `PAYMENT_PENDING`. After pay, corrections use ledger reversal.
- List tab `payment_pending` surfaces unpaid completions. A daily job counts rows older than `PAYMENT_PENDING_ALERT_HOURS` (default 12) into Redis for the dispatch header badge. **Never auto-confirm money.**
- Reversals: `POST /finance/transactions/:id/reverse` (accounts/super) posts a one-time `REVERSAL` with negated lines and `reversalOfId`, sets `booking.paymentStatus=REFUNDED` when the source was a booking, and audits. Cash reversals put money back on the driver balance; passenger cash refund is a separate real-world step.
- Reads: `GET /finance/drivers/:id/balance`, `GET /finance/accounts/:key/entries` (finance roles, branch-scoped), `GET /driver/earnings?from&to` (trips + ledger balance).
- Daily ledger-integrity job: `SUM(LedgerEntry.amountCents)` must be 0; otherwise log at error and alert (never auto-correct).
- Permissions (seeded for `accounts_admin` / `super_admin`): `finance.read`, `finance.write`, `payments.confirm`, `payments.read`, `payments.refund`, `payouts.run`, `payouts.confirm`, `closing.manage`, `lease_agreements.manage`, plus `bookings.adjust_fare`. Runtime guards still use role names today.

### Payment providers

- `PaymentProvider` (`src/payments/`) exposes `authorize` / `capture` / `cancel` / `refund`. `CashProvider.authorize` returns `CAPTURED` when the driver confirms cash. `FakeProvider` registers only when `ALLOW_FAKE_PAYMENTS` is set (forbidden in production). `StripeProvider` registers when `STRIPE_SECRET_KEY` is set: manual-capture PaymentIntents (`capture_method: 'manual'`, `off_session` for saved cards), CAD, Stripe idempotency keys reused from `Payment.idempotencyKey`. `REQUIRES_ACTION` (3DS) must be handled in the passenger app — never assume authorize succeeded.
- **Day 10 — Stripe (chosen):** operates cleanly in Canada, CAD, hosted Elements/PaymentSheet so card numbers never touch BridgeCabs servers (easiest PCI path). Moneris remains a reasonable Canadian alternative for a fee comparison; the same authorize/capture/webhook pattern applies to either. Use **test-mode** keys only (`sk_test_` / `pk_test_`); enable CAD in the Stripe Dashboard. Keep live keys out until Day 14’s production hardening pass. Env: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PUBLISHABLE_KEY`, `AUTH_BUFFER_BPS` (default 2000), `LEASE_DEDUCTION_DAY` (default `MON`), `PAYOUT_METHOD_DEFAULT` (default `E_TRANSFER`).

### Day 10 — Card authorize / capture / settlement

- **Authorize at booking, capture at completion** — `POST /passenger/bookings` with `paymentMethod: CARD` authorizes (quote × `(1 + AUTH_BUFFER_BPS/10000)`) *before* inserting the booking + `Payment(AUTHORIZED)` in one transaction; declines never orphan a booking (`CARD_REQUIRES_ACTION` / `CARD_DECLINED`). On driver complete, capture is capped at the hold; overage leaves `paymentStatus: UNPAID` on the payment_pending tab for manual review (no automatic second charge yet). Capture API call is not ledger truth — the Stripe webhook posts `TRIP_CARD` and closes the booking.
- **Card-on-file** — `POST /passenger/payment-methods/setup-intent` creates (or reuses) `StripeCustomer` and returns a SetupIntent `clientSecret` (`usage: off_session`). The passenger app confirms the card in Stripe’s client SDK; raw PANs never hit this API. A `setup_intent.succeeded` webhook (Step 8) writes `PassengerPaymentMethod`. Also: `GET /passenger/payment-methods`, `POST …/:id/default`, `DELETE …/:id` (detach + delete). Booking references a saved method via `paymentMethodId` → `stripePmId`.
- **Webhooks are the source of truth** for payment state, not the client’s “I finished paying” call. `POST /api/v1/webhooks/stripe` (`@Public`) verifies `stripe-signature` against the **raw** body (`express.raw` in `main.ts`). `WebhookEvent` upserts by `(provider, eventId)` and skips work when `processedAt` is set. Handlers: `setup_intent.succeeded` → `PassengerPaymentMethod`; `payment_intent.amount_capturable_updated` → `AUTHORIZED`; `payment_intent.succeeded` → `CAPTURED` + `TRIP_CARD` ledger + `PAYMENT_PENDING` → `CLOSED`; `payment_intent.payment_failed` → `FAILED` (stays on payment_pending); `charge.refunded` → `REFUNDED` + ledger `REVERSAL`. Ledger `post` is also idempotent by `(sourceType, sourceId, kind)`.
- **Cancel before capture** — staff/passenger cancel (and staff status→CANCELLED) calls `CardHoldService.releaseAuthorized`, which `paymentIntents.cancel`s when `Payment.status === AUTHORIZED` and marks the Payment `CANCELLED`.
- **Refund after capture** — `POST /bookings/:id/refund` (`accounts_admin` / `super_admin`) calls Stripe `refund`; ledger reversal waits for `charge.refunded`.

### Local Stripe webhook forwarding

Install the [Stripe CLI](https://stripe.com/docs/stripe-cli) (`winget install Stripe.StripeCli` on Windows). While developing, keep a dedicated terminal open:

```bash
stripe login
stripe listen --forward-to localhost:3000/api/v1/webhooks/stripe
```

Copy the printed `whsec_...` into `apps/api/.env` as `STRIPE_WEBHOOK_SECRET` and restart the API. Synthetic events (no real card):

```bash
stripe trigger payment_intent.succeeded
stripe trigger payment_intent.payment_failed
stripe trigger charge.refunded
```
- **Payouts are manual for now** — `POST /finance/payouts/run` creates `DriverPayout(PENDING)` for every driver with positive balance (and no pending payout) and posts `SETTLEMENT` (debit `DRIVER_BALANCE`, credit `BANK_CLEARING:{branchId}`). `GET /finance/payouts`, `POST …/mark-sent`, `POST …/mark-failed` (`accounts_admin` / `super_admin` write; finance roles read). Failed payouts need a manual reversing entry — no automatic REVERSAL. Stripe Connect is a later upgrade.
- **Weekly closing is a snapshot, not a mutation** — `POST /finance/closing-periods/run` (and the `weekly-close` BullMQ job, local midnight the day after `LEASE_DEDUCTION_DAY`) materializes `ClosingPeriod` / `ClosingLine` opening/movement/closing cents per account from ledger sums. Never writes `LedgerEntry` / `LedgerTransaction`. DRAFT periods may be recomputed freely; `POST …/finalize` (`accounts_admin` / `super_admin`) locks the week. `GET /finance/closing-periods` and `GET …/:id` feed the Weekly Ledger Closing screen.
- **Lease deductions** — weekly BullMQ job (`lease-deduction`) at `LEASE_DEDUCTION_DAY` local midnight per distinct `Branch.timezone`. Posts `LEASE_DEDUCTION` with `sourceType=LEASE_WEEK`, `sourceId={leaseId}:{weekStartISO}` (idempotent re-run). Debit `DRIVER_BALANCE`, credit `LEASE_RECEIVABLE:{branchId}` (`AccountType.COMPANY_REVENUE`). CRUD: `POST/GET/PATCH /lease-agreements` (`super_admin`, `branch_admin`).

**Business-rule defaults** (confirm with dispatch/accounts against legacy Lease Deduction and Weekly Ledger Closing screens; change later without rewriting history):

- Week starts **Monday 00:00** in `Branch.timezone`.
- Missed lease **does not auto-carry**; the next week posts a fresh deduction. Disputes use ledger `REVERSAL`.

### Posting rules

- Posting rules are **pure functions**, unit-tested (including property tests), and easy for an accountant to review.
- `finalizeFare` / `splitFare` (`src/fares/finalize-fare.ts`) compute settlement cents. `tripPostings` (`src/ledger/trip-postings.ts`) turns them into signed ledger lines (debit positive; zero lines dropped).
- `LedgerService.post` is the only writer. It upserts accounts by key (`DRIVER_BALANCE:<driverId>`, `COMPANY_REVENUE:<branchId>`, `GST_PAYABLE:<branchId>`, `PAYMENT_CLEARING:<branchId>`), is idempotent on `(sourceType, sourceId, kind)`, and relies on the unique constraint so a concurrent loser rolls back.
- Driver balance for reporting is **`-SUM(DRIVER_BALANCE entries)`**: positive means the company owes the driver; negative means the driver owes the company. Cash-heavy drivers drift negative until they settle; card-heavy drivers drift positive. Confirm both directions against the legacy Driver Ledger before building its screen.
- `FIXED_FARE_INCLUDES_GST` (env, default `false`) chooses whether a dispatcher fixed fare already includes GST. Ask dispatchers which number they quote the customer.

### Accountant-flagged config

Commission model, who remits GST, and whether fixed fares include GST vary by company structure. In Canada, taxi and ride-hailing suppliers generally must register for GST regardless of revenue—confirm owner-operator and lease treatment with your accountant. Branch-level knobs (`gstRateBps`, `commissionBps`) exist so those decisions stay configurable.

## Fare field meaning (Day 4)

| Field | Meaning |
| --- | --- |
| `quotedFareCents` | Subtotal **before** GST (from `calcFare.subtotalCents`) |
| `quotedTaxCents` | GST on the quote |
| `finalFareCents` | GST-inclusive total at completion |
| `finalSubtotalCents` / `finalTaxCents` | Settlement split at completion |
| `commissionCents` / `driverEarningCents` | Branch commission snapshot applied at completion |

## Schema notes

- `Branch.commissionBps` defaults to `0`. Import the real legacy deduction later; seed values are placeholders.
- Booking snapshots `gstRateBps` at creation and `commissionBps` at completion so later branch config changes do not rewrite history.
- Ledger invariants live in Postgres: non-zero entries, deferred balance check, append-only triggers. One `CAPTURED` payment per `(bookingId, purpose)` (allows trip auth capture + overage).
- Day 10 tables: `StripeCustomer`, `PassengerPaymentMethod`, `WebhookEvent`, `LeaseAgreement`, `DriverPayout`, `ClosingPeriod` / `ClosingLine`. Booking holds `stripePaymentIntentId`, `authorizedAmountCents`, `authBufferBps`, `paymentMethodId`.
- Day 10 guards: unique webhook `(provider, eventId)`, at most one `PENDING` payout per driver, `ClosingLine` immutable once its `ClosingPeriod` is `FINALIZED` (`forbid_finalized_closing_line_mutation`).
- Triggers stop the application role; a superuser can still drop them. **Deployment checklist:** run the API under a DB role with no `UPDATE` / `DELETE` / `TRUNCATE` on `LedgerEntry` / `LedgerTransaction`, and no mutation of finalized `ClosingLine` rows. Keep `STRIPE_*` secrets and service accounts out of git.
