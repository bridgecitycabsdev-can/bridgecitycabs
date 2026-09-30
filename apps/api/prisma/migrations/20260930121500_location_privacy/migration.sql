-- CreateTable
CREATE TABLE "DriverLocationConsent" (
    "id" TEXT NOT NULL,
    "driverId" TEXT NOT NULL,
    "noticeVersion" TEXT NOT NULL,
    "acceptedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DriverLocationConsent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LocationAccessLog" (
    "id" TEXT NOT NULL,
    "actorUserId" TEXT NOT NULL,
    "driverId" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "from" TIMESTAMP(3) NOT NULL,
    "to" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LocationAccessLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "DriverLocationConsent_driverId_noticeVersion_key" ON "DriverLocationConsent"("driverId", "noticeVersion");

-- CreateIndex
CREATE INDEX "LocationAccessLog_driverId_createdAt_idx" ON "LocationAccessLog"("driverId", "createdAt");

-- CreateIndex
CREATE INDEX "LocationAccessLog_actorUserId_createdAt_idx" ON "LocationAccessLog"("actorUserId", "createdAt");

-- AddForeignKey
ALTER TABLE "DriverLocationConsent" ADD CONSTRAINT "DriverLocationConsent_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES "Driver"("id") ON DELETE CASCADE ON UPDATE CASCADE;
