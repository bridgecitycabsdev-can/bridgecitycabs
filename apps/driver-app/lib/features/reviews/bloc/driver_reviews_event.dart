import 'package:equatable/equatable.dart';
import '../data/models/driver_review_filter_star.dart';
import '../data/models/driver_reviews_status.dart';

abstract class DriverReviewsEvent extends Equatable {
  const DriverReviewsEvent();

  @override
  List<Object?> get props => [];
}

class DriverReviewsStarted extends DriverReviewsEvent {
  final DriverReviewsStatus initialStatus;

  const DriverReviewsStarted({
    this.initialStatus = DriverReviewsStatus.list,
  });

  @override
  List<Object?> get props => [initialStatus];
}

class DriverReviewsFilterStarSelected extends DriverReviewsEvent {
  final DriverReviewFilterStar filter;

  const DriverReviewsFilterStarSelected(this.filter);

  @override
  List<Object?> get props => [filter];
}

class DriverReviewsFilterReset extends DriverReviewsEvent {
  const DriverReviewsFilterReset();
}

class DriverReviewsReviewSelected extends DriverReviewsEvent {
  final String reviewId;

  const DriverReviewsReviewSelected(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

class DriverReviewsModalDismissed extends DriverReviewsEvent {
  const DriverReviewsModalDismissed();
}

class DriverReviewsReportReviewPressed extends DriverReviewsEvent {
  final String reviewId;

  const DriverReviewsReportReviewPressed(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

class DriverReviewsSyncRetryPressed extends DriverReviewsEvent {
  const DriverReviewsSyncRetryPressed();
}

class DriverReviewsGoOnlinePressed extends DriverReviewsEvent {
  const DriverReviewsGoOnlinePressed();
}

class DriverReviewsLoadMoreTriggered extends DriverReviewsEvent {
  const DriverReviewsLoadMoreTriggered();
}

class DriverReviewsInspectorTabSwitched extends DriverReviewsEvent {
  final int tabIndex;

  const DriverReviewsInspectorTabSwitched(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class DriverReviewsStateForced extends DriverReviewsEvent {
  final DriverReviewsStatus status;

  const DriverReviewsStateForced(this.status);

  @override
  List<Object?> get props => [status];
}
