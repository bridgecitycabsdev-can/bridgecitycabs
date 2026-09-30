-- AlterTable
ALTER TABLE "Passenger" ADD COLUMN     "blockReason" TEXT,
ADD COLUMN     "blockedAt" TIMESTAMP(3),
ADD COLUMN     "unblockReason" TEXT;
