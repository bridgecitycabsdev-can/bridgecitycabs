-- Day 13: DailyBranchStat rollups, GeneratedReport jobs, booking report indexes.
-- Derived/rebuildable data — no append-only SQL guards.

-- CreateEnum
CREATE TYPE "ReportType" AS ENUM ('INVOICE', 'DAILY_SUMMARY', 'CUSTOM_BOOKING_REPORT');

-- CreateEnum
CREATE TYPE "ReportStatus" AS ENUM ('QUEUED', 'GENERATING', 'READY', 'FAILED');

-- CreateTable
CREATE TABLE "DailyBranchStat" (
    "id" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "totalRides" INTEGER NOT NULL DEFAULT 0,
    "completedRides" INTEGER NOT NULL DEFAULT 0,
    "activeRides" INTEGER NOT NULL DEFAULT 0,
    "cancelledRides" INTEGER NOT NULL DEFAULT 0,
    "unpaidRides" INTEGER NOT NULL DEFAULT 0,
    "prepaidRides" INTEGER NOT NULL DEFAULT 0,
    "postpaidRides" INTEGER NOT NULL DEFAULT 0,
    "accountCalls" INTEGER NOT NULL DEFAULT 0,
    "sourceDispatch" INTEGER NOT NULL DEFAULT 0,
    "sourceDriverApp" INTEGER NOT NULL DEFAULT 0,
    "sourcePassengerApp" INTEGER NOT NULL DEFAULT 0,
    "grossSubtotalCents" INTEGER NOT NULL DEFAULT 0,
    "computedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DailyBranchStat_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GeneratedReport" (
    "id" TEXT NOT NULL,
    "type" "ReportType" NOT NULL,
    "status" "ReportStatus" NOT NULL DEFAULT 'QUEUED',
    "branchId" TEXT,
    "paramsJson" JSONB NOT NULL,
    "storageKey" TEXT,
    "rowCount" INTEGER,
    "requestedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),
    "failureNote" TEXT,

    CONSTRAINT "GeneratedReport_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "DailyBranchStat_branchId_date_idx" ON "DailyBranchStat"("branchId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "DailyBranchStat_branchId_date_key" ON "DailyBranchStat"("branchId", "date");

-- CreateIndex
CREATE INDEX "GeneratedReport_requestedById_createdAt_idx" ON "GeneratedReport"("requestedById", "createdAt");

-- CreateIndex
CREATE INDEX "GeneratedReport_type_status_idx" ON "GeneratedReport"("type", "status");

-- Report filter indexes (idempotent if already present from a partial apply).
CREATE INDEX IF NOT EXISTS "Booking_branchId_completedAt_idx" ON "Booking"("branchId", "completedAt");
CREATE INDEX IF NOT EXISTS "Booking_branchId_paymentMethod_paymentStatus_idx" ON "Booking"("branchId", "paymentMethod", "paymentStatus");
CREATE INDEX IF NOT EXISTS "Booking_source_createdAt_idx" ON "Booking"("source", "createdAt");

-- AddForeignKey
ALTER TABLE "DailyBranchStat" ADD CONSTRAINT "DailyBranchStat_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "Branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GeneratedReport" ADD CONSTRAINT "GeneratedReport_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "Branch"("id") ON DELETE SET NULL ON UPDATE CASCADE;
