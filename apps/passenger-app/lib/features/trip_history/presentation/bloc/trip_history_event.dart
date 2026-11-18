import 'package:equatable/equatable.dart';
import '../../data/models/trip_history_model.dart';

abstract class TripHistoryEvent extends Equatable {
  const TripHistoryEvent();

  @override
  List<Object?> get props => [];
}

class TripHistoryStarted extends TripHistoryEvent {
  final String? tripId;
  final TripPaymentScenario? initialScenario;

  const TripHistoryStarted({
    this.tripId,
    this.initialScenario,
  });

  @override
  List<Object?> get props => [tripId, initialScenario];
}

class TripHistoryScenarioChanged extends TripPaymentScenarioEvent {
  final TripPaymentScenario scenario;
  const TripHistoryScenarioChanged(this.scenario);

  @override
  List<Object?> get props => [scenario];
}

abstract class TripPaymentScenarioEvent extends TripHistoryEvent {
  const TripPaymentScenarioEvent();
}

class TripHistoryViewDetailsTapped extends TripHistoryEvent {
  final String tripId;
  const TripHistoryViewDetailsTapped(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class TripHistoryOpenNotificationsTapped extends TripHistoryEvent {
  const TripHistoryOpenNotificationsTapped();
}

class TripHistoryContactSupportTapped extends TripHistoryEvent {
  const TripHistoryContactSupportTapped();
}

class TripHistoryRateDriverTapped extends TripHistoryEvent {
  final String tripId;
  const TripHistoryRateDriverTapped(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class TripHistoryDownloadReceiptTapped extends TripHistoryEvent {
  final String tripId;
  const TripHistoryDownloadReceiptTapped(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class TripHistoryReportProblemTapped extends TripHistoryEvent {
  final String tripId;
  const TripHistoryReportProblemTapped(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

// New Events for Full Trip History & Filter Screens
class TripHistoryFilterSelected extends TripHistoryEvent {
  final TripHistoryFilter filter;
  const TripHistoryFilterSelected(this.filter);

  @override
  List<Object?> get props => [filter];
}

class TripHistoryCustomDateRangeApplied extends TripHistoryEvent {
  final DateTime startDate;
  final DateTime endDate;

  const TripHistoryCustomDateRangeApplied({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class TripHistoryCardTapped extends TripHistoryEvent {
  final TripRecord trip;
  const TripHistoryCardTapped(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripHistoryQuickActionsClosed extends TripHistoryEvent {
  const TripHistoryQuickActionsClosed();
}

class TripHistoryCalendarTapped extends TripHistoryEvent {
  const TripHistoryCalendarTapped();
}

class TripHistoryDateRangeFilterClosed extends TripHistoryEvent {
  const TripHistoryDateRangeFilterClosed();
}

class TripHistoryRefreshTriggered extends TripHistoryEvent {
  const TripHistoryRefreshTriggered();
}

class TripHistoryQaStateChanged extends TripHistoryEvent {
  final int stateIndex;
  const TripHistoryQaStateChanged(this.stateIndex);

  @override
  List<Object?> get props => [stateIndex];
}
