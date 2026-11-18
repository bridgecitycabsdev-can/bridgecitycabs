import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_rating_distribution.dart';
import '../data/models/driver_review_filter_star.dart';
import '../data/models/driver_reviews_config.dart';
import '../data/models/driver_reviews_status.dart';
import '../data/repositories/driver_reviews_repository.dart';
import 'driver_reviews_event.dart';
import 'driver_reviews_state.dart';

class DriverReviewsBloc
    extends Bloc<DriverReviewsEvent, DriverReviewsState> {
  final DriverReviewsRepository repository;

  DriverReviewsBloc({required this.repository})
      : super(DriverReviewsState.initial()) {
    on<DriverReviewsStarted>(_onStarted);
    on<DriverReviewsFilterStarSelected>(_onFilterStarSelected);
    on<DriverReviewsFilterReset>(_onFilterReset);
    on<DriverReviewsReviewSelected>(_onReviewSelected);
    on<DriverReviewsModalDismissed>(_onModalDismissed);
    on<DriverReviewsReportReviewPressed>(_onReportReviewPressed);
    on<DriverReviewsSyncRetryPressed>(_onSyncRetryPressed);
    on<DriverReviewsGoOnlinePressed>(_onGoOnlinePressed);
    on<DriverReviewsLoadMoreTriggered>(_onLoadMoreTriggered);
    on<DriverReviewsInspectorTabSwitched>(_onInspectorTabSwitched);
    on<DriverReviewsStateForced>(_onStateForced);
  }

  void _onStarted(
    DriverReviewsStarted event,
    Emitter<DriverReviewsState> emit,
  ) {
    add(DriverReviewsStateForced(event.initialStatus));
  }

  Future<void> _onFilterStarSelected(
    DriverReviewsFilterStarSelected event,
    Emitter<DriverReviewsState> emit,
  ) async {
    emit(state.copyWith(selectedFilter: event.filter, isActionLoading: true));
    try {
      final fetched = await repository.fetchReviews(
        starRating: event.filter.starValue,
      );

      if (fetched.isEmpty && event.filter.starValue == 1) {
        emit(
          state.copyWith(
            status: DriverReviewsStatus.noMatchingFilter,
            reviews: [],
            isActionLoading: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DriverReviewsStatus.list,
            reviews: fetched,
            isActionLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Failed to filter reviews: $e',
        ),
      );
    }
  }

  Future<void> _onFilterReset(
    DriverReviewsFilterReset event,
    Emitter<DriverReviewsState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedFilter: DriverReviewFilterStar.all,
        status: DriverReviewsStatus.list,
        isActionLoading: true,
      ),
    );
    try {
      final all = await repository.fetchReviews();
      emit(
        state.copyWith(
          status: DriverReviewsStatus.list,
          reviews: all,
          isActionLoading: false,
          feedbackMessage: 'Filters reset to All (120)',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isActionLoading: false));
    }
  }

  void _onReviewSelected(
    DriverReviewsReviewSelected event,
    Emitter<DriverReviewsState> emit,
  ) {
    final matched = state.reviews.firstWhere(
      (r) => r.id == event.reviewId,
      orElse: () => DriverReviewsConfig.singleDetailReview(),
    );
    emit(
      state.copyWith(
        status: DriverReviewsStatus.detailModal,
        selectedReview: matched,
      ),
    );
  }

  void _onModalDismissed(
    DriverReviewsModalDismissed event,
    Emitter<DriverReviewsState> emit,
  ) {
    emit(state.copyWith(status: DriverReviewsStatus.list));
  }

  Future<void> _onReportReviewPressed(
    DriverReviewsReportReviewPressed event,
    Emitter<DriverReviewsState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.reportReview(
        event.reviewId,
        'Flagged for review by driver',
      );
      emit(
        state.copyWith(
          isActionLoading: false,
          status: DriverReviewsStatus.list,
          feedbackMessage:
              'Review ${event.reviewId} submitted for Lethbridge Taxi Commission audit.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Failed to report review: $e',
        ),
      );
    }
  }

  Future<void> _onSyncRetryPressed(
    DriverReviewsSyncRetryPressed event,
    Emitter<DriverReviewsState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.retryReviewsSync();
      emit(
        state.copyWith(
          isActionLoading: false,
          isOfflineWarningVisible: false,
          feedbackMessage:
              'Reviews cache synced with Bridge City dispatch server.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Sync failed: $e',
        ),
      );
    }
  }

  void _onGoOnlinePressed(
    DriverReviewsGoOnlinePressed event,
    Emitter<DriverReviewsState> emit,
  ) {
    emit(
      state.copyWith(
        shouldNavigateToDispatch: true,
        feedbackMessage: 'Navigating to dispatch shift...',
      ),
    );
  }

  Future<void> _onLoadMoreTriggered(
    DriverReviewsLoadMoreTriggered event,
    Emitter<DriverReviewsState> emit,
  ) async {
    emit(state.copyWith(isLoadingMore: true));
    await Future.delayed(const Duration(milliseconds: 300));
    final more = DriverReviewsConfig.feedScrollPresetReviews();
    emit(
      state.copyWith(
        isLoadingMore: false,
        reviews: [...state.reviews, ...more],
      ),
    );
  }

  void _onInspectorTabSwitched(
    DriverReviewsInspectorTabSwitched event,
    Emitter<DriverReviewsState> emit,
  ) {
    emit(state.copyWith(inspectorTabIndex: event.tabIndex));
  }

  void _onStateForced(
    DriverReviewsStateForced event,
    Emitter<DriverReviewsState> emit,
  ) {
    switch (event.status) {
      case DriverReviewsStatus.list:
        emit(
          state.copyWith(
            status: DriverReviewsStatus.list,
            selectedFilter: DriverReviewFilterStar.all,
            reviews: DriverReviewsConfig.listPresetReviews(),
            isOfflineWarningVisible: false,
            isActionLoading: false,
          ),
        );
        break;
      case DriverReviewsStatus.detailModal:
        emit(
          state.copyWith(
            status: DriverReviewsStatus.detailModal,
            selectedReview: DriverReviewsConfig.singleDetailReview(),
            isActionLoading: false,
          ),
        );
        break;
      case DriverReviewsStatus.edgeStatesGallery:
        emit(
          state.copyWith(
            status: DriverReviewsStatus.edgeStatesGallery,
            isOfflineWarningVisible: true,
            inspectorTabIndex: 0,
            isActionLoading: false,
          ),
        );
        break;
      case DriverReviewsStatus.noMatchingFilter:
        emit(
          state.copyWith(
            status: DriverReviewsStatus.noMatchingFilter,
            selectedFilter: DriverReviewFilterStar.star1,
            reviews: [],
            isActionLoading: false,
          ),
        );
        break;
      case DriverReviewsStatus.newDriverEmpty:
        emit(
          state.copyWith(
            status: DriverReviewsStatus.newDriverEmpty,
            distribution: const DriverRatingDistribution(
              overallRating: 0.0,
              totalReviews: 0,
              star5Count: 0,
              star4Count: 0,
              star3Count: 0,
              star2Count: 0,
              star1Count: 0,
            ),
            reviews: [],
            isActionLoading: false,
          ),
        );
        break;
      case DriverReviewsStatus.serviceFailure:
        emit(
          state.copyWith(
            status: DriverReviewsStatus.serviceFailure,
            isActionLoading: false,
          ),
        );
        break;
    }
  }
}
