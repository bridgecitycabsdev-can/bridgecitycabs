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
- Permissions: `finance.read`, `finance.write`, `payments.confirm`, `bookings.adjust_fare`.

### Payment providers

- `PaymentProvider` (`src/payments/`) abstracts gateways. `CashProvider` returns `CAPTURED` when the driver confirms cash received. `FakeProvider` is registered only when `ALLOW_FAKE_PAYMENTS` is set, and that flag is forbidden in production (same boot assert pattern as `OTP_DEV_CODE`).
- **Day 10:** Stripe (or Moneris / another Canadian gateway), webhooks, and a `WebhookEvent` dedupe table. Compare fees and Interac debit support before committing. Integrate via hosted card fields or the provider SDK so card numbers never touch BridgeCabs servers.

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
- Ledger invariants live in Postgres: non-zero entries, deferred balance check, append-only triggers, one `CAPTURED` payment per booking.
- Triggers stop the application role; a superuser can still drop them. **Day 10 deployment checklist:** run the API under a DB role with no `UPDATE` / `DELETE` / `TRUNCATE` on `LedgerEntry` and `LedgerTransaction`.
