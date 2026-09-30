-- AlterTable
ALTER TABLE "Driver" ADD COLUMN     "presenceVersion" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "DriverShift" ADD COLUMN     "endNote" TEXT;
