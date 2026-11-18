import 'package:equatable/equatable.dart';
import '../../data/models/rate_driver_config.dart';
import '../../data/models/rate_driver_models.dart';

class RateDriverState extends Equatable {
  final RateDriverStatus status;
  final DriverRatingProfile driver;
  final TripSummaryInfo trip;
  final int selectedStars;
  final List<RatingTag> selectedTags;
  final String comment;
  final bool isSubmitting;
  final String? errorMessage;
  final bool navigateToHome;
  final bool navigateToReceipt;
  final bool showReportIssueSheet;

  const RateDriverState({
    this.status = RateDriverStatus.initial,
    this.driver = const DriverRatingProfile(),
    this.trip = const TripSummaryInfo(),
    this.selectedStars = 0,
    this.selectedTags = const [],
    this.comment = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.navigateToHome = false,
    this.navigateToReceipt = false,
    this.showReportIssueSheet = false,
  });

  bool get isUnrated => selectedStars == 0;
  bool get isLowRating => status == RateDriverStatus.lowRating;
  bool get isHighRating => status == RateDriverStatus.highRating;
  bool get isSuccess => status == RateDriverStatus.success;
  bool get isAlreadyRated => status == RateDriverStatus.alreadyRated;
  bool get isWindowExpired => status == RateDriverStatus.windowExpired;

  bool get canSubmit =>
      selectedStars > 0 &&
      !isSubmitting &&
      status != RateDriverStatus.alreadyRated &&
      status != RateDriverStatus.windowExpired;

  String get sentimentLabel => RateDriverConfig.getSentimentLabel(selectedStars);
  RatingSentiment get sentiment => RateDriverConfig.getSentiment(selectedStars);

  List<RatingTag> get availableTags =>
      selectedStars <= 2 ? RateDriverConfig.negativeTags : RateDriverConfig.positiveTags;

  String get tagsSectionTitle =>
      selectedStars <= 2 ? 'What went wrong?' : 'WHAT WENT WELL?';

  String get tagsSectionSubtitle =>
      selectedStars <= 2 ? 'Select all that apply' : '';

  RateDriverState copyWith({
    RateDriverStatus? status,
    DriverRatingProfile? driver,
    TripSummaryInfo? trip,
    int? selectedStars,
    List<RatingTag>? selectedTags,
    String? comment,
    bool? isSubmitting,
    String? errorMessage,
    bool? navigateToHome,
    bool? navigateToReceipt,
    bool? showReportIssueSheet,
  }) {
    return RateDriverState(
      status: status ?? this.status,
      driver: driver ?? this.driver,
      trip: trip ?? this.trip,
      selectedStars: selectedStars ?? this.selectedStars,
      selectedTags: selectedTags ?? this.selectedTags,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      navigateToHome: navigateToHome ?? this.navigateToHome,
      navigateToReceipt: navigateToReceipt ?? this.navigateToReceipt,
      showReportIssueSheet: showReportIssueSheet ?? this.showReportIssueSheet,
    );
  }

  @override
  List<Object?> get props => [
        status,
        driver,
        trip,
        selectedStars,
        selectedTags,
        comment,
        isSubmitting,
        errorMessage,
        navigateToHome,
        navigateToReceipt,
        showReportIssueSheet,
      ];
}
