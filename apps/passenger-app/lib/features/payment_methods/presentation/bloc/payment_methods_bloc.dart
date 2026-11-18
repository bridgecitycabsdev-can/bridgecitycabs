import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_card_model.dart';
import '../../data/models/payment_methods_config.dart';
import '../../data/repositories/payment_methods_repository.dart';
import 'payment_methods_event.dart';
import 'payment_methods_state.dart';

class PaymentMethodsBloc extends Bloc<PaymentMethodsEvent, PaymentMethodsState> {
  final PaymentMethodsRepository repository;
  String? _lastFailedCardId;

  PaymentMethodsBloc({PaymentMethodsRepository? repository})
      : repository = repository ?? MockPaymentMethodsRepository(),
        super(const PaymentMethodsState()) {
    on<PaymentMethodsStarted>(_onStarted);
    on<PaymentMethodsCashSelected>(_onCashSelected);
    on<PaymentMethodsCardSelected>(_onCardSelected);
    on<PaymentMethodsRemoveCardInitiated>(_onRemoveCardInitiated);
    on<PaymentMethodsRemoveCardConfirmed>(_onRemoveCardConfirmed);
    on<PaymentMethodsRemoveCardCancelled>(_onRemoveCardCancelled);
    on<PaymentMethodsAddCardTapped>(_onAddCardTapped);
    on<PaymentMethodsCardAdded>(_onCardAdded);
    on<PaymentMethodsErrorDismissed>(_onErrorDismissed);
    on<PaymentMethodsRetryTapped>(_onRetryTapped);
    on<PaymentMethodsBackTapped>(_onBackTapped);
  }

  Future<void> _onStarted(
    PaymentMethodsStarted event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    if (event.simulateLoading) {
      emit(state.copyWith(status: PaymentMethodsStatus.loading));
      await Future.delayed(const Duration(milliseconds: 600));
    }

    List<PaymentCard> cards;
    if (event.initialCards != null) {
      cards = event.initialCards!;
    } else {
      try {
        cards = await repository.fetchCards();
      } catch (e) {
        emit(state.copyWith(
          status: PaymentMethodsStatus.error,
          errorMessage: e.toString(),
        ));
        return;
      }
    }

    final paymentType = event.initialPaymentType ??
        (cards.isEmpty ? SelectedPaymentType.cash : SelectedPaymentType.card);

    emit(state.copyWith(
      status: event.initialStatus ?? PaymentMethodsStatus.loaded,
      cards: cards,
      selectedPaymentType: paymentType,
      clearError: true,
      clearPendingRemoval: true,
      navigateBack: false,
      showAddCardSheet: false,
    ));
  }

  void _onCashSelected(
    PaymentMethodsCashSelected event,
    Emitter<PaymentMethodsState> emit,
  ) {
    emit(state.copyWith(
      selectedPaymentType: SelectedPaymentType.cash,
    ));
  }

  Future<void> _onCardSelected(
    PaymentMethodsCardSelected event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    final targetCard = state.cards.firstWhere(
      (c) => c.id == event.cardId,
      orElse: () => state.cards.first,
    );

    if (targetCard.isDefault && state.selectedPaymentType == SelectedPaymentType.card) {
      return;
    }

    _lastFailedCardId = event.cardId;

    emit(state.copyWith(
      status: PaymentMethodsStatus.updatingDefault,
      updatingCardId: event.cardId,
      clearError: true,
    ));

    try {
      await repository.setDefaultCard(event.cardId);

      final updatedCards = state.cards.map((c) {
        return c.copyWith(isDefault: c.id == event.cardId);
      }).toList();

      emit(state.copyWith(
        status: PaymentMethodsStatus.loaded,
        cards: updatedCards,
        selectedPaymentType: SelectedPaymentType.card,
        updatingCardId: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodsStatus.error,
        errorMessage: e.toString().contains('Exception:')
            ? e.toString().replaceFirst('Exception: ', '')
            : PaymentMethodsConfig.defaultUpdateErrorMessage,
        updatingCardId: null,
      ));
    }
  }

  void _onRemoveCardInitiated(
    PaymentMethodsRemoveCardInitiated event,
    Emitter<PaymentMethodsState> emit,
  ) {
    emit(state.copyWith(cardPendingRemoval: event.card));
  }

  void _onRemoveCardCancelled(
    PaymentMethodsRemoveCardCancelled event,
    Emitter<PaymentMethodsState> emit,
  ) {
    emit(state.copyWith(clearPendingRemoval: true));
  }

  Future<void> _onRemoveCardConfirmed(
    PaymentMethodsRemoveCardConfirmed event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(
      status: PaymentMethodsStatus.removingCard,
      clearPendingRemoval: true,
    ));

    try {
      await repository.removeCard(event.cardId);
      final updatedCards = await repository.fetchCards();

      final newPaymentType = updatedCards.isEmpty
          ? SelectedPaymentType.cash
          : state.selectedPaymentType;

      emit(state.copyWith(
        status: PaymentMethodsStatus.loaded,
        cards: updatedCards,
        selectedPaymentType: newPaymentType,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onAddCardTapped(
    PaymentMethodsAddCardTapped event,
    Emitter<PaymentMethodsState> emit,
  ) {
    emit(state.copyWith(showAddCardSheet: true));
  }

  Future<void> _onCardAdded(
    PaymentMethodsCardAdded event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(
      status: PaymentMethodsStatus.loading,
      showAddCardSheet: false,
    ));

    try {
      await repository.addCard(
        brand: event.brand,
        last4: event.last4,
        expiry: event.expiry,
      );
      final updatedCards = await repository.fetchCards();

      emit(state.copyWith(
        status: PaymentMethodsStatus.loaded,
        cards: updatedCards,
        selectedPaymentType: SelectedPaymentType.card,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onErrorDismissed(
    PaymentMethodsErrorDismissed event,
    Emitter<PaymentMethodsState> emit,
  ) {
    emit(state.copyWith(
      clearError: true,
      status: PaymentMethodsStatus.loaded,
    ));
  }

  void _onRetryTapped(
    PaymentMethodsRetryTapped event,
    Emitter<PaymentMethodsState> emit,
  ) {
    if (_lastFailedCardId != null) {
      add(PaymentMethodsCardSelected(_lastFailedCardId!));
    } else {
      add(const PaymentMethodsStarted());
    }
  }

  void _onBackTapped(
    PaymentMethodsBackTapped event,
    Emitter<PaymentMethodsState> emit,
  ) {
    emit(state.copyWith(navigateBack: true));
  }
}
