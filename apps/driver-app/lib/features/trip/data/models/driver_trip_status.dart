enum DriverTripStatus {
  headingToPickup,
  waitingForPassenger,
  cancelTripModal,
  telemetryAlert,
  onTrip,
  endTripModal,
  emergencySosModal,
  canceled;

  String get label {
    switch (this) {
      case DriverTripStatus.headingToPickup:
        return 'Heading to pickup';
      case DriverTripStatus.waitingForPassenger:
        return 'Waiting for passenger';
      case DriverTripStatus.cancelTripModal:
        return 'Cancel trip modal';
      case DriverTripStatus.telemetryAlert:
        return 'Fleet Telemetry & Weak GPS';
      case DriverTripStatus.onTrip:
        return 'Active Trip Navigation';
      case DriverTripStatus.endTripModal:
        return 'End trip modal';
      case DriverTripStatus.emergencySosModal:
        return 'Emergency SOS';
      case DriverTripStatus.canceled:
        return 'Trip canceled';
    }
  }

  bool get isHeadingToPickup => this == DriverTripStatus.headingToPickup;
  bool get isWaitingForPassenger => this == DriverTripStatus.waitingForPassenger;
  bool get isCancelTripModal => this == DriverTripStatus.cancelTripModal;
  bool get isTelemetryAlert => this == DriverTripStatus.telemetryAlert;
  bool get isOnTrip => this == DriverTripStatus.onTrip;
  bool get isEndTripModal => this == DriverTripStatus.endTripModal;
  bool get isEmergencySosModal => this == DriverTripStatus.emergencySosModal;
}
