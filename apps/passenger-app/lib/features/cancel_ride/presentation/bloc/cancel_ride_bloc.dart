import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cancel_ride_models.dart';
import '../../data/repositories/cancel_ride_repository.dart';
import 'cancel_ride_event.dart';
import 'cancel_ride_state.dart';

class CancelRideBloc extends Bloc<CancelRideEvent, CancelRideState> {
  final CancelRideRepository repository;

  CancelRideBloc({CancelRideRepository? repository})
      : repository = repository ?? MockCancelRideRepository(),
        super(const CancelRideState()) {
    on<CancelRideStarted>(_onStarted);
    on<CancelRideReasonSelected>(_onReasonSelected);
    on<CancelRideCustomReasonChanged>(_onCustomReasonChanged);
    on<CancelRideConfirmed>(_onConfirmed);
    on<CancelRideDismissed>(_onDismissed);
    on<CancelRideBackToTripTapped>(_onBackToTripTapped);
    on<CancelRideEmergencyCallTapped>(_onEmergencyCallTapped);
    on<CancelRideSuccessBannerDismissed>(_onSuccessBannerDismissed);
  }

  void _onStarted(
    CancelRideStarted event,
    Emitter<CancelRideState> emit,
  ) {
    final details = event.details ?? state.details;
    final isTripStarted = event.isTripStarted ?? details.isTripStarted;

    emit(state.copyWith(
      details: details.copyWith(isTripStarted: isTripStarted),
      status: isTripStarted
          ? CancelRideStatus.cannotCancel
          : CancelRideStatus.confirm,
      isSubmitting: false,
      navigateBack: false,
      navigateToHome: false,
      navigateToTrip: false,
    ));
  }

  void _onReasonSelected(
    CancelRideReasonSelected event,
    Emitter<CancelRideState> emit,
  ) {
    emit(state.copyWith(
      details: state.details.copyWith(selectedReason: event.reason),
    ));
  }

  void _onCustomReasonChanged(
    CancelRideCustomReasonChanged event,
    Emitter<CancelRideState> emit,
  ) {
    emit(state.copyWith(
      details: state.details.copyWith(customReason: event.customReason),
    ));
  }

  Future<void> _onConfirmed(
    CancelRideConfirmed event,
    Emitter<CancelRideState> emit,
  ) async {
    final canCancel =
        await repository.checkCanCancel(bookingId: state.details.bookingId);

    if (!canCancel) {
      emit(state.copyWith(
        status: CancelRideStatus.cannotCancel,
        details: state.details.copyWith(isTripStarted: true),
      ));
      return;
    }

    emit(state.copyWith(
      status: CancelRideStatus.cancelling,
      isSubmitting: true,
    ));

    final reasonToSubmit = state.details.customReason?.isNotEmpty == true
        ? state.details.customReason!
        : state.details.selectedReason;

    await repository.submitCancellation(
      bookingId: state.details.bookingId,
      reason: reasonToSubmit,
    );

    emit(state.copyWith(
      status: CancelRideStatus.cancelledSuccess,
      isSubmitting: false,
      showSuccessBanner: true,
      navigateToHome: true,
    ));
  }

  void _onDismissed(
    CancelRideDismissed event,
    Emitter<CancelRideState> emit,
  ) {
    emit(state.copyWith(navigateBack: true));
  }

  void _onBackToTripTapped(
    CancelRideBackToTripTapped event,
    Emitter<CancelRideState> emit,
  ) {
    emit(state.copyWith(navigateToTrip: true));
  }

  void _onEmergencyCallTapped(
    CancelRideEmergencyCallTapped event,
    Emitter<CancelRideState> emit,
  ) {}

  void _onSuccessBannerDismissed(
    CancelRideSuccessBannerDismissed event,
    Emitter<CancelRideState> emit,
  ) {
    emit(state.copyWith(showSuccessBanner: false));
  }
}
