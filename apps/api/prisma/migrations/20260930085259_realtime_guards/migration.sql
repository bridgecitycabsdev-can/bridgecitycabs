-- one open shift per driver
CREATE UNIQUE INDEX one_open_shift_per_driver
  ON "DriverShift" ("driverId") WHERE "endedAt" IS NULL;

-- The driver socket reads branchId from the user token. Copy it onto any
-- driver account that was created without it.
UPDATE "User" AS account
SET "branchId" = driver."branchId"
FROM "Driver" AS driver
WHERE driver."userId" = account.id
  AND account."branchId" IS DISTINCT FROM driver."branchId";
