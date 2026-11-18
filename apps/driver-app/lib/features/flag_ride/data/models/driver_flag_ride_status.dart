enum DriverFlagRideStatus {
  startFlagRide,
  flagInProgress,
  flagComplete,
  edgeStates,
  returnedToHome;

  String get label {
    switch (this) {
      case DriverFlagRideStatus.startFlagRide:
        return 'Start A Flag Ride';
      case DriverFlagRideStatus.flagInProgress:
        return 'Flag Ride In Progress';
      case DriverFlagRideStatus.flagComplete:
        return 'Flag Ride Complete';
      case DriverFlagRideStatus.edgeStates:
        return '7 Edge States';
      case DriverFlagRideStatus.returnedToHome:
        return 'Returned to Home';
    }
  }

  bool get isStart => this == DriverFlagRideStatus.startFlagRide;
  bool get isInProgress => this == DriverFlagRideStatus.flagInProgress;
  bool get isComplete => this == DriverFlagRideStatus.flagComplete;
  bool get isEdgeStates => this == DriverFlagRideStatus.edgeStates;
}
