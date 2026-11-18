import 'package:equatable/equatable.dart';
import '../../data/models/tracking_models.dart';

abstract class LiveTrackingEvent extends Equatable {
  const LiveTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LiveTrackingStarted extends LiveTrackingEvent {
  final TrackingTripDetails? trip;
  final TrackingDriverInfo? driver;
  final LiveTrackingStatus? initialStatus;

  const LiveTrackingStarted({
    this.trip,
    this.driver,
    this.initialStatus,
  });

  @override
  List<Object?> get props => [trip, driver, initialStatus];
}

class LiveTrackingStatusChanged extends LiveTrackingEvent {
  final LiveTrackingStatus status;

  const LiveTrackingStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class LiveTrackingProgressUpdated extends LiveTrackingEvent {
  final double progress;
  final int etaMinutes;
  final String? estimatedArrivalTime;

  const LiveTrackingProgressUpdated({
    required this.progress,
    required this.etaMinutes,
    this.estimatedArrivalTime,
  });

  @override
  List<Object?> get props => [progress, etaMinutes, estimatedArrivalTime];
}

class LiveTrackingTelemetrySyncToggled extends LiveTrackingEvent {
  final bool isSyncing;

  const LiveTrackingTelemetrySyncToggled(this.isSyncing);

  @override
  List<Object?> get props => [isSyncing];
}

class LiveTrackingSosTriggered extends LiveTrackingEvent {
  const LiveTrackingSosTriggered();
}

class LiveTrackingSosCancelled extends LiveTrackingEvent {
  const LiveTrackingSosCancelled();
}

class LiveTrackingCancelRideTapped extends LiveTrackingEvent {
  const LiveTrackingCancelRideTapped();
}

class LiveTrackingCancelConfirmed extends LiveTrackingEvent {
  const LiveTrackingCancelConfirmed();
}

class LiveTrackingCancelDismissed extends LiveTrackingEvent {
  const LiveTrackingCancelDismissed();
}

class LiveTrackingCall911Tapped extends LiveTrackingEvent {
  const LiveTrackingCall911Tapped();
}

class LiveTrackingCopyTrackingIdTapped extends LiveTrackingEvent {
  const LiveTrackingCopyTrackingIdTapped();
}

class LiveTrackingSafetyTapped extends LiveTrackingEvent {
  const LiveTrackingSafetyTapped();
}

class LiveTrackingRecenterTapped extends LiveTrackingEvent {
  const LiveTrackingRecenterTapped();
}
