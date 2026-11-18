import 'package:equatable/equatable.dart';
import '../../data/models/no_driver_models.dart';

abstract class NoDriverEvent extends Equatable {
  const NoDriverEvent();

  @override
  List<Object?> get props => [];
}

class NoDriverStarted extends NoDriverEvent {
  final NoDriverBookingDetails? booking;

  const NoDriverStarted({this.booking});

  @override
  List<Object?> get props => [booking];
}

class NoDriverRetryTapped extends NoDriverEvent {
  const NoDriverRetryTapped();
}

class NoDriverCancelTapped extends NoDriverEvent {
  const NoDriverCancelTapped();
}

class NoDriverCancelConfirmed extends NoDriverEvent {
  const NoDriverCancelConfirmed();
}

class NoDriverCopyTrackingIdTapped extends NoDriverEvent {
  const NoDriverCopyTrackingIdTapped();
}

class NoDriverCallDispatchTapped extends NoDriverEvent {
  const NoDriverCallDispatchTapped();
}

class NoDriverRecenterTapped extends NoDriverEvent {
  const NoDriverRecenterTapped();
}

class NoDriverBackTapped extends NoDriverEvent {
  const NoDriverBackTapped();
}

class NoDriverBookDifferentVehicleTapped extends NoDriverEvent {
  const NoDriverBookDifferentVehicleTapped();
}

class NoDriverAutoReconnectToggled extends NoDriverEvent {
  final bool isAutoReconnecting;

  const NoDriverAutoReconnectToggled(this.isAutoReconnecting);

  @override
  List<Object?> get props => [isAutoReconnecting];
}
