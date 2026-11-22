import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_cancel_reason.dart';
import '../data/models/driver_trip_config.dart';
import '../data/models/driver_trip_model.dart';
import '../data/models/driver_trip_status.dart';
import '../data/repositories/driver_trip_repository.dart';
import 'driver_trip_event.dart';
import 'driver_trip_state.dart';

class DriverTripBloc extends Bloc<DriverTripEvent, DriverTripState> {
  final DriverTripRepository repository;

  DriverTripBloc({
    required this.repository,
    DriverTripStatus? initialStatus,
  }) : super(DriverTripState.initial(initialStatus: initialStatus)) {
    on<DriverTripStarted>(_onStarted);
    on<DriverTripArrivedPressed>(_onArrivedPressed);
    on<DriverTripStartTripPressed>(_onStartTripPressed);
    on<DriverTripCancelRequested>(_onCancelRequested);
    on<DriverTripCancelReasonSelected>(_onCancelReasonSelected);
    on<DriverTripCancelConfirmed>(_onCancelConfirmed);
    on<DriverTripKeepTripPressed>(_onKeepTripPressed);
    on<DriverTripExternalNavigationPressed>(_onExternalNavigationPressed);
    on<DriverTripPassengerNotHerePressed>(_onPassengerNotHerePressed);
    on<DriverTripTelemetryTabSelected>(_onTelemetryTabSelected);
    on<DriverTripWaitTimerTicked>(_onWaitTimerTicked);
    on<DriverTripEndTripRequested>(_onEndTripRequested);
    on<DriverTripProximityModeToggled>(_onProximityModeToggled);
    on<DriverTripEndTripConfirmed>(_onEndTripConfirmed);
    on<DriverTripEmergencySosRequested>(_onEmergencySosRequested);
    on<DriverTripEmergencySosTriggered>(_onEmergencySosTriggered);
    on<DriverTripEmergencySosCancelled>(_onEmergencySosCancelled);
    on<DriverTripStateForced>(_onStateForced);
  }

  Future<void> _onStarted(
    DriverTripStarted event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final trip = await repository.fetchActiveTrip();
      emit(state.copyWith(
        isLoading: false,
        trip: trip,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load active trip dispatch: $e',
      ));
    }
  }

  Future<void> _onArrivedPressed(
    DriverTripArrivedPressed event,
    Emitter<DriverTripState> emit,
  ) async {
    if (state.trip.isArrivalLocked && !event.bypassProximity) {
      emit(state.copyWith(
        toastMessage:
            'Get closer to the pickup point to continue (${state.trip.distanceAwayMeters}m away)',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.markArrived(state.trip.tripId);
      final updatedTrip = DriverTripConfig.waitingForPassengerPreset.copyWith(
        tripId: state.trip.tripId,
        passenger: state.trip.passenger,
      );
      emit(state.copyWith(
        isLoading: false,
        status: DriverTripStatus.waitingForPassenger,
        trip: updatedTrip,
        toastMessage: 'Arrived at pickup point. Wait timer started.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Could not record arrival: $e',
      ));
    }
  }

  Future<void> _onStartTripPressed(
    DriverTripStartTripPressed event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.startTrip(state.trip.tripId);
      emit(state.copyWith(
        isLoading: false,
        status: DriverTripStatus.onTrip,
        trip: DriverTripConfig.activeNavigationPreset.copyWith(
          tripId: state.trip.tripId,
          passenger: state.trip.passenger,
        ),
        toastMessage: 'Trip started. En route to destination.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to start trip: $e',
      ));
    }
  }

  void _onCancelRequested(
    DriverTripCancelRequested event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      previousStatus: state.status,
      status: DriverTripStatus.cancelTripModal,
    ));
  }

  void _onCancelReasonSelected(
    DriverTripCancelReasonSelected event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      trip: state.trip.copyWith(selectedCancelReason: event.reason),
    ));
  }

  Future<void> _onCancelConfirmed(
    DriverTripCancelConfirmed event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.cancelTrip(
        tripId: state.trip.tripId,
        reason: state.trip.selectedCancelReason,
      );
      emit(state.copyWith(
        isLoading: false,
        status: DriverTripStatus.canceled,
        isCanceledAndReturning: true,
        toastMessage: 'Trip canceled',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to cancel trip: $e',
      ));
    }
  }

  void _onKeepTripPressed(
    DriverTripKeepTripPressed event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      status: state.previousStatus,
    ));
  }

  Future<void> _onExternalNavigationPressed(
    DriverTripExternalNavigationPressed event,
    Emitter<DriverTripState> emit,
  ) async {
    try {
      final targetAddress = state.status == DriverTripStatus.onTrip
          ? state.trip.dropoffAddress
          : state.trip.pickupAddress;
      await repository.launchNavigation(address: targetAddress);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Could not open navigation: $e',
      ));
    }
  }

  void _onPassengerNotHerePressed(
    DriverTripPassengerNotHerePressed event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      toastMessage: 'Passenger no-show protocol logged after 5 min wait period',
    ));
  }

  void _onTelemetryTabSelected(
    DriverTripTelemetryTabSelected event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      trip: state.trip.copyWith(telemetryActiveTab: event.tabIndex),
    ));
  }

  void _onWaitTimerTicked(
    DriverTripWaitTimerTicked event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      trip: state.trip.copyWith(
        waitTimeElapsedSeconds: event.newElapsedSeconds,
      ),
    ));
  }

  void _onEndTripRequested(
    DriverTripEndTripRequested event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      previousStatus: state.status,
      status: DriverTripStatus.endTripModal,
    ));
  }

  void _onProximityModeToggled(
    DriverTripProximityModeToggled event,
    Emitter<DriverTripState> emit,
  ) {
    final isWithin50m = event.mode == 'within50m';
    emit(state.copyWith(
      trip: state.trip.copyWith(
        dropoffProximityMode: event.mode,
        dropoffDistanceAwayKm: isWithin50m ? 0.04 : 1.2,
        computedMeterFareCad: isWithin50m ? 18.40 : 16.85,
      ),
    ));
  }

  void _onEndTripConfirmed(
    DriverTripEndTripConfirmed event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      isTripEndedAndSummarizing: true,
      toastMessage: 'Trip completed. Finalizing fare via Bylaw 6138 digital meter.',
    ));
  }

  void _onEmergencySosRequested(
    DriverTripEmergencySosRequested event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      previousStatus: state.status,
      status: DriverTripStatus.emergencySosModal,
    ));
  }

  void _onEmergencySosTriggered(
    DriverTripEmergencySosTriggered event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      toastMessage:
          'EMERGENCY ALERT BROADCAST: GPS locked. Lethbridge Police notified.',
    ));
  }

  void _onEmergencySosCancelled(
    DriverTripEmergencySosCancelled event,
    Emitter<DriverTripState> emit,
  ) {
    emit(state.copyWith(
      status: state.previousStatus,
    ));
  }

  void _onStateForced(
    DriverTripStateForced event,
    Emitter<DriverTripState> emit,
  ) {
    DriverTripModel newTrip;
    switch (event.targetStatus) {
      case DriverTripStatus.headingToPickup:
        newTrip = DriverTripConfig.headingToPickupPreset;
        break;
      case DriverTripStatus.waitingForPassenger:
        newTrip = DriverTripConfig.waitingForPassengerPreset;
        break;
      case DriverTripStatus.cancelTripModal:
        newTrip = DriverTripConfig.cancelTripModalPreset;
        break;
      case DriverTripStatus.telemetryAlert:
        newTrip = DriverTripConfig.telemetryAlertPreset;
        break;
      case DriverTripStatus.onTrip:
        newTrip = DriverTripConfig.activeNavigationPreset;
        break;
      case DriverTripStatus.endTripModal:
        newTrip = DriverTripConfig.endTripModalPreset;
        break;
      case DriverTripStatus.emergencySosModal:
        newTrip = DriverTripConfig.emergencySosModalPreset;
        break;
      case DriverTripStatus.canceled:
        newTrip = DriverTripConfig.headingToPickupPreset;
        break;
    }

    emit(state.copyWith(
      status: event.targetStatus,
      trip: newTrip,
      clearError: true,
      clearToast: true,
      isCanceledAndReturning: event.targetStatus == DriverTripStatus.canceled,
      isTripEndedAndSummarizing: false,
    ));
  }
}
