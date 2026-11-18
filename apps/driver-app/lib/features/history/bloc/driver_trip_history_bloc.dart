import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_trip_filter_period.dart';
import '../data/models/driver_trip_history_config.dart';
import '../data/models/driver_trip_history_status.dart';
import '../data/repositories/driver_trip_history_repository.dart';
import 'driver_trip_history_event.dart';
import 'driver_trip_history_state.dart';

class DriverTripHistoryBloc
    extends Bloc<DriverTripHistoryEvent, DriverTripHistoryState> {
  final DriverTripHistoryRepository repository;

  DriverTripHistoryBloc({required this.repository})
      : super(DriverTripHistoryState.initial()) {
    on<DriverTripHistoryStarted>(_onStarted);
    on<DriverTripHistoryFilterRequested>(_onFilterRequested);
    on<DriverTripHistoryFilterDismissed>(_onFilterDismissed);
    on<DriverTripHistoryPeriodSelected>(_onPeriodSelected);
    on<DriverTripHistoryCustomRangeConfigured>(_onCustomRangeConfigured);
    on<DriverTripHistoryFilterApplied>(_onFilterApplied);
    on<DriverTripHistoryTripSelected>(_onTripSelected);
    on<DriverTripHistoryBackToGalleryPressed>(_onBackToGalleryPressed);
    on<DriverTripHistorySyncRetryPressed>(_onSyncRetryPressed);
    on<DriverTripHistoryGoOnlinePressed>(_onGoOnlinePressed);
    on<DriverTripHistoryIssueReported>(_onIssueReported);
    on<DriverTripHistoryStateForced>(_onStateForced);
  }

  void _onStarted(
    DriverTripHistoryStarted event,
    Emitter<DriverTripHistoryState> emit,
  ) {
    add(DriverTripHistoryStateForced(event.initialStatus));
  }

  void _onFilterRequested(
    DriverTripHistoryFilterRequested event,
    Emitter<DriverTripHistoryState> emit,
  ) {
    emit(state.copyWith(status: DriverTripHistoryStatus.filterSheet));
  }

  void _onFilterDismissed(
    DriverTripHistoryFilterDismissed event,
    Emitter<DriverTripHistoryState> emit,
  ) {
    emit(state.copyWith(status: DriverTripHistoryStatus.gallery));
  }

  void _onPeriodSelected(
    DriverTripHistoryPeriodSelected event,
    Emitter<DriverTripHistoryState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPeriod: event.period,
        isCustomRangeExpanded:
            event.period == DriverTripFilterPeriod.customRange,
      ),
    );
  }

  void _onCustomRangeConfigured(
    DriverTripHistoryCustomRangeConfigured event,
    Emitter<DriverTripHistoryState> emit,
  ) {
    emit(
      state.copyWith(
        customStartDate: event.startDate,
        customEndDate: event.endDate,
      ),
    );
  }

  Future<void> _onFilterApplied(
    DriverTripHistoryFilterApplied event,
    Emitter<DriverTripHistoryState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      final fetchedTrips = await repository.fetchTrips(
        period: state.selectedPeriod,
        startDate: state.customStartDate,
        endDate: state.customEndDate,
      );

      emit(
        state.copyWith(
          status: DriverTripHistoryStatus.gallery,
          isActionLoading: false,
          trips: fetchedTrips,
          hasFilteredEmptyNotice: fetchedTrips.isEmpty,
          feedbackMessage:
              'Applied filter: ${state.selectedPeriod.label} (${fetchedTrips.length} trips found)',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DriverTripHistoryStatus.gallery,
          isActionLoading: false,
          feedbackMessage: 'Failed to apply filter: $e',
        ),
      );
    }
  }

  Future<void> _onTripSelected(
    DriverTripHistoryTripSelected event,
    Emitter<DriverTripHistoryState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      final tripDetail = await repository.fetchTripDetail(event.tripId);
      emit(
        state.copyWith(
          isActionLoading: false,
          status: DriverTripHistoryStatus.tripDetail,
          selectedTrip: tripDetail,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Failed to load trip: $e',
        ),
      );
    }
  }

  void _onBackToGalleryPressed(
    DriverTripHistoryBackToGalleryPressed event,
    Emitter<DriverTripHistoryState> emit,
  ) {
    emit(state.copyWith(status: DriverTripHistoryStatus.gallery));
  }

  Future<void> _onSyncRetryPressed(
    DriverTripHistorySyncRetryPressed event,
    Emitter<DriverTripHistoryState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.retryOfflineSync();
      emit(
        state.copyWith(
          isActionLoading: false,
          isOfflineWarningVisible: false,
          isSyncingRecent: false,
          feedbackMessage:
              'Local trips synced successfully with Bridge City dispatch.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Sync retry failed: $e',
        ),
      );
    }
  }

  void _onGoOnlinePressed(
    DriverTripHistoryGoOnlinePressed event,
    Emitter<DriverTripHistoryState> emit,
  ) {
    emit(
      state.copyWith(
        shouldNavigateToDispatch: true,
        feedbackMessage: 'Going online on Lethbridge dispatch network...',
      ),
    );
  }

  Future<void> _onIssueReported(
    DriverTripHistoryIssueReported event,
    Emitter<DriverTripHistoryState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.reportTripIssue(
        event.tripId,
        'Driver flag reported from archived manifest',
      );
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage:
              'Trip issue report for ${event.tripId} submitted to fleet dispatch.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Failed to submit report: $e',
        ),
      );
    }
  }

  void _onStateForced(
    DriverTripHistoryStateForced event,
    Emitter<DriverTripHistoryState> emit,
  ) {
    switch (event.status) {
      case DriverTripHistoryStatus.gallery:
        emit(
          state.copyWith(
            status: DriverTripHistoryStatus.gallery,
            isOnline: true,
            isOfflineWarningVisible: true,
            isZeroActiveDispatches: true,
            hasFilteredEmptyNotice: true,
            trips: [DriverTripHistoryConfig.sampleCancelledTrip()],
            selectedTrip: DriverTripHistoryConfig.sampleCompletedTrip(),
            isSyncingRecent: true,
            isActionLoading: false,
          ),
        );
        break;
      case DriverTripHistoryStatus.tripDetail:
        emit(
          state.copyWith(
            status: DriverTripHistoryStatus.tripDetail,
            selectedTrip: DriverTripHistoryConfig.sampleCompletedTrip(),
            isActionLoading: false,
          ),
        );
        break;
      case DriverTripHistoryStatus.filterSheet:
        emit(
          state.copyWith(
            status: DriverTripHistoryStatus.filterSheet,
            selectedPeriod: DriverTripFilterPeriod.thisWeek,
            customStartDate: '10 Jun 2024',
            customEndDate: '24 Jun 2024',
            isCustomRangeExpanded: true,
            isActionLoading: false,
          ),
        );
        break;
      case DriverTripHistoryStatus.emptyNoRides:
        emit(
          state.copyWith(
            status: DriverTripHistoryStatus.emptyNoRides,
            isZeroActiveDispatches: true,
            hasFilteredEmptyNotice: false,
            trips: [],
            isSyncingRecent: false,
            isActionLoading: false,
          ),
        );
        break;
    }
  }
}
