enum DriverDeclineReason {
  tooFarAway('Too far away'),
  breakTime('Break time'),
  vehicleCapacity('Vehicle capacity'),
  other('Other');

  final String label;
  const DriverDeclineReason(this.label);
}
