import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/trip_history_config.dart';
import '../../data/models/trip_history_model.dart';
import '../../data/repositories/trip_history_repository.dart';
import 'trip_history_event.dart';
import 'trip_history_state.dart';

class TripHistoryBloc extends Bloc<TripHistoryEvent, TripHistoryState> {
  final TripHistoryRepository _repository;

  TripHistoryBloc({required TripHistoryRepository repository})
      : _repository = repository,
        super(const TripHistoryState()) {
    on<TripHistoryStarted>(_onStarted);
    on<TripHistoryScenarioChanged>(_onScenarioChanged);
    on<TripHistoryViewDetailsTapped>(_onViewDetailsTapped);
    on<TripHistoryOpenNotificationsTapped>(_onOpenNotificationsTapped);
    on<TripHistoryContactSupportTapped>(_onContactSupportTapped);
    on<TripHistoryRateDriverTapped>(_onRateDriverTapped);
    on<TripHistoryDownloadReceiptTapped>(_onDownloadReceiptTapped);
    on<TripHistoryReportProblemTapped>(_onReportProblemTapped);

    // New Handlers for Full History Hub & Date Range Filter
    on<TripHistoryFilterSelected>(_onFilterSelected);
    on<TripHistoryCustomDateRangeApplied>(_onCustomDateRangeApplied);
    on<TripHistoryCardTapped>(_onCardTapped);
    on<TripHistoryQuickActionsClosed>(_onQuickActionsClosed);
    on<TripHistoryCalendarTapped>(_onCalendarTapped);
    on<TripHistoryDateRangeFilterClosed>(_onDateRangeFilterClosed);
    on<TripHistoryRefreshTriggered>(_onRefreshTriggered);
    on<TripHistoryQaStateChanged>(_onQaStateChanged);
  }

  Future<void> _onStarted(
    TripHistoryStarted event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(status: TripHistoryStatus.loading));
    try {
      final lastTrip = await _repository.getLastTrip();
      final scenario = event.initialScenario ?? state.selectedScenario;

      TripRecord? active;
      if (event.tripId != null) {
        active = await _repository.getTripDetails(event.tripId!, scenario: scenario);
      } else if (lastTrip != null) {
        active = await _repository.getTripDetails(lastTrip.tripId, scenario: scenario);
      }

      final grouped = await _repository.getGroupedTrips(filter: state.activeFilter);
      final summary = await _repository.getTripSummary(filter: state.activeFilter);

      emit(state.copyWith(
        status: TripHistoryStatus.loaded,
        lastTrip: lastTrip,
        activeTrip: () => active,
        selectedScenario: scenario,
        groupedTrips: grouped,
        tripSummary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TripHistoryStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onScenarioChanged(
    TripHistoryScenarioChanged event,
    Emitter<TripHistoryState> emit,
  ) async {
    final currentId = state.currentTrip.tripId;
    final updated = await _repository.getTripDetails(
      currentId,
      scenario: event.scenario,
    );

    emit(state.copyWith(
      selectedScenario: event.scenario,
      activeTrip: () => updated,
      feedbackMessage: () => 'Scenario updated: ${event.scenario.label}',
    ));
  }

  Future<void> _onViewDetailsTapped(
    TripHistoryViewDetailsTapped event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(status: TripHistoryStatus.loading));
    try {
      final trip = await _repository.getTripDetails(
        event.tripId,
        scenario: state.selectedScenario,
      );
      emit(state.copyWith(
        status: TripHistoryStatus.loaded,
        activeTrip: () => trip,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TripHistoryStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onOpenNotificationsTapped(
    TripHistoryOpenNotificationsTapped event,
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening Notifications Center...',
    ));
  }

  void _onContactSupportTapped(
    TripHistoryContactSupportTapped event,
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening Support Hub...',
    ));
  }

  void _onRateDriverTapped(
    TripHistoryRateDriverTapped event,
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening driver rating for trip #${event.tripId}...',
    ));
  }

  Future<void> _onDownloadReceiptTapped(
    TripHistoryDownloadReceiptTapped event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(
      status: TripHistoryStatus.downloadingReceipt,
      isDownloadingReceipt: true,
    ));

    try {
      await _repository.downloadTaxReceipt(event.tripId);
      emit(state.copyWith(
        status: TripHistoryStatus.downloadSuccess,
        isDownloadingReceipt: false,
        feedbackMessage: () => 'Alberta CRA compliant PDF receipt downloaded to device.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TripHistoryStatus.error,
        isDownloadingReceipt: false,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onReportProblemTapped(
    TripHistoryReportProblemTapped event,
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Creating support ticket for trip #${event.tripId}...',
    ));
  }

  Future<void> _onFilterSelected(
    TripHistoryFilterSelected event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(activeFilter: event.filter, isLoadingMore: true));
    final grouped = await _repository.getGroupedTrips(filter: event.filter);
    final summary = await _repository.getTripSummary(filter: event.filter);
    emit(state.copyWith(
      activeFilter: event.filter,
      groupedTrips: grouped,
      tripSummary: summary,
      isLoadingMore: false,
    ));
  }

  Future<void> _onCustomDateRangeApplied(
    TripHistoryCustomDateRangeApplied event,
    Emitter<TripHistoryState> emit,
  ) async {
    final customRange = CustomDateRange(
      startDate: event.startDate,
      endDate: event.endDate,
    );
    emit(state.copyWith(
      activeFilter: TripHistoryFilter.custom,
      customDateRange: () => customRange,
      isDateRangeFilterOpen: false,
      isLoadingMore: true,
    ));
    final grouped = await _repository.getGroupedTrips(
      filter: TripHistoryFilter.custom,
      customRange: customRange,
    );
    final summary = await _repository.getTripSummary(
      filter: TripHistoryFilter.custom,
      customRange: customRange,
    );
    emit(state.copyWith(
      groupedTrips: grouped,
      tripSummary: summary,
      isLoadingMore: false,
      feedbackMessage: () => 'Date filter applied: ${customRange.formattedRange}',
    ));
  }

  void _onCardTapped(
    TripHistoryCardTapped event,
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      selectedTripForActions: () => event.trip,
      isQuickActionsOpen: true,
    ));
  }

  void _onQuickActionsClosed(
    TripHistoryQuickActionsClosed event,
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      selectedTripForActions: () => null,
      isQuickActionsOpen: false,
    ));
  }

  void _onCalendarTapped(
    TripHistoryCalendarTapped event,
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      isDateRangeFilterOpen: true,
    ));
  }

  void _onDateRangeFilterClosed(
    TripHistoryDateRangeFilterClosed event,
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      isDateRangeFilterOpen: false,
    ));
  }

  Future<void> _onRefreshTriggered(
    TripHistoryRefreshTriggered event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(isLoadingMore: true));
    final grouped = await _repository.getGroupedTrips(filter: state.activeFilter);
    final summary = await _repository.getTripSummary(filter: state.activeFilter);
    emit(state.copyWith(
      groupedTrips: grouped,
      tripSummary: summary,
      isLoadingMore: false,
      feedbackMessage: () => 'Trip history updated',
    ));
  }

  void _onQaStateChanged(
    TripHistoryQaStateChanged event,
    Emitter<TripHistoryState> emit,
  ) {
    final showLiveBanner = event.stateIndex == 2;
    final showCustomFilter = event.stateIndex == 5;
    emit(state.copyWith(
      qaStateIndex: event.stateIndex,
      isLiveTripActive: showLiveBanner,
      isDateRangeFilterOpen: showCustomFilter,
    ));
  }
}
