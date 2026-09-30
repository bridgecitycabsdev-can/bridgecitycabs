-- CreateEnum
CREATE TYPE "ShiftEndReason" AS ENUM ('MANUAL', 'CONNECTION_LOST', 'ADMIN_FORCED', 'SYSTEM');

-- CreateTable
CREATE TABLE "DriverShift" (
    "id" TEXT NOT NULL,
    "driverId" TEXT NOT NULL,
    "vehicleId" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endedAt" TIMESTAMP(3),
    "endReason" "ShiftEndReason",
    "endedById" TEXT,

    CONSTRAINT "DriverShift_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DriverLocationLog" (
    "id" BIGSERIAL NOT NULL,
    "driverId" TEXT NOT NULL,
    "bookingId" TEXT,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "speedMps" DOUBLE PRECISION,
    "heading" DOUBLE PRECISION,
    "accuracyM" DOUBLE PRECISION,
    "recordedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DriverLocationLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "DriverShift_driverId_startedAt_idx" ON "DriverShift"("driverId", "startedAt");

-- CreateIndex
CREATE INDEX "DriverShift_branchId_startedAt_idx" ON "DriverShift"("branchId", "startedAt");

-- CreateIndex
CREATE INDEX "DriverLocationLog_driverId_recordedAt_idx" ON "DriverLocationLog"("driverId", "recordedAt");

-- CreateIndex
CREATE INDEX "DriverLocationLog_bookingId_recordedAt_idx" ON "DriverLocationLog"("bookingId", "recordedAt");

-- CreateIndex
CREATE INDEX "DriverLocationLog_recordedAt_idx" ON "DriverLocationLog"("recordedAt");

-- AddForeignKey
ALTER TABLE "DriverShift" ADD CONSTRAINT "DriverShift_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES "Driver"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
