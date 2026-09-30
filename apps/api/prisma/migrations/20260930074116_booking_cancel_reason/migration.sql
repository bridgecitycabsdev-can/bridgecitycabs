/*
  Warnings:

  - The `cancelReason` column on the `Booking` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- CreateEnum
CREATE TYPE "CancelReason" AS ENUM ('PASSENGER_REQUEST', 'DRIVER_NO_SHOW', 'PASSENGER_NO_SHOW', 'DUPLICATE', 'OPERATIONAL', 'OTHER');

-- AlterTable
ALTER TABLE "Booking" ADD COLUMN     "cancelNote" TEXT,
DROP COLUMN "cancelReason",
ADD COLUMN     "cancelReason" "CancelReason";
