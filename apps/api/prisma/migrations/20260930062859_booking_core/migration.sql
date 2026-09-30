-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('SCHEDULED', 'CREATED', 'SEARCHING_DRIVER', 'MATCHED', 'DRIVER_ASSIGNED', 'DRIVER_ARRIVING', 'DRIVER_ARRIVED', 'TRIP_STARTED', 'TRIP_COMPLETED', 'PAYMENT_PENDING', 'PAYMENT_COMPLETED', 'CLOSED', 'CANCELLED', 'NO_DRIVER_FOUND');

-- CreateEnum
CREATE TYPE "BookingSource" AS ENUM ('DISPATCH', 'PASSENGER_APP', 'DRIVER_APP');

-- CreateEnum
CREATE TYPE "FareZone" AS ENUM ('INSIDE_TOWN', 'OUT_OF_TOWN');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('CARD', 'CASH', 'WALLET', 'ACCOUNT');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('UNPAID', 'PAID', 'PARTIALLY_REFUNDED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "StopType" AS ENUM ('PICKUP', 'DROPOFF', 'STOP');

-- CreateEnum
CREATE TYPE "ActorType" AS ENUM ('SYSTEM', 'STAFF', 'PASSENGER', 'DRIVER');

-- CreateEnum
CREATE TYPE "AssignMethod" AS ENUM ('MANUAL', 'AUTO');

-- CreateEnum
CREATE TYPE "AssignEndReason" AS ENUM ('REASSIGNED', 'DRIVER_CANCELLED', 'COMPLETED', 'BOOKING_CANCELLED', 'TIMEOUT');

-- AlterTable
ALTER TABLE "Branch" ADD COLUMN     "currency" TEXT NOT NULL DEFAULT 'CAD',
ADD COLUMN     "gstRateBps" INTEGER NOT NULL DEFAULT 500,
ADD COLUMN     "timezone" TEXT NOT NULL DEFAULT 'America/Edmonton';

-- CreateTable
CREATE TABLE "FareRule" (
    "id" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "vehicleTypeId" TEXT NOT NULL,
    "zone" "FareZone" NOT NULL,
    "title" TEXT NOT NULL,
    "baseFareCents" INTEGER NOT NULL,
    "perKmCents" INTEGER NOT NULL,
    "perMinuteCents" INTEGER NOT NULL DEFAULT 0,
    "minFareCents" INTEGER NOT NULL DEFAULT 0,
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "FareRule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Booking" (
    "id" TEXT NOT NULL,
    "trackingId" TEXT NOT NULL,
    "legacyId" INTEGER,
    "version" INTEGER NOT NULL DEFAULT 0,
    "branchId" TEXT NOT NULL,
    "source" "BookingSource" NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'CREATED',
    "passengerId" TEXT,
    "passengerName" TEXT NOT NULL,
    "passengerPhone" TEXT NOT NULL,
    "createdById" TEXT,
    "vehicleTypeId" TEXT NOT NULL,
    "vanOnly" BOOLEAN NOT NULL DEFAULT false,
    "ladyDriverOnly" BOOLEAN NOT NULL DEFAULT false,
    "zone" "FareZone" NOT NULL DEFAULT 'INSIDE_TOWN',
    "corporateAccountId" TEXT,
    "scheduledAt" TIMESTAMP(3),
    "distanceMeters" INTEGER NOT NULL,
    "durationSeconds" INTEGER NOT NULL,
    "quotedFareCents" INTEGER NOT NULL,
    "quotedTaxCents" INTEGER NOT NULL,
    "fixedFareCents" INTEGER,
    "finalFareCents" INTEGER,
    "cancellationFeeCents" INTEGER NOT NULL DEFAULT 0,
    "paymentMethod" "PaymentMethod" NOT NULL DEFAULT 'CASH',
    "paymentStatus" "PaymentStatus" NOT NULL DEFAULT 'UNPAID',
    "notes" TEXT,
    "driverId" TEXT,
    "vehicleId" TEXT,
    "cancelledBy" "ActorType",
    "cancelReason" TEXT,
    "assignedAt" TIMESTAMP(3),
    "arrivedAt" TIMESTAMP(3),
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "closedAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Booking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingStop" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "sequence" INTEGER NOT NULL,
    "type" "StopType" NOT NULL,
    "address" TEXT NOT NULL,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "placeId" TEXT,
    "arrivedAt" TIMESTAMP(3),

    CONSTRAINT "BookingStop_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingStatusHistory" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "fromStatus" "BookingStatus",
    "toStatus" "BookingStatus" NOT NULL,
    "actorType" "ActorType" NOT NULL,
    "actorUserId" TEXT,
    "reason" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BookingStatusHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingAssignment" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "driverId" TEXT NOT NULL,
    "vehicleId" TEXT NOT NULL,
    "method" "AssignMethod" NOT NULL,
    "assignedById" TEXT,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endedAt" TIMESTAMP(3),
    "endReason" "AssignEndReason",

    CONSTRAINT "BookingAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "IdempotencyKey" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "requestHash" TEXT NOT NULL,
    "responseCode" INTEGER,
    "responseBody" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "IdempotencyKey_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "FareRule_branchId_vehicleTypeId_zone_key" ON "FareRule"("branchId", "vehicleTypeId", "zone");

-- CreateIndex
CREATE UNIQUE INDEX "Booking_trackingId_key" ON "Booking"("trackingId");

-- CreateIndex
CREATE UNIQUE INDEX "Booking_legacyId_key" ON "Booking"("legacyId");

-- CreateIndex
CREATE INDEX "Booking_branchId_status_createdAt_idx" ON "Booking"("branchId", "status", "createdAt");

-- CreateIndex
CREATE INDEX "Booking_driverId_status_idx" ON "Booking"("driverId", "status");

-- CreateIndex
CREATE INDEX "Booking_passengerId_createdAt_idx" ON "Booking"("passengerId", "createdAt");

-- CreateIndex
CREATE INDEX "Booking_scheduledAt_idx" ON "Booking"("scheduledAt");

-- CreateIndex
CREATE UNIQUE INDEX "BookingStop_bookingId_sequence_key" ON "BookingStop"("bookingId", "sequence");

-- CreateIndex
CREATE INDEX "BookingStatusHistory_bookingId_createdAt_idx" ON "BookingStatusHistory"("bookingId", "createdAt");

-- CreateIndex
CREATE INDEX "BookingAssignment_driverId_assignedAt_idx" ON "BookingAssignment"("driverId", "assignedAt");

-- CreateIndex
CREATE UNIQUE INDEX "IdempotencyKey_userId_key_key" ON "IdempotencyKey"("userId", "key");

-- AddForeignKey
ALTER TABLE "FareRule" ADD CONSTRAINT "FareRule_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "Branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FareRule" ADD CONSTRAINT "FareRule_vehicleTypeId_fkey" FOREIGN KEY ("vehicleTypeId") REFERENCES "VehicleType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "Branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_passengerId_fkey" FOREIGN KEY ("passengerId") REFERENCES "Passenger"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_vehicleTypeId_fkey" FOREIGN KEY ("vehicleTypeId") REFERENCES "VehicleType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES "Driver"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "Vehicle"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingStop" ADD CONSTRAINT "BookingStop_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingStatusHistory" ADD CONSTRAINT "BookingStatusHistory_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingAssignment" ADD CONSTRAINT "BookingAssignment_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
