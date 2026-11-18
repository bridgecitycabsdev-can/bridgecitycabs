import 'package:equatable/equatable.dart';
import '../data/models/driver_cancel_reason.dart';
import '../data/models/driver_trip_status.dart';

abstract class DriverTripEvent extends Equatable {
  const DriverTripEvent();

  @override
  List<Object?> get props => [];
}

class DriverTripStarted extends DriverTripEvent {
  const DriverTripStarted();
}

class DriverTripArrivedPressed extends DriverTripEvent {
  final bool bypassProximity;
  const DriverTripArrivedPressed({this.bypassProximity = false});

  @override
  List<Object?> get props => [bypassProximity];
}

class DriverTripStartTripPressed extends DriverTripEvent {
  const DriverTripStartTripPressed();
}

class DriverTripCancelRequested extends DriverTripEvent {
  const DriverTripCancelRequested();
}

class DriverTripCancelReasonSelected extends DriverTripEvent {
  final DriverCancelReason reason;
  const DriverTripCancelReasonSelected(this.reason);

  @override
  List<Object?> get props => [reason];
}

class DriverTripCancelConfirmed extends DriverTripEvent {
  const DriverTripCancelConfirmed();
}

class DriverTripKeepTripPressed extends DriverTripEvent {
  const DriverTripKeepTripPressed();
}

class DriverTripExternalNavigationPressed extends DriverTripEvent {
  const DriverTripExternalNavigationPressed();
}

class DriverTripPassengerNotHerePressed extends DriverTripEvent {
  const DriverTripPassengerNotHerePressed();
}

class DriverTripTelemetryTabSelected extends DriverTripEvent {
  final int tabIndex;
  const DriverTripTelemetryTabSelected(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class DriverTripWaitTimerTicked extends DriverTripEvent {
  final int newElapsedSeconds;
  const DriverTripWaitTimerTicked(this.newElapsedSeconds);

  @override
  List<Object?> get props => [newElapsedSeconds];
}

// In-progress Active Navigation & End Trip Events (Screenshots 1 & 2)
class DriverTripEndTripRequested extends DriverTripEvent {
  const DriverTripEndTripRequested();
}

class DriverTripProximityModeToggled extends DriverTripEvent {
  final String mode; // 'far' or 'within50m'
  const DriverTripProximityModeToggled(this.mode);

  @override
  List<Object?> get props => [mode];
}

class DriverTripEndTripConfirmed extends DriverTripEvent {
  const DriverTripEndTripConfirmed();
}

class DriverTripEmergencySosRequested extends DriverTripEvent {
  const DriverTripEmergencySosRequested();
}

class DriverTripEmergencySosTriggered extends DriverTripEvent {
  const DriverTripEmergencySosTriggered();
}

class DriverTripEmergencySosCancelled extends DriverTripEvent {
  const DriverTripEmergencySosCancelled();
}

class DriverTripStateForced extends DriverTripEvent {
  final DriverTripStatus targetStatus;
  const DriverTripStateForced(this.targetStatus);

  @override
  List<Object?> get props => [targetStatus];
}
