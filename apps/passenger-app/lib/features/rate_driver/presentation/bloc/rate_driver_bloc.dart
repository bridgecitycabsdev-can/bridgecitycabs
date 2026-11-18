import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/rate_driver_models.dart';
import '../../data/repositories/rate_driver_repository.dart';
import 'rate_driver_event.dart';
import 'rate_driver_state.dart';

class RateDriverBloc extends Bloc<RateDriverEvent, RateDriverState> {
  final RateDriverRepository repository;

  RateDriverBloc({RateDriverRepository? repository})
      : repository = repository ?? MockRateDriverRepository(),
        super(const RateDriverState()) {
    on<RateDriverStarted>(_onStarted);
    on<RateDriverStarsSelected>(_onStarsSelected);
    on<RateDriverTagToggled>(_onTagToggled);
    on<RateDriverCommentChanged>(_onCommentChanged);
    on<RateDriverReviewSubmitted>(_onReviewSubmitted);
    on<RateDriverSkipTapped>(_onSkipTapped);
    on<RateDriverBackToHomeTapped>(_onBackToHomeTapped);
    on<RateDriverBackToReceiptTapped>(_onBackToReceiptTapped);
    on<RateDriverReportIssueTapped>(_onReportIssueTapped);
  }

  void _onStarted(
    RateDriverStarted event,
    Emitter<RateDriverState> emit,
  ) {
    final driver = event.driverProfile ?? state.driver;
    final trip = event.tripInfo ?? state.trip;
    final stars = event.initialStars ?? state.selectedStars;
    final tags = event.initialTags ?? state.selectedTags;
    final comment = event.initialComment ?? state.comment;

    RateDriverStatus determinedStatus = event.initialStatus ?? RateDriverStatus.initial;
    if (event.initialStatus == null) {
      if (stars == 0) {
        determinedStatus = RateDriverStatus.initial;
      } else if (stars <= 2) {
        determinedStatus = RateDriverStatus.lowRating;
      } else {
        determinedStatus = RateDriverStatus.highRating;
      }
    }

    emit(state.copyWith(
      status: determinedStatus,
      driver: driver,
      trip: trip,
      selectedStars: stars,
      selectedTags: tags,
      comment: comment,
      isSubmitting: false,
      navigateToHome: false,
      navigateToReceipt: false,
      showReportIssueSheet: false,
    ));
  }

  void _onStarsSelected(
    RateDriverStarsSelected event,
    Emitter<RateDriverState> emit,
  ) {
    if (state.isAlreadyRated || state.isWindowExpired || state.isSubmitting) {
      return;
    }

    final newStars = event.stars.clamp(1, 5);
    final isLow = newStars <= 2;
    final newStatus = isLow ? RateDriverStatus.lowRating : RateDriverStatus.highRating;

    // Filter tags that match new polarity
    final validTags = state.selectedTags.where((t) => t.isNegative == isLow).toList();

    emit(state.copyWith(
      selectedStars: newStars,
      status: newStatus,
      selectedTags: validTags,
    ));
  }

  void _onTagToggled(
    RateDriverTagToggled event,
    Emitter<RateDriverState> emit,
  ) {
    if (state.isAlreadyRated || state.isWindowExpired || state.isSubmitting) {
      return;
    }

    final currentTags = List<RatingTag>.from(state.selectedTags);
    if (currentTags.contains(event.tag)) {
      currentTags.remove(event.tag);
    } else {
      currentTags.add(event.tag);
    }

    emit(state.copyWith(selectedTags: currentTags));
  }

  void _onCommentChanged(
    RateDriverCommentChanged event,
    Emitter<RateDriverState> emit,
  ) {
    emit(state.copyWith(comment: event.comment));
  }

  Future<void> _onReviewSubmitted(
    RateDriverReviewSubmitted event,
    Emitter<RateDriverState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(
      status: RateDriverStatus.submitting,
      isSubmitting: true,
      errorMessage: null,
    ));

    try {
      await repository.submitReview(
        tripId: state.trip.tripId,
        rating: state.selectedStars,
        tagIds: state.selectedTags.map((t) => t.id).toList(),
        comment: state.comment,
      );

      emit(state.copyWith(
        status: RateDriverStatus.success,
        isSubmitting: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.selectedStars <= 2
            ? RateDriverStatus.lowRating
            : RateDriverStatus.highRating,
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSkipTapped(
    RateDriverSkipTapped event,
    Emitter<RateDriverState> emit,
  ) {
    emit(state.copyWith(navigateToHome: true));
  }

  void _onBackToHomeTapped(
    RateDriverBackToHomeTapped event,
    Emitter<RateDriverState> emit,
  ) {
    emit(state.copyWith(navigateToHome: true));
  }

  void _onBackToReceiptTapped(
    RateDriverBackToReceiptTapped event,
    Emitter<RateDriverState> emit,
  ) {
    emit(state.copyWith(navigateToReceipt: true));
  }

  void _onReportIssueTapped(
    RateDriverReportIssueTapped event,
    Emitter<RateDriverState> emit,
  ) {
    emit(state.copyWith(showReportIssueSheet: true));
  }
}
