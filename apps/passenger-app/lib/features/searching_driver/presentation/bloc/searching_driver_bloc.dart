import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/driver_search_models.dart';
import '../../data/repositories/searching_driver_repository.dart';
import 'searching_driver_event.dart';
import 'searching_driver_state.dart';

class SearchingDriverBloc
    extends Bloc<SearchingDriverEvent, SearchingDriverState> {
  final SearchingDriverRepository repository;
  StreamSubscription<SearchingDriverStatus>? _statusSubscription;
  Timer? _countdownTimer;

  SearchingDriverBloc({SearchingDriverRepository? repository})
      : repository = repository ?? MockSearchingDriverRepository(),
        super(const SearchingDriverState()) {
    on<SearchingDriverStarted>(_onStarted);
    on<SearchingDriverDriverFoundSimulated>(_onDriverFound);
    on<SearchingDriverCountdownTicked>(_onCountdownTicked);
    on<SearchingDriverCancelRequested>(_onCancelRequested);
    on<SearchingDriverCancelConfirmed>(_onCancelConfirmed);
    on<SearchingDriverCancelDismissed>(_onCancelDismissed);
    on<SearchingDriverConnectionChanged>(_onConnectionChanged);
    on<SearchingDriverCopyTrackingIdTapped>(_onCopyTrackingIdTapped);
    on<SearchingDriverScheduleStatusSet>(_onScheduleStatusSet);
    on<SearchingDriverRecenterTapped>(_onRecenterTapped);
    on<SearchingDriverSafetyTapped>(_onSafetyTapped);
    on<SearchingDriverCallDispatchTapped>(_onCallDispatchTapped);
  }

  Future<void> _onStarted(
    SearchingDriverStarted event,
    Emitter<SearchingDriverState> emit,
  ) async {
    final booking = event.booking ?? state.booking;
    final initialStatus = booking.isScheduled
        ? SearchingDriverStatus.scheduled
        : SearchingDriverStatus.searching;

    emit(state.copyWith(
      booking: booking,
      status: initialStatus,
      isOnline: true,
      errorMessage: null,
      navigateToTracking: false,
      navigateToHome: false,
    ));

    await _statusSubscription?.cancel();
    _statusSubscription = repository.watchStatus(booking.trackingId).listen(
      (status) {
        if (status == SearchingDriverStatus.driverFound) {
          add(const SearchingDriverDriverFoundSimulated());
        } else if (status == SearchingDriverStatus.cancelled) {
          emit(state.copyWith(
            status: SearchingDriverStatus.cancelled,
            navigateToHome: true,
          ));
        }
      },
      onError: (dynamic error) {
        emit(state.copyWith(
          errorMessage: error.toString(),
        ));
      },
    );
  }

  void _onDriverFound(
    SearchingDriverDriverFoundSimulated event,
    Emitter<SearchingDriverState> emit,
  ) {
    _countdownTimer?.cancel();
    final driver = event.driver ?? MatchedDriverInfo.sample;
    final updatedBooking = state.booking.copyWith(pickupConfirmed: true);

    emit(state.copyWith(
      status: SearchingDriverStatus.driverFound,
      driver: driver,
      booking: updatedBooking,
      connectingSecondsRemaining: 2,
    ));

    int currentSeconds = 2;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentSeconds--;
      if (currentSeconds >= 0) {
        add(SearchingDriverCountdownTicked(currentSeconds));
      } else {
        timer.cancel();
      }
    });
  }

  void _onCountdownTicked(
    SearchingDriverCountdownTicked event,
    Emitter<SearchingDriverState> emit,
  ) {
    if (event.secondsRemaining <= 0) {
      emit(state.copyWith(
        connectingSecondsRemaining: 0,
        navigateToTracking: true,
      ));
    } else {
      emit(state.copyWith(
        connectingSecondsRemaining: event.secondsRemaining,
      ));
    }
  }

  void _onCancelRequested(
    SearchingDriverCancelRequested event,
    Emitter<SearchingDriverState> emit,
  ) {
    emit(state.copyWith(showCancelDialog: true));
  }

  void _onCancelDismissed(
    SearchingDriverCancelDismissed event,
    Emitter<SearchingDriverState> emit,
  ) {
    emit(state.copyWith(showCancelDialog: false));
  }

  Future<void> _onCancelConfirmed(
    SearchingDriverCancelConfirmed event,
    Emitter<SearchingDriverState> emit,
  ) async {
    _countdownTimer?.cancel();
    emit(state.copyWith(
      showCancelDialog: false,
      isSubmittingCancel: true,
      status: SearchingDriverStatus.cancelling,
    ));

    try {
      await repository.cancelBooking(state.booking.trackingId);
      emit(state.copyWith(
        isSubmittingCancel: false,
        status: SearchingDriverStatus.cancelled,
        navigateToHome: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmittingCancel: false,
        status: SearchingDriverStatus.searching,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onConnectionChanged(
    SearchingDriverConnectionChanged event,
    Emitter<SearchingDriverState> emit,
  ) {
    final nextStatus = event.isOnline
        ? (state.booking.isScheduled
            ? SearchingDriverStatus.scheduled
            : SearchingDriverStatus.searching)
        : SearchingDriverStatus.reconnecting;

    emit(state.copyWith(
      isOnline: event.isOnline,
      signalStrength: event.signalStrength,
      status: nextStatus,
    ));
  }

  void _onCopyTrackingIdTapped(
    SearchingDriverCopyTrackingIdTapped event,
    Emitter<SearchingDriverState> emit,
  ) {
    emit(state.copyWith(isCopiedToClipboard: true));
  }

  void _onScheduleStatusSet(
    SearchingDriverScheduleStatusSet event,
    Emitter<SearchingDriverState> emit,
  ) {
    final updated = state.booking.copyWith(
      isScheduled: event.isScheduled,
      scheduledDateTime: event.scheduledDateTime ?? 'Fri, 3:30 PM',
      scheduledDayText: 'Confirmed for Friday afternoon',
      scheduledDispatchNotice: 'Driver dispatch begins 15 mins prior (3:15 PM)',
    );
    emit(state.copyWith(
      booking: updated,
      status: event.isScheduled
          ? SearchingDriverStatus.scheduled
          : SearchingDriverStatus.searching,
    ));
  }

  void _onRecenterTapped(
    SearchingDriverRecenterTapped event,
    Emitter<SearchingDriverState> emit,
  ) {
    // UI responds to recenter
  }

  void _onSafetyTapped(
    SearchingDriverSafetyTapped event,
    Emitter<SearchingDriverState> emit,
  ) {
    // UI shows safety toolkit
  }

  void _onCallDispatchTapped(
    SearchingDriverCallDispatchTapped event,
    Emitter<SearchingDriverState> emit,
  ) {
    // UI triggers phone dialer
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }
}
