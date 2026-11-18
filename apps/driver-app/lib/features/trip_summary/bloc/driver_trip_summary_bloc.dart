import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_trip_summary_config.dart';
import '../data/models/driver_trip_summary_model.dart';
import '../data/models/driver_trip_summary_status.dart';
import '../data/repositories/driver_trip_summary_repository.dart';
import 'driver_trip_summary_event.dart';
import 'driver_trip_summary_state.dart';

class DriverTripSummaryBloc
    extends Bloc<DriverTripSummaryEvent, DriverTripSummaryState> {
  final DriverTripSummaryRepository repository;

  DriverTripSummaryBloc({
    required this.repository,
    DriverTripSummaryStatus? initialStatus,
  }) : super(DriverTripSummaryState.initial(initialStatus: initialStatus)) {
    on<DriverTripSummaryStarted>(_onStarted);
    on<DriverTripSummaryCashCollectedPressed>(_onCashCollected);
    on<DriverTripSummaryRatingChanged>(_onRatingChanged);
    on<DriverTripSummaryTagToggled>(_onTagToggled);
    on<DriverTripSummaryFeedbackNotesChanged>(_onFeedbackNotesChanged);
    on<DriverTripSummaryRatingSubmitted>(_onRatingSubmitted);
    on<DriverTripSummaryRatingSkipped>(_onRatingSkipped);
    on<DriverTripSummaryEdgeStateSelected>(_onEdgeStateSelected);
    on<DriverTripSummaryRetryPaymentPressed>(_onRetryPayment);
    on<DriverTripSummaryDoneReturnPressed>(_onDoneReturn);
    on<DriverTripSummaryStateForced>(_onStateForced);
  }

  Future<void> _onStarted(
    DriverTripSummaryStarted event,
    Emitter<DriverTripSummaryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final summary = await repository.fetchSummary(
        tripId: event.tripId,
        paymentMethod: event.paymentMethod,
      );
      emit(state.copyWith(
        isLoading: false,
        summary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load trip summary: $e',
      ));
    }
  }

  Future<void> _onCashCollected(
    DriverTripSummaryCashCollectedPressed event,
    Emitter<DriverTripSummaryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.collectCash(
        tripId: state.summary.tripId,
        amount: state.summary.grossMeteredFare,
      );
      emit(state.copyWith(
        isLoading: false,
        summary: state.summary.copyWith(
          isCashCollected: true,
          isPaid: true,
        ),
        toastMessage: 'Payment confirmed: \$18.78 credited to shift balance',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to record cash payment: $e',
      ));
    }
  }

  void _onRatingChanged(
    DriverTripSummaryRatingChanged event,
    Emitter<DriverTripSummaryState> emit,
  ) {
    emit(state.copyWith(
      summary: state.summary.copyWith(
        ratingModel: state.summary.ratingModel.copyWith(rating: event.rating),
      ),
    ));
  }

  void _onTagToggled(
    DriverTripSummaryTagToggled event,
    Emitter<DriverTripSummaryState> emit,
  ) {
    final currentTags = List<String>.from(state.summary.ratingModel.selectedTags);
    if (currentTags.contains(event.tag)) {
      currentTags.remove(event.tag);
    } else {
      currentTags.add(event.tag);
    }
    emit(state.copyWith(
      summary: state.summary.copyWith(
        ratingModel: state.summary.ratingModel.copyWith(selectedTags: currentTags),
      ),
    ));
  }

  void _onFeedbackNotesChanged(
    DriverTripSummaryFeedbackNotesChanged event,
    Emitter<DriverTripSummaryState> emit,
  ) {
    emit(state.copyWith(
      summary: state.summary.copyWith(
        ratingModel: state.summary.ratingModel.copyWith(
          dispatcherFeedbackNotes: event.notes,
        ),
      ),
    ));
  }

  Future<void> _onRatingSubmitted(
    DriverTripSummaryRatingSubmitted event,
    Emitter<DriverTripSummaryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.submitPassengerRating(
        tripId: state.summary.tripId,
        rating: state.summary.ratingModel,
      );
      emit(state.copyWith(
        isLoading: false,
        status: DriverTripSummaryStatus.cardSettled,
        summary: state.summary.copyWith(
          ratingModel: state.summary.ratingModel.copyWith(isSubmitted: true),
        ),
        toastMessage: 'Rating submitted to Lethbridge fleet log.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to submit rating: $e',
      ));
    }
  }

  void _onRatingSkipped(
    DriverTripSummaryRatingSkipped event,
    Emitter<DriverTripSummaryState> emit,
  ) {
    emit(state.copyWith(
      status: DriverTripSummaryStatus.cardSettled,
    ));
  }

  void _onEdgeStateSelected(
    DriverTripSummaryEdgeStateSelected event,
    Emitter<DriverTripSummaryState> emit,
  ) {
    emit(state.copyWith(
      summary: state.summary.copyWith(activeEdgeState: event.edgeType),
    ));
  }

  Future<void> _onRetryPayment(
    DriverTripSummaryRetryPaymentPressed event,
    Emitter<DriverTripSummaryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.retryPaymentSync(tripId: state.summary.tripId);
      emit(state.copyWith(
        isLoading: false,
        toastMessage: 'Re-syncing with terminal batch #84...',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Retry failed: $e',
      ));
    }
  }

  void _onDoneReturn(
    DriverTripSummaryDoneReturnPressed event,
    Emitter<DriverTripSummaryState> emit,
  ) {
    emit(state.copyWith(
      isReturnedToDispatch: true,
      toastMessage: 'Returning to Lethbridge Fleet Dispatch',
    ));
  }

  void _onStateForced(
    DriverTripSummaryStateForced event,
    Emitter<DriverTripSummaryState> emit,
  ) {
    DriverTripSummaryModel model;
    switch (event.status) {
      case DriverTripSummaryStatus.cardSettled:
        model = DriverTripSummaryConfig.cardSummaryPreset;
        break;
      case DriverTripSummaryStatus.cashDue:
        model = DriverTripSummaryConfig.cashSummaryPreset;
        break;
      case DriverTripSummaryStatus.ratePassenger:
        model = DriverTripSummaryConfig.ratePassengerPreset;
        break;
      case DriverTripSummaryStatus.edgeStatesGallery:
        model = DriverTripSummaryConfig.edgeStatesGalleryPreset;
        break;
      case DriverTripSummaryStatus.returnedToDispatch:
        model = DriverTripSummaryConfig.cardSummaryPreset;
        break;
    }

    emit(state.copyWith(
      status: event.status,
      summary: model,
      clearError: true,
      clearToast: true,
      isReturnedToDispatch:
          event.status == DriverTripSummaryStatus.returnedToDispatch,
    ));
  }
}
