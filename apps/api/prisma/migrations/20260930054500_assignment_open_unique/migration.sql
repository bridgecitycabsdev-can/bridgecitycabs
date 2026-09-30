-- CreateIndex
CREATE UNIQUE INDEX "one_open_assignment_per_vehicle"
  ON "DriverVehicleAssignment" ("vehicleId") WHERE "endedAt" IS NULL;

-- CreateIndex
CREATE UNIQUE INDEX "one_open_assignment_per_driver"
  ON "DriverVehicleAssignment" ("driverId") WHERE "endedAt" IS NULL;
