-- A passenger can hold only one booking that is still open.
CREATE UNIQUE INDEX one_active_booking_per_passenger
  ON "Booking" ("passengerId")
  WHERE "passengerId" IS NOT NULL
    AND status NOT IN ('CANCELLED', 'CLOSED');
