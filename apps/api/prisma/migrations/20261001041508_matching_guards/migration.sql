-- one open offer per booking
CREATE UNIQUE INDEX one_open_offer_per_booking
  ON "BookingOffer" ("bookingId") WHERE status = 'OFFERED';

-- a driver can hold only one open offer at a time
CREATE UNIQUE INDEX one_open_offer_per_driver
  ON "BookingOffer" ("driverId") WHERE status = 'OFFERED';
