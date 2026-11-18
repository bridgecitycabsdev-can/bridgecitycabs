import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/no_driver_models.dart';
import '../../data/repositories/no_driver_repository.dart';
import 'no_driver_event.dart';
import 'no_driver_state.dart';

class NoDriverBloc extends Bloc<NoDriverEvent, NoDriverState> {
  final NoDriverRepository repository;

  NoDriverBloc({NoDriverRepository? repository})
      : repository = repository ?? MockNoDriverRepository(),
        super(const NoDriverState()) {
    on<NoDriverStarted>(_onStarted);
    on<NoDriverRetryTapped>(_onRetryTapped);
    on<NoDriverCancelTapped>(_onCancelTapped);
    on<NoDriverCancelConfirmed>(_onCancelConfirmed);
    on<NoDriverCopyTrackingIdTapped>(_onCopyTrackingIdTapped);
    on<NoDriverBookDifferentVehicleTapped>(_onBookDifferentVehicleTapped);
    on<NoDriverBackTapped>(_onBackTapped);
    on<NoDriverRecenterTapped>(_onRecenterTapped);
    on<NoDriverCallDispatchTapped>(_onCallDispatchTapped);
    on<NoDriverAutoReconnectToggled>(_onAutoReconnectToggled);
  }

  void _onStarted(
    NoDriverStarted event,
    Emitter<NoDriverState> emit,
  ) {
    emit(state.copyWith(
      booking: event.booking ?? state.booking,
      status: NoDriverStatus.idle,
      retryCount: 0,
      isAutoReconnecting: false,
      isCopiedToClipboard: false,
      navigateToHome: false,
      navigateToOptions: false,
      navigateToTracking: false,
    ));
  }

  Future<void> _onRetryTapped(
    NoDriverRetryTapped event,
    Emitter<NoDriverState> emit,
  ) async {
    emit(state.copyWith(
      status: NoDriverStatus.retrySearching,
      isAutoReconnecting: true,
    ));

    try {
      final found = await repository.retrySearch(
        trackingId: state.booking.trackingId,
      );

      if (found) {
        emit(state.copyWith(
          isAutoReconnecting: false,
          navigateToTracking: true,
        ));
      } else {
        emit(state.copyWith(
          status: NoDriverStatus.stillNoDriver,
          retryCount: state.retryCount + 1,
          isAutoReconnecting: false,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        status: NoDriverStatus.stillNoDriver,
        retryCount: state.retryCount + 1,
        isAutoReconnecting: false,
      ));
    }
  }

  Future<void> _onCancelTapped(
    NoDriverCancelTapped event,
    Emitter<NoDriverState> emit,
  ) async {
    add(const NoDriverCancelConfirmed());
  }

  Future<void> _onCancelConfirmed(
    NoDriverCancelConfirmed event,
    Emitter<NoDriverState> emit,
  ) async {
    emit(state.copyWith(status: NoDriverStatus.cancelling));

    try {
      await repository.cancelRide(trackingId: state.booking.trackingId);
      emit(state.copyWith(
        status: NoDriverStatus.cancelled,
        navigateToHome: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: NoDriverStatus.cancelled,
        navigateToHome: true,
      ));
    }
  }

  void _onCopyTrackingIdTapped(
    NoDriverCopyTrackingIdTapped event,
    Emitter<NoDriverState> emit,
  ) {
    emit(state.copyWith(isCopiedToClipboard: true));
  }

  void _onBookDifferentVehicleTapped(
    NoDriverBookDifferentVehicleTapped event,
    Emitter<NoDriverState> emit,
  ) {
    emit(state.copyWith(navigateToOptions: true));
  }

  void _onBackTapped(
    NoDriverBackTapped event,
    Emitter<NoDriverState> emit,
  ) {
    emit(state.copyWith(navigateToHome: true));
  }

  void _onRecenterTapped(
    NoDriverRecenterTapped event,
    Emitter<NoDriverState> emit,
  ) {}

  void _onCallDispatchTapped(
    NoDriverCallDispatchTapped event,
    Emitter<NoDriverState> emit,
  ) {}

  void _onAutoReconnectToggled(
    NoDriverAutoReconnectToggled event,
    Emitter<NoDriverState> emit,
  ) {
    emit(state.copyWith(isAutoReconnecting: event.isAutoReconnecting));
  }
}
