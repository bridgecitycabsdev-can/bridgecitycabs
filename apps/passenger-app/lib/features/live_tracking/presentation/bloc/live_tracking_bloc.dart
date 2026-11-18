import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories/live_tracking_repository.dart';
import 'live_tracking_event.dart';
import 'live_tracking_state.dart';

class LiveTrackingBloc extends Bloc<LiveTrackingEvent, LiveTrackingState> {
  final LiveTrackingRepository repository;
  StreamSubscription<LiveTrackingStatus>? _statusSubscription;

  LiveTrackingBloc({LiveTrackingRepository? repository})
      : repository = repository ?? MockLiveTrackingRepository(),
        super(const LiveTrackingState()) {
    on<LiveTrackingStarted>(_onStarted);
    on<LiveTrackingStatusChanged>(_onStatusChanged);
    on<LiveTrackingProgressUpdated>(_onProgressUpdated);
    on<LiveTrackingTelemetrySyncToggled>(_onTelemetrySyncToggled);
    on<LiveTrackingSosTriggered>(_onSosTriggered);
    on<LiveTrackingSosCancelled>(_onSosCancelled);
    on<LiveTrackingCancelRideTapped>(_onCancelRideTapped);
    on<LiveTrackingCancelConfirmed>(_onCancelConfirmed);
    on<LiveTrackingCancelDismissed>(_onCancelDismissed);
    on<LiveTrackingCopyTrackingIdTapped>(_onCopyTrackingIdTapped);
    on<LiveTrackingSafetyTapped>(_onSafetyTapped);
    on<LiveTrackingCall911Tapped>(_onCall911Tapped);
    on<LiveTrackingRecenterTapped>(_onRecenterTapped);
  }

  Future<void> _onStarted(
    LiveTrackingStarted event,
    Emitter<LiveTrackingState> emit,
  ) async {
    final trip = event.trip ?? state.trip;
    final driver = event.driver ?? state.driver;
    final status = event.initialStatus ?? state.status;

    emit(state.copyWith(
      trip: trip,
      driver: driver,
      status: status,
      isSosTriggered: status == LiveTrackingStatus.sosTriggered,
      isTelemetrySyncing: status == LiveTrackingStatus.telemetrySyncing,
      navigateToHome: false,
      navigateToReceipt: false,
    ));

    await _statusSubscription?.cancel();
    _statusSubscription = repository.watchTripStatus(trip.trackingId).listen(
      (newStatus) {
        add(LiveTrackingStatusChanged(newStatus));
      },
    );
  }

  void _onStatusChanged(
    LiveTrackingStatusChanged event,
    Emitter<LiveTrackingState> emit,
  ) {
    if (event.status == LiveTrackingStatus.cancelled) {
      emit(state.copyWith(
        status: LiveTrackingStatus.cancelled,
        navigateToHome: true,
      ));
    } else if (event.status == LiveTrackingStatus.tripCompleted) {
      emit(state.copyWith(
        status: LiveTrackingStatus.tripCompleted,
        navigateToReceipt: true,
      ));
    } else {
      emit(state.copyWith(
        status: event.status,
        isSosTriggered: event.status == LiveTrackingStatus.sosTriggered,
        isTelemetrySyncing: event.status == LiveTrackingStatus.telemetrySyncing,
      ));
    }
  }

  void _onProgressUpdated(
    LiveTrackingProgressUpdated event,
    Emitter<LiveTrackingState> emit,
  ) {
    final updatedTrip = state.trip.copyWith(
      tripProgress: event.progress,
      etaMinutes: event.etaMinutes,
      estimatedArrivalTime: event.estimatedArrivalTime,
    );
    emit(state.copyWith(trip: updatedTrip));
  }

  void _onTelemetrySyncToggled(
    LiveTrackingTelemetrySyncToggled event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(
      isTelemetrySyncing: event.isSyncing,
      status: event.isSyncing
          ? LiveTrackingStatus.telemetrySyncing
          : LiveTrackingStatus.tripInProgress,
    ));
  }

  Future<void> _onSosTriggered(
    LiveTrackingSosTriggered event,
    Emitter<LiveTrackingState> emit,
  ) async {
    emit(state.copyWith(
      isSosTriggered: true,
      status: LiveTrackingStatus.sosTriggered,
    ));
    await repository.triggerSosAlert(state.trip.trackingId);
  }

  Future<void> _onSosCancelled(
    LiveTrackingSosCancelled event,
    Emitter<LiveTrackingState> emit,
  ) async {
    emit(state.copyWith(
      isSosTriggered: false,
      status: LiveTrackingStatus.tripInProgress,
    ));
    await repository.cancelSosAlert(state.trip.trackingId);
  }

  void _onCancelRideTapped(
    LiveTrackingCancelRideTapped event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(showCancelDialog: true));
  }

  void _onCancelDismissed(
    LiveTrackingCancelDismissed event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(showCancelDialog: false));
  }

  Future<void> _onCancelConfirmed(
    LiveTrackingCancelConfirmed event,
    Emitter<LiveTrackingState> emit,
  ) async {
    emit(state.copyWith(showCancelDialog: false));
    await repository.cancelTrip(state.trip.trackingId);
    emit(state.copyWith(
      status: LiveTrackingStatus.cancelled,
      navigateToHome: true,
    ));
  }

  void _onCopyTrackingIdTapped(
    LiveTrackingCopyTrackingIdTapped event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(isCopiedToClipboard: true));
  }

  void _onSafetyTapped(
    LiveTrackingSafetyTapped event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(showSafetyToolkit: true));
  }

  void _onCall911Tapped(
    LiveTrackingCall911Tapped event,
    Emitter<LiveTrackingState> emit,
  ) {}

  void _onRecenterTapped(
    LiveTrackingRecenterTapped event,
    Emitter<LiveTrackingState> emit,
  ) {}

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
