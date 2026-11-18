import 'package:equatable/equatable.dart';
import '../../data/models/rate_driver_models.dart';

abstract class RateDriverEvent extends Equatable {
  const RateDriverEvent();

  @override
  List<Object?> get props => [];
}

class RateDriverStarted extends RateDriverEvent {
  final DriverRatingProfile? driverProfile;
  final TripSummaryInfo? tripInfo;
  final RateDriverStatus? initialStatus;
  final int? initialStars;
  final List<RatingTag>? initialTags;
  final String? initialComment;

  const RateDriverStarted({
    this.driverProfile,
    this.tripInfo,
    this.initialStatus,
    this.initialStars,
    this.initialTags,
    this.initialComment,
  });

  @override
  List<Object?> get props => [
        driverProfile,
        tripInfo,
        initialStatus,
        initialStars,
        initialTags,
        initialComment,
      ];
}

class RateDriverStarsSelected extends RateDriverEvent {
  final int stars;

  const RateDriverStarsSelected(this.stars);

  @override
  List<Object?> get props => [stars];
}

class RateDriverTagToggled extends RateDriverEvent {
  final RatingTag tag;

  const RateDriverTagToggled(this.tag);

  @override
  List<Object?> get props => [tag];
}

class RateDriverCommentChanged extends RateDriverEvent {
  final String comment;

  const RateDriverCommentChanged(this.comment);

  @override
  List<Object?> get props => [comment];
}

class RateDriverReviewSubmitted extends RateDriverEvent {
  const RateDriverReviewSubmitted();
}

class RateDriverSkipTapped extends RateDriverEvent {
  const RateDriverSkipTapped();
}

class RateDriverBackToHomeTapped extends RateDriverEvent {
  const RateDriverBackToHomeTapped();
}

class RateDriverBackToReceiptTapped extends RateDriverEvent {
  const RateDriverBackToReceiptTapped();
}

class RateDriverReportIssueTapped extends RateDriverEvent {
  const RateDriverReportIssueTapped();
}
