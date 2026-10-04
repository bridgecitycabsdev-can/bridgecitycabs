-- Day 14 Step 7 — must return zero rows after the booking-matching load test.
-- one_active_booking_per_driver / one_open_offer_per_driver should have blocked
-- any double assignment; this query confirms no violation stuck in the table.

select "driverId", count(*)
from "Booking"
where status in (
  'MATCHED',
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
  'TRIP_STARTED'
)
group by "driverId"
having count(*) > 1;

-- Optional: open offers per driver (also unique-indexed).
select "driverId", count(*)
from "BookingOffer"
where status = 'OFFERED'
group by "driverId"
having count(*) > 1;
