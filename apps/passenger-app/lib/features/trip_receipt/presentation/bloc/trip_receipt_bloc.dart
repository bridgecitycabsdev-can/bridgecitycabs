import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/receipt_models.dart';
import '../../data/repositories/trip_receipt_repository.dart';
import 'trip_receipt_event.dart';
import 'trip_receipt_state.dart';

class TripReceiptBloc extends Bloc<TripReceiptEvent, TripReceiptState> {
  final TripReceiptRepository repository;

  TripReceiptBloc({TripReceiptRepository? repository})
      : repository = repository ?? MockTripReceiptRepository(),
        super(const TripReceiptState()) {
    on<TripReceiptStarted>(_onStarted);
    on<TripReceiptCashPaymentConfirmed>(_onCashPaymentConfirmed);
    on<TripReceiptRateDriverTapped>(_onRateDriverTapped);
    on<TripReceiptRatingSubmitted>(_onRatingSubmitted);
    on<TripReceiptReportProblemTapped>(_onReportProblemTapped);
    on<TripReceiptCopyTrackingIdTapped>(_onCopyTrackingIdTapped);
    on<TripReceiptDoneTapped>(_onDoneTapped);
  }

  Future<void> _onStarted(
    TripReceiptStarted event,
    Emitter<TripReceiptState> emit,
  ) async {
    final receipt = event.receipt ?? state.receipt;

    if (event.simulateLoading) {
      emit(state.copyWith(
        status: TripReceiptStatus.loading,
        receipt: receipt,
      ));
      await Future.delayed(const Duration(milliseconds: 700));
    }

    TripReceiptStatus determinedStatus;
    if (event.initialStatus != null) {
      determinedStatus = event.initialStatus!;
    } else if (receipt.fare.hasDiscount) {
      determinedStatus = TripReceiptStatus.discountApplied;
    } else if (receipt.fare.isCard) {
      determinedStatus = TripReceiptStatus.cardPaid;
    } else {
      determinedStatus = TripReceiptStatus.cashPending;
    }

    emit(state.copyWith(
      status: determinedStatus,
      receipt: receipt,
      isSubmittingRating: false,
      isRatingSubmitted: false,
      showRatingSheet: false,
      showProblemSheet: false,
      isCopiedToClipboard: false,
      navigateToHome: false,
    ));
  }

  void _onCashPaymentConfirmed(
    TripReceiptCashPaymentConfirmed event,
    Emitter<TripReceiptState> emit,
  ) {
    final updatedFare = state.receipt.fare.copyWith(
      paymentStatusText: 'Cash (Driver Confirmed)',
    );
    emit(state.copyWith(
      status: TripReceiptStatus.cashConfirmed,
      receipt: state.receipt.copyWith(fare: updatedFare),
    ));
  }

  void _onRateDriverTapped(
    TripReceiptRateDriverTapped event,
    Emitter<TripReceiptState> emit,
  ) {
    if (state.canRateDriver) {
      emit(state.copyWith(showRatingSheet: true));
    }
  }

  Future<void> _onRatingSubmitted(
    TripReceiptRatingSubmitted event,
    Emitter<TripReceiptState> emit,
  ) async {
    emit(state.copyWith(
      isSubmittingRating: true,
      showRatingSheet: false,
    ));

    await repository.submitDriverRating(
      trackingId: state.receipt.trackingId,
      rating: event.rating,
      feedback: event.feedback,
    );

    emit(state.copyWith(
      isSubmittingRating: false,
      isRatingSubmitted: true,
      receipt: state.receipt.copyWith(
        userRating: event.rating,
        ratingFeedback: event.feedback,
      ),
    ));
  }

  void _onReportProblemTapped(
    TripReceiptReportProblemTapped event,
    Emitter<TripReceiptState> emit,
  ) {
    emit(state.copyWith(showProblemSheet: true));
  }

  void _onCopyTrackingIdTapped(
    TripReceiptCopyTrackingIdTapped event,
    Emitter<TripReceiptState> emit,
  ) {
    emit(state.copyWith(isCopiedToClipboard: true));
  }

  void _onDoneTapped(
    TripReceiptDoneTapped event,
    Emitter<TripReceiptState> emit,
  ) {
    emit(state.copyWith(navigateToHome: true));
  }
}
