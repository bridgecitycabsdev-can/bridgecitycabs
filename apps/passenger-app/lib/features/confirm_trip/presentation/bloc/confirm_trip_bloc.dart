import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/fare_breakdown.dart';
import '../../data/models/payment_method_info.dart';
import '../../data/repositories/confirm_trip_repository.dart';
import 'confirm_trip_event.dart';
import 'confirm_trip_state.dart';

class ConfirmTripBloc extends Bloc<ConfirmTripEvent, ConfirmTripState> {
  final ConfirmTripRepository _repository;

  ConfirmTripBloc({required ConfirmTripRepository repository})
      : _repository = repository,
        super(const ConfirmTripState()) {
    on<ConfirmTripStarted>(_onStarted);
    on<ConfirmTripPaymentTypeChanged>(_onPaymentTypeChanged);
    on<ConfirmTripAddCardTapped>(_onAddCardTapped);
    on<ConfirmTripDriverNotesUpdated>(_onDriverNotesUpdated);
    on<ConfirmTripPickupTimeChanged>(_onPickupTimeChanged);
    on<ConfirmTripBookTapped>(_onBookTapped);
    on<ConfirmTripFareChangeAccepted>(_onFareChangeAccepted);
    on<ConfirmTripFareChangeDeclined>(_onFareChangeDeclined);
    on<ConfirmTripDismissDeclineBanner>(_onDismissDeclineBanner);
    on<ConfirmTripBackTapped>(_onBackTapped);
  }

  Future<void> _onStarted(
    ConfirmTripStarted event,
    Emitter<ConfirmTripState> emit,
  ) async {
    if (event.simulateFareChange) {
      emit(state.copyWith(
        status: ConfirmTripStatus.fareChanged,
        fare: FareBreakdown.fareChanged,
      ));
      return;
    }

    if (event.simulateDecline) {
      emit(state.copyWith(
        status: ConfirmTripStatus.declined,
        payment: PaymentMethodInfo.declinedVisa,
      ));
      return;
    }

    if (event.initialPayment == PaymentType.card) {
      if (event.hasLinkedCard) {
        emit(state.copyWith(
          status: ConfirmTripStatus.ready,
          payment: PaymentMethodInfo.linkedVisa,
        ));
      } else {
        emit(state.copyWith(
          status: ConfirmTripStatus.cardRequired,
          payment: PaymentMethodInfo.unlinkedCard,
        ));
      }
    } else {
      emit(state.copyWith(
        status: ConfirmTripStatus.ready,
        payment: PaymentMethodInfo.cash,
      ));
    }
  }

  void _onPaymentTypeChanged(
    ConfirmTripPaymentTypeChanged event,
    Emitter<ConfirmTripState> emit,
  ) {
    if (event.type == PaymentType.cash) {
      emit(state.copyWith(
        status: ConfirmTripStatus.ready,
        payment: PaymentMethodInfo.cash,
      ));
    } else {
      // If card was previously linked, reuse it
      if (state.payment.isLinked && !state.payment.isDeclined) {
        emit(state.copyWith(
          status: ConfirmTripStatus.ready,
          payment: PaymentMethodInfo.linkedVisa,
        ));
      } else {
        emit(state.copyWith(
          status: ConfirmTripStatus.cardRequired,
          payment: PaymentMethodInfo.unlinkedCard,
        ));
      }
    }
  }

  Future<void> _onAddCardTapped(
    ConfirmTripAddCardTapped event,
    Emitter<ConfirmTripState> emit,
  ) async {
    final linked = await _repository.linkNewCard();
    emit(state.copyWith(
      status: ConfirmTripStatus.ready,
      payment: linked,
    ));
  }

  void _onDriverNotesUpdated(
    ConfirmTripDriverNotesUpdated event,
    Emitter<ConfirmTripState> emit,
  ) {
    emit(state.copyWith(
      details: state.details.copyWith(driverNotes: event.notes),
    ));
  }

  void _onPickupTimeChanged(
    ConfirmTripPickupTimeChanged event,
    Emitter<ConfirmTripState> emit,
  ) {
    emit(state.copyWith(
      details: state.details.copyWith(pickupTime: event.time),
    ));
  }

  Future<void> _onBookTapped(
    ConfirmTripBookTapped event,
    Emitter<ConfirmTripState> emit,
  ) async {
    if (!state.canBook) return;

    emit(state.copyWith(status: ConfirmTripStatus.booking));

    // Check if dynamic surge or traffic recalculated fare
    final fareUpdate = await _repository.checkForFareUpdate();
    if (fareUpdate != null) {
      emit(state.copyWith(
        status: ConfirmTripStatus.fareChanged,
        fare: fareUpdate,
      ));
      return;
    }

    try {
      await _repository.bookTrip(
        payment: state.payment,
        totalAmount: state.fare.totalCad,
      );
      emit(state.copyWith(
        status: ConfirmTripStatus.success,
        targetRoute: '/searching',
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ConfirmTripStatus.declined,
        payment: PaymentMethodInfo.declinedVisa,
      ));
    }
  }

  void _onFareChangeAccepted(
    ConfirmTripFareChangeAccepted event,
    Emitter<ConfirmTripState> emit,
  ) {
    emit(state.copyWith(
      status: ConfirmTripStatus.success,
      targetRoute: '/searching',
    ));
  }

  void _onFareChangeDeclined(
    ConfirmTripFareChangeDeclined event,
    Emitter<ConfirmTripState> emit,
  ) {
    emit(state.copyWith(targetRoute: '/options'));
  }

  void _onDismissDeclineBanner(
    ConfirmTripDismissDeclineBanner event,
    Emitter<ConfirmTripState> emit,
  ) {
    emit(state.copyWith(
      status: ConfirmTripStatus.ready,
      payment: PaymentMethodInfo.cash,
    ));
  }

  void _onBackTapped(
    ConfirmTripBackTapped event,
    Emitter<ConfirmTripState> emit,
  ) {
    emit(state.copyWith(targetRoute: '/options'));
  }
}
