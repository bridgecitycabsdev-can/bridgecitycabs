-- one open assignment per booking
CREATE UNIQUE INDEX one_open_assignment_per_booking
  ON "BookingAssignment" ("bookingId") WHERE "endedAt" IS NULL;

-- a driver can hold only one live booking at a time
CREATE UNIQUE INDEX one_active_booking_per_driver
  ON "Booking" ("driverId")
  WHERE "driverId" IS NOT NULL
    AND status IN ('MATCHED','DRIVER_ASSIGNED','DRIVER_ARRIVING','DRIVER_ARRIVED','TRIP_STARTED');

-- status history can never be edited or deleted
CREATE FUNCTION forbid_history_mutation() RETURNS trigger AS $$
BEGIN RAISE EXCEPTION 'booking status history is append-only'; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER booking_history_immutable
  BEFORE UPDATE OR DELETE ON "BookingStatusHistory"
  FOR EACH ROW EXECUTE FUNCTION forbid_history_mutation();
