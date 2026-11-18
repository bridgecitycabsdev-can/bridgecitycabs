import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/past_trip_detail_model.dart';
import '../../data/repositories/past_trip_detail_repository.dart';
import 'past_trip_detail_event.dart';
import 'past_trip_detail_state.dart';

class PastTripDetailBloc
    extends Bloc<PastTripDetailEvent, PastTripDetailState> {
  final PastTripDetailRepository repository;

  PastTripDetailBloc({required this.repository})
      : super(const PastTripDetailState()) {
    on<PastTripDetailStarted>(_onStarted);
    on<PastTripDetailSegmentChanged>(_onSegmentChanged);
    on<PastTripDetailQaScenarioSelected>(_onQaScenarioSelected);
    on<PastTripDetailCopyTripIdTapped>(_onCopyTripIdTapped);
    on<PastTripDetailDownloadReceiptTapped>(_onDownloadReceiptTapped);
    on<PastTripDetailBookReturnTapped>(_onBookReturnTapped);
    on<PastTripDetailToggleViewMode>(_onToggleViewMode);
  }

  Future<void> _onStarted(
    PastTripDetailStarted event,
    Emitter<PastTripDetailState> emit,
  ) async {
    emit(state.copyWith(status: PastTripDetailStatus.loading));

    final tripId = event.tripId ?? 'BC-123456';
    final trip = await repository.getTripDetail(tripId);

    final bool isHarpreet = tripId.contains('BCC-84920');

    emit(state.copyWith(
      status: PastTripDetailStatus.loaded,
      trip: trip,
      isInspectorMode: isHarpreet,
      selectedSegment: event.initialSegment ?? TripDetailSegment.completedCard,
      selectedQaScenario:
          event.initialScenario ?? PastTripQaScenario.completedCard,
    ));
  }

  Future<void> _onSegmentChanged(
    PastTripDetailSegmentChanged event,
    Emitter<PastTripDetailState> emit,
  ) async {
    PastTripQaScenario targetScenario;
    switch (event.segment) {
      case TripDetailSegment.completedCard:
        targetScenario = PastTripQaScenario.completedCard;
        break;
      case TripDetailSegment.completedCash:
        targetScenario = PastTripQaScenario.completedCash;
        break;
      case TripDetailSegment.inProgress:
        targetScenario = PastTripQaScenario.inProgress;
        break;
    }

    final updatedTrip = await repository.getTripForScenario(targetScenario);
    emit(state.copyWith(
      selectedSegment: event.segment,
      selectedQaScenario: targetScenario,
      trip: updatedTrip,
      feedbackMessage: () => 'Switched to ${event.segment.label}',
    ));
  }

  Future<void> _onQaScenarioSelected(
    PastTripDetailQaScenarioSelected event,
    Emitter<PastTripDetailState> emit,
  ) async {
    final updatedTrip = await repository.getTripForScenario(event.scenario);
    emit(state.copyWith(
      selectedQaScenario: event.scenario,
      trip: updatedTrip,
      feedbackMessage: () => 'Scenario updated: ${event.scenario.chipLabel}',
    ));
  }

  void _onCopyTripIdTapped(
    PastTripDetailCopyTripIdTapped event,
    Emitter<PastTripDetailState> emit,
  ) {
    emit(state.copyWith(
      isCopied: true,
      feedbackMessage: () => 'Trip ID ${event.tripId} copied to clipboard',
    ));
  }

  Future<void> _onDownloadReceiptTapped(
    PastTripDetailDownloadReceiptTapped event,
    Emitter<PastTripDetailState> emit,
  ) async {
    emit(state.copyWith(isDownloadingPdf: true));
    final filename = await repository.downloadOfficialTaxReceipt(event.tripId);
    emit(state.copyWith(
      isDownloadingPdf: false,
      feedbackMessage: () => 'Downloaded $filename',
    ));
  }

  Future<void> _onBookReturnTapped(
    PastTripDetailBookReturnTapped event,
    Emitter<PastTripDetailState> emit,
  ) async {
    emit(state.copyWith(isBookingReturn: true));
    await repository.bookReturnTrip(event.trip);
    emit(state.copyWith(
      isBookingReturn: false,
      feedbackMessage: () =>
          'Return ride booked: ${event.trip.dropoffAddress} ➔ ${event.trip.pickupAddress}',
    ));
  }

  void _onToggleViewMode(
    PastTripDetailToggleViewMode event,
    Emitter<PastTripDetailState> emit,
  ) {
    emit(state.copyWith(
      isInspectorMode: !state.isInspectorMode,
      feedbackMessage: () => state.isInspectorMode
          ? 'Switched to Metered Detail Mode'
          : 'Switched to QA Scenario Inspector Mode',
    ));
  }
}
