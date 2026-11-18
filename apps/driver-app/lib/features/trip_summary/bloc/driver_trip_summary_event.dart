import 'package:equatable/equatable.dart';
import '../data/models/driver_edge_state.dart';
import '../data/models/driver_trip_summary_status.dart';

abstract class DriverTripSummaryEvent extends Equatable {
  const DriverTripSummaryEvent();

  @override
  List<Object?> get props => [];
}

class DriverTripSummaryStarted extends DriverTripSummaryEvent {
  final String? tripId;
  final String? paymentMethod;

  const DriverTripSummaryStarted({
    this.tripId,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [tripId, paymentMethod];
}

class DriverTripSummaryCashCollectedPressed extends DriverTripSummaryEvent {
  const DriverTripSummaryCashCollectedPressed();
}

class DriverTripSummaryRatingChanged extends DriverTripSummaryEvent {
  final double rating;
  const DriverTripSummaryRatingChanged(this.rating);

  @override
  List<Object?> get props => [rating];
}

class DriverTripSummaryTagToggled extends DriverTripSummaryEvent {
  final String tag;
  const DriverTripSummaryTagToggled(this.tag);

  @override
  List<Object?> get props => [tag];
}

class DriverTripSummaryFeedbackNotesChanged extends DriverTripSummaryEvent {
  final String notes;
  const DriverTripSummaryFeedbackNotesChanged(this.notes);

  @override
  List<Object?> get props => [notes];
}

class DriverTripSummaryRatingSubmitted extends DriverTripSummaryEvent {
  const DriverTripSummaryRatingSubmitted();
}

class DriverTripSummaryRatingSkipped extends DriverTripSummaryEvent {
  const DriverTripSummaryRatingSkipped();
}

class DriverTripSummaryEdgeStateSelected extends DriverTripSummaryEvent {
  final DriverEdgeStateType edgeType;
  const DriverTripSummaryEdgeStateSelected(this.edgeType);

  @override
  List<Object?> get props => [edgeType];
}

class DriverTripSummaryRetryPaymentPressed extends DriverTripSummaryEvent {
  const DriverTripSummaryRetryPaymentPressed();
}

class DriverTripSummaryDoneReturnPressed extends DriverTripSummaryEvent {
  const DriverTripSummaryDoneReturnPressed();
}

class DriverTripSummaryStateForced extends DriverTripSummaryEvent {
  final DriverTripSummaryStatus status;
  const DriverTripSummaryStateForced(this.status);

  @override
  List<Object?> get props => [status];
}
