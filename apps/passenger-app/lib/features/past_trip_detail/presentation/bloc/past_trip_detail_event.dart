import 'package:equatable/equatable.dart';
import '../../data/models/past_trip_detail_model.dart';

abstract class PastTripDetailEvent extends Equatable {
  const PastTripDetailEvent();

  @override
  List<Object?> get props => [];
}

class PastTripDetailStarted extends PastTripDetailEvent {
  final String? tripId;
  final TripDetailSegment? initialSegment;
  final PastTripQaScenario? initialScenario;

  const PastTripDetailStarted({
    this.tripId,
    this.initialSegment,
    this.initialScenario,
  });

  @override
  List<Object?> get props => [tripId, initialSegment, initialScenario];
}

class PastTripDetailSegmentChanged extends PastTripDetailEvent {
  final TripDetailSegment segment;

  const PastTripDetailSegmentChanged(this.segment);

  @override
  List<Object?> get props => [segment];
}

class PastTripDetailQaScenarioSelected extends PastTripDetailEvent {
  final PastTripQaScenario scenario;

  const PastTripDetailQaScenarioSelected(this.scenario);

  @override
  List<Object?> get props => [scenario];
}

class PastTripDetailCopyTripIdTapped extends PastTripDetailEvent {
  final String tripId;

  const PastTripDetailCopyTripIdTapped(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class PastTripDetailDownloadReceiptTapped extends PastTripDetailEvent {
  final String tripId;

  const PastTripDetailDownloadReceiptTapped(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class PastTripDetailBookReturnTapped extends PastTripDetailEvent {
  final PastTripDetailModel trip;

  const PastTripDetailBookReturnTapped(this.trip);

  @override
  List<Object?> get props => [trip];
}

class PastTripDetailRateDriverTapped extends PastTripDetailEvent {
  const PastTripDetailRateDriverTapped();
}

class PastTripDetailReportProblemTapped extends PastTripDetailEvent {
  const PastTripDetailReportProblemTapped();
}

class PastTripDetailOpenNotificationsTapped extends PastTripDetailEvent {
  const PastTripDetailOpenNotificationsTapped();
}

class PastTripDetailContactSupportTapped extends PastTripDetailEvent {
  const PastTripDetailContactSupportTapped();
}

class PastTripDetailToggleViewMode extends PastTripDetailEvent {
  const PastTripDetailToggleViewMode();
}
