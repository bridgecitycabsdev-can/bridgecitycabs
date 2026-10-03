-- CreateEnum
CREATE TYPE "PaymentRecordStatus" AS ENUM ('PENDING', 'REQUIRES_ACTION', 'AUTHORIZED', 'CAPTURED', 'FAILED', 'CANCELLED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "AccountType" AS ENUM ('DRIVER_BALANCE', 'COMPANY_REVENUE', 'GST_PAYABLE', 'PAYMENT_CLEARING', 'PASSENGER_WALLET');

-- CreateEnum
CREATE TYPE "LedgerKind" AS ENUM ('TRIP_CASH', 'TRIP_CARD', 'ADJUSTMENT', 'REVERSAL');

-- DropIndex
DROP INDEX "Payment_bookingId_createdAt_idx";

-- Evolve Payment: map stub attempt statuses, then switch enum.
ALTER TABLE "Payment" DROP COLUMN "updatedAt";

ALTER TABLE "Payment"
ADD COLUMN "provider" TEXT,
ADD COLUMN "currency" TEXT NOT NULL DEFAULT 'CAD',
ADD COLUMN "providerRef" TEXT,
ADD COLUMN "idempotencyKey" TEXT,
ADD COLUMN "failureCode" TEXT,
ADD COLUMN "capturedAt" TIMESTAMP(3),
ADD COLUMN "createdById" TEXT;

UPDATE "Payment"
SET "provider" = CASE WHEN "method" = 'CASH' THEN 'CASH' ELSE 'FAKE' END
WHERE "provider" IS NULL;

ALTER TABLE "Payment" ALTER COLUMN "provider" SET NOT NULL;

ALTER TABLE "Payment" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "Payment" ALTER COLUMN "status" TYPE TEXT USING (
  CASE "status"::text
    WHEN 'SUCCEEDED' THEN 'CAPTURED'
    ELSE "status"::text
  END
);
DROP TYPE "PaymentAttemptStatus";
ALTER TABLE "Payment" ALTER COLUMN "status" TYPE "PaymentRecordStatus" USING ("status"::"PaymentRecordStatus");
ALTER TABLE "Payment" ALTER COLUMN "status" SET DEFAULT 'PENDING'::"PaymentRecordStatus";

-- CreateTable
CREATE TABLE "FinancialAccount" (
    "id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "type" "AccountType" NOT NULL,
    "branchId" TEXT,
    "ownerId" TEXT,
    "currency" TEXT NOT NULL DEFAULT 'CAD',

    CONSTRAINT "FinancialAccount_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LedgerTransaction" (
    "id" TEXT NOT NULL,
    "kind" "LedgerKind" NOT NULL,
    "sourceType" TEXT NOT NULL,
    "sourceId" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "description" TEXT,
    "reversalOfId" TEXT,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LedgerTransaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LedgerEntry" (
    "id" TEXT NOT NULL,
    "transactionId" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "amountCents" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LedgerEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ConsentRecord" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "appVersion" TEXT,
    "acceptedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ConsentRecord_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "FinancialAccount_key_key" ON "FinancialAccount"("key");

-- CreateIndex
CREATE UNIQUE INDEX "LedgerTransaction_reversalOfId_key" ON "LedgerTransaction"("reversalOfId");

-- CreateIndex
CREATE UNIQUE INDEX "LedgerTransaction_sourceType_sourceId_kind_key" ON "LedgerTransaction"("sourceType", "sourceId", "kind");

-- CreateIndex
CREATE INDEX "LedgerEntry_accountId_createdAt_idx" ON "LedgerEntry"("accountId", "createdAt");

-- CreateIndex
CREATE INDEX "LedgerEntry_transactionId_idx" ON "LedgerEntry"("transactionId");

-- CreateIndex
CREATE INDEX "ConsentRecord_userId_type_idx" ON "ConsentRecord"("userId", "type");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_idempotencyKey_key" ON "Payment"("idempotencyKey");

-- CreateIndex
CREATE INDEX "Payment_bookingId_idx" ON "Payment"("bookingId");

-- AddForeignKey
ALTER TABLE "LedgerEntry" ADD CONSTRAINT "LedgerEntry_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "LedgerTransaction"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LedgerEntry" ADD CONSTRAINT "LedgerEntry_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "FinancialAccount"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Snapshot GST from the booking's branch (overrides the column default for existing rows).
UPDATE "Booking" AS b
SET "gstRateBps" = br."gstRateBps"
FROM "Branch" AS br
WHERE b."branchId" = br."id";
