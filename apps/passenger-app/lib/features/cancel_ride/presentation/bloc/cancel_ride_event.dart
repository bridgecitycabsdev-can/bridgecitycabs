import 'package:equatable/equatable.dart';
import '../../data/models/cancel_ride_models.dart';

abstract class CancelRideEvent extends Equatable {
  const CancelRideEvent();

  @override
  List<Object?> get props => [];
}

class CancelRideStarted extends CancelRideEvent {
  final CancellationDetails? details;
  final bool? isTripStarted;

  const CancelRideStarted({
    this.details,
    this.isTripStarted,
  });

  @override
  List<Object?> get props => [details, isTripStarted];
}

class CancelRideReasonSelected extends CancelRideEvent {
  final String reason;

  const CancelRideReasonSelected(this.reason);

  @override
  List<Object?> get props => [reason];
}

class CancelRideCustomReasonChanged extends CancelRideEvent {
  final String customReason;

  const CancelRideCustomReasonChanged(this.customReason);

  @override
  List<Object?> get props => [customReason];
}

class CancelRideConfirmed extends CancelRideEvent {
  const CancelRideConfirmed();
}

class CancelRideDismissed extends CancelRideEvent {
  const CancelRideDismissed();
}

class CancelRideBackToTripTapped extends CancelRideEvent {
  const CancelRideBackToTripTapped();
}

class CancelRideEmergencyCallTapped extends CancelRideEvent {
  const CancelRideEmergencyCallTapped();
}

class CancelRideSuccessBannerDismissed extends CancelRideEvent {
  const CancelRideSuccessBannerDismissed();
}
