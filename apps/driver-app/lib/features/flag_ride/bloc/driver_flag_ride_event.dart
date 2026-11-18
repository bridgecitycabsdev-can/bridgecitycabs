import 'package:equatable/equatable.dart';
import '../data/models/driver_flag_ride_status.dart';

abstract class DriverFlagRideEvent extends Equatable {
  const DriverFlagRideEvent();

  @override
  List<Object?> get props => [];
}

class DriverFlagRideStarted extends DriverFlagRideEvent {
  const DriverFlagRideStarted();
}

class DriverFlagPassengerCountIncremented extends DriverFlagRideEvent {
  const DriverFlagPassengerCountIncremented();
}

class DriverFlagPassengerCountDecremented extends DriverFlagRideEvent {
  const DriverFlagPassengerCountDecremented();
}

class DriverFlagDestinationSelected extends DriverFlagRideEvent {
  final String destination;
  const DriverFlagDestinationSelected(this.destination);

  @override
  List<Object?> get props => [destination];
}

class DriverFlagStartRidePressed extends DriverFlagRideEvent {
  const DriverFlagStartRidePressed();
}

class DriverFlagEndTripPressed extends DriverFlagRideEvent {
  const DriverFlagEndTripPressed();
}

class DriverFlagCashCollectedPressed extends DriverFlagRideEvent {
  const DriverFlagCashCollectedPressed();
}

class DriverFlagEdgeCategorySelected extends DriverFlagRideEvent {
  final int categoryIndex;
  const DriverFlagEdgeCategorySelected(this.categoryIndex);

  @override
  List<Object?> get props => [categoryIndex];
}

class DriverFlagRetryTelemetryPressed extends DriverFlagRideEvent {
  const DriverFlagRetryTelemetryPressed();
}

class DriverFlagRefreshCalculationPressed extends DriverFlagRideEvent {
  const DriverFlagRefreshCalculationPressed();
}

class DriverFlagHoldMeterPressed extends DriverFlagRideEvent {
  const DriverFlagHoldMeterPressed();
}

class DriverFlagEndOfflineRidePressed extends DriverFlagRideEvent {
  const DriverFlagEndOfflineRidePressed();
}

class DriverFlagStateForced extends DriverFlagRideEvent {
  final DriverFlagRideStatus status;
  const DriverFlagStateForced(this.status);

  @override
  List<Object?> get props => [status];
}
