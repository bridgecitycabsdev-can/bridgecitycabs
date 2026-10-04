-- Day 10: Stripe card-on-file, webhook dedupe, lease, payouts, weekly closing.

-- Enum extensions
ALTER TYPE "LedgerKind" ADD VALUE 'LEASE_DEDUCTION';
ALTER TYPE "LedgerKind" ADD VALUE 'SETTLEMENT';

CREATE TYPE "PaymentPurpose" AS ENUM ('TRIP_AUTH_CAPTURE', 'TRIP_OVERAGE', 'REFUND');
CREATE TYPE "PayoutStatus" AS ENUM ('PENDING', 'SENT', 'FAILED', 'CANCELLED');
CREATE TYPE "ClosingStatus" AS ENUM ('DRAFT', 'FINALIZED');

-- Booking authorization / saved card
ALTER TABLE "Booking"
  ADD COLUMN "paymentMethodId" TEXT,
  ADD COLUMN "stripePaymentIntentId" TEXT,
  ADD COLUMN "authorizedAmountCents" INTEGER,
  ADD COLUMN "authBufferBps" INTEGER;

CREATE INDEX "Booking_stripePaymentIntentId_idx" ON "Booking"("stripePaymentIntentId");

-- Payment purpose (cash rows default to TRIP_AUTH_CAPTURE)
ALTER TABLE "Payment"
  ADD COLUMN "purpose" "PaymentPurpose" NOT NULL DEFAULT 'TRIP_AUTH_CAPTURE';

CREATE INDEX "Payment_provider_providerRef_idx" ON "Payment"("provider", "providerRef");

-- Allow one CAPTURED payment per (booking, purpose) so overage can coexist with auth capture
DROP INDEX IF EXISTS one_captured_payment_per_booking;
CREATE UNIQUE INDEX one_captured_payment_per_booking_purpose
  ON "Payment" ("bookingId", "purpose") WHERE status = 'CAPTURED';

-- Unique providerRef when present (partial)
CREATE UNIQUE INDEX "Payment_provider_providerRef_unique"
  ON "Payment" ("provider", "providerRef")
  WHERE "providerRef" IS NOT NULL;

-- Saved cards (passenger-owned)
CREATE TABLE "PassengerPaymentMethod" (
    "id" TEXT NOT NULL,
    "passengerId" TEXT NOT NULL,
    "stripePmId" TEXT NOT NULL,
    "brand" TEXT,
    "last4" TEXT,
    "expMonth" INTEGER,
    "expYear" INTEGER,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "PassengerPaymentMethod_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "PassengerPaymentMethod_stripePmId_key" ON "PassengerPaymentMethod"("stripePmId");
CREATE INDEX "PassengerPaymentMethod_passengerId_idx" ON "PassengerPaymentMethod"("passengerId");

ALTER TABLE "PassengerPaymentMethod"
  ADD CONSTRAINT "PassengerPaymentMethod_passengerId_fkey"
  FOREIGN KEY ("passengerId") REFERENCES "Passenger"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Booking"
  ADD CONSTRAINT "Booking_paymentMethodId_fkey"
  FOREIGN KEY ("paymentMethodId") REFERENCES "PassengerPaymentMethod"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Stripe Customer (one per passenger)
CREATE TABLE "StripeCustomer" (
    "id" TEXT NOT NULL,
    "passengerId" TEXT NOT NULL,
    "stripeCustomerId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "StripeCustomer_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "StripeCustomer_passengerId_key" ON "StripeCustomer"("passengerId");
CREATE UNIQUE INDEX "StripeCustomer_stripeCustomerId_key" ON "StripeCustomer"("stripeCustomerId");

ALTER TABLE "StripeCustomer"
  ADD CONSTRAINT "StripeCustomer_passengerId_fkey"
  FOREIGN KEY ("passengerId") REFERENCES "Passenger"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Webhook dedupe
CREATE TABLE "WebhookEvent" (
    "id" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" TIMESTAMP(3),
    "payload" JSONB NOT NULL,
    CONSTRAINT "WebhookEvent_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "WebhookEvent_provider_eventId_key" ON "WebhookEvent"("provider", "eventId");

-- Lease agreements (driver + vehicle)
CREATE TABLE "LeaseAgreement" (
    "id" TEXT NOT NULL,
    "driverId" TEXT NOT NULL,
    "vehicleId" TEXT NOT NULL,
    "weeklyAmountCents" INTEGER NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3),
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "LeaseAgreement_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "LeaseAgreement_driverId_active_idx" ON "LeaseAgreement"("driverId", "active");

ALTER TABLE "LeaseAgreement"
  ADD CONSTRAINT "LeaseAgreement_driverId_fkey"
  FOREIGN KEY ("driverId") REFERENCES "Driver"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "LeaseAgreement"
  ADD CONSTRAINT "LeaseAgreement_vehicleId_fkey"
  FOREIGN KEY ("vehicleId") REFERENCES "Vehicle"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Manual driver payouts
CREATE TABLE "DriverPayout" (
    "id" TEXT NOT NULL,
    "driverId" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "amountCents" INTEGER NOT NULL,
    "status" "PayoutStatus" NOT NULL DEFAULT 'PENDING',
    "method" TEXT NOT NULL,
    "reference" TEXT,
    "requestedById" TEXT,
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" TIMESTAMP(3),
    "sentById" TEXT,
    "failureNote" TEXT,
    CONSTRAINT "DriverPayout_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "DriverPayout_driverId_status_idx" ON "DriverPayout"("driverId", "status");

ALTER TABLE "DriverPayout"
  ADD CONSTRAINT "DriverPayout_driverId_fkey"
  FOREIGN KEY ("driverId") REFERENCES "Driver"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Weekly closing snapshots
CREATE TABLE "ClosingPeriod" (
    "id" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "weekStart" TIMESTAMP(3) NOT NULL,
    "weekEnd" TIMESTAMP(3) NOT NULL,
    "status" "ClosingStatus" NOT NULL DEFAULT 'DRAFT',
    "finalizedAt" TIMESTAMP(3),
    "finalizedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "ClosingPeriod_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "ClosingPeriod_branchId_weekStart_key" ON "ClosingPeriod"("branchId", "weekStart");

ALTER TABLE "ClosingPeriod"
  ADD CONSTRAINT "ClosingPeriod_branchId_fkey"
  FOREIGN KEY ("branchId") REFERENCES "Branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE TABLE "ClosingLine" (
    "id" TEXT NOT NULL,
    "closingPeriodId" TEXT NOT NULL,
    "accountKey" TEXT NOT NULL,
    "accountType" "AccountType" NOT NULL,
    "ownerId" TEXT,
    "openingCents" INTEGER NOT NULL,
    "movementCents" INTEGER NOT NULL,
    "closingCents" INTEGER NOT NULL,
    CONSTRAINT "ClosingLine_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "ClosingLine_closingPeriodId_idx" ON "ClosingLine"("closingPeriodId");

ALTER TABLE "ClosingLine"
  ADD CONSTRAINT "ClosingLine_closingPeriodId_fkey"
  FOREIGN KEY ("closingPeriodId") REFERENCES "ClosingPeriod"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
