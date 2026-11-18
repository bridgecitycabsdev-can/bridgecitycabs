enum DriverCancelReason {
  passengerAsked(
    'Passenger asked me to cancel',
    'passenger_request',
  ),
  passengerNotResponding(
    'Passenger is not responding',
    'passenger_no_show',
  ),
  unsafeLocation(
    'Pickup location is unsafe or unreachable',
    'unsafe_location',
  ),
  vehicleIssue(
    'Vehicle problem / mechanical issue',
    'vehicle_breakdown',
  ),
  other(
    'Other',
    'other',
  );

  final String label;
  final String code;

  const DriverCancelReason(this.label, this.code);
}
