import 'package:equatable/equatable.dart';
import '../data/models/driver_rating_distribution.dart';
import '../data/models/driver_review_filter_star.dart';
import '../data/models/driver_review_item.dart';
import '../data/models/driver_reviews_config.dart';
import '../data/models/driver_reviews_status.dart';

class DriverReviewsState extends Equatable {
  final DriverReviewsStatus status;
  final DriverRatingDistribution distribution;
  final DriverReviewFilterStar selectedFilter;
  final List<DriverReviewItem> reviews;
  final DriverReviewItem? selectedReview;
  final bool isOfflineWarningVisible;
  final bool isActionLoading;
  final bool isLoadingMore;
  final int inspectorTabIndex;
  final String? feedbackMessage;
  final bool shouldNavigateToDispatch;

  const DriverReviewsState({
    required this.status,
    this.distribution = DriverReviewsConfig.defaultDistribution,
    this.selectedFilter = DriverReviewFilterStar.all,
    this.reviews = const [],
    this.selectedReview,
    this.isOfflineWarningVisible = false,
    this.isActionLoading = false,
    this.isLoadingMore = false,
    this.inspectorTabIndex = 0,
    this.feedbackMessage,
    this.shouldNavigateToDispatch = false,
  });

  factory DriverReviewsState.initial() {
    return DriverReviewsState(
      status: DriverReviewsStatus.list,
      distribution: DriverReviewsConfig.defaultDistribution,
      selectedFilter: DriverReviewFilterStar.all,
      reviews: DriverReviewsConfig.listPresetReviews(),
      selectedReview: DriverReviewsConfig.singleDetailReview(),
      isOfflineWarningVisible: false,
      isActionLoading: false,
      isLoadingMore: false,
      inspectorTabIndex: 0,
      feedbackMessage: null,
      shouldNavigateToDispatch: false,
    );
  }

  DriverReviewsState copyWith({
    DriverReviewsStatus? status,
    DriverRatingDistribution? distribution,
    DriverReviewFilterStar? selectedFilter,
    List<DriverReviewItem>? reviews,
    DriverReviewItem? selectedReview,
    bool? isOfflineWarningVisible,
    bool? isActionLoading,
    bool? isLoadingMore,
    int? inspectorTabIndex,
    String? feedbackMessage,
    bool? shouldNavigateToDispatch,
  }) {
    return DriverReviewsState(
      status: status ?? this.status,
      distribution: distribution ?? this.distribution,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      reviews: reviews ?? this.reviews,
      selectedReview: selectedReview ?? this.selectedReview,
      isOfflineWarningVisible:
          isOfflineWarningVisible ?? this.isOfflineWarningVisible,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      inspectorTabIndex: inspectorTabIndex ?? this.inspectorTabIndex,
      feedbackMessage: feedbackMessage,
      shouldNavigateToDispatch:
          shouldNavigateToDispatch ?? this.shouldNavigateToDispatch,
    );
  }

  bool get isList => status == DriverReviewsStatus.list;
  bool get isDetailModalVisible => status == DriverReviewsStatus.detailModal;
  bool get isEdgeStatesGallery =>
      status == DriverReviewsStatus.edgeStatesGallery;
  bool get isNoMatchingFilter => status == DriverReviewsStatus.noMatchingFilter;
  bool get isNewDriverEmpty => status == DriverReviewsStatus.newDriverEmpty;
  bool get isServiceFailure => status == DriverReviewsStatus.serviceFailure;

  @override
  List<Object?> get props => [
    status,
    distribution,
    selectedFilter,
    reviews,
    selectedReview,
    isOfflineWarningVisible,
    isActionLoading,
    isLoadingMore,
    inspectorTabIndex,
    feedbackMessage,
    shouldNavigateToDispatch,
  ];
}
