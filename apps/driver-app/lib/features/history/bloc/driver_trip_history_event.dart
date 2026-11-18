import 'package:equatable/equatable.dart';
import '../data/models/driver_trip_filter_period.dart';
import '../data/models/driver_trip_history_status.dart';

abstract class DriverTripHistoryEvent extends Equatable {
  const DriverTripHistoryEvent();

  @override
  List<Object?> get props => [];
}

class DriverTripHistoryStarted extends DriverTripHistoryEvent {
  final DriverTripHistoryStatus initialStatus;

  const DriverTripHistoryStarted({
    this.initialStatus = DriverTripHistoryStatus.gallery,
  });

  @override
  List<Object?> get props => [initialStatus];
}

class DriverTripHistoryFilterRequested extends DriverTripHistoryEvent {
  const DriverTripHistoryFilterRequested();
}

class DriverTripHistoryFilterDismissed extends DriverTripHistoryEvent {
  const DriverTripHistoryFilterDismissed();
}

class DriverTripHistoryPeriodSelected extends DriverTripHistoryEvent {
  final DriverTripFilterPeriod period;

  const DriverTripHistoryPeriodSelected(this.period);

  @override
  List<Object?> get props => [period];
}

class DriverTripHistoryCustomRangeConfigured extends DriverTripHistoryEvent {
  final String startDate;
  final String endDate;

  const DriverTripHistoryCustomRangeConfigured({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class DriverTripHistoryFilterApplied extends DriverTripHistoryEvent {
  const DriverTripHistoryFilterApplied();
}

class DriverTripHistoryTripSelected extends DriverTripHistoryEvent {
  final String tripId;

  const DriverTripHistoryTripSelected(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class DriverTripHistoryBackToGalleryPressed extends DriverTripHistoryEvent {
  const DriverTripHistoryBackToGalleryPressed();
}

class DriverTripHistorySyncRetryPressed extends DriverTripHistoryEvent {
  const DriverTripHistorySyncRetryPressed();
}

class DriverTripHistoryGoOnlinePressed extends DriverTripHistoryEvent {
  const DriverTripHistoryGoOnlinePressed();
}

class DriverTripHistoryIssueReported extends DriverTripHistoryEvent {
  final String tripId;

  const DriverTripHistoryIssueReported(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class DriverTripHistoryStateForced extends DriverTripHistoryEvent {
  final DriverTripHistoryStatus status;

  const DriverTripHistoryStateForced(this.status);

  @override
  List<Object?> get props => [status];
}
