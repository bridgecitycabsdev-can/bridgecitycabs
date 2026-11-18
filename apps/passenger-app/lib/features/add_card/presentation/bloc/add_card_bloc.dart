import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/add_card_config.dart';
import '../../data/models/add_card_models.dart';
import '../../data/repositories/add_card_repository.dart';
import 'add_card_event.dart';
import 'add_card_state.dart';

class AddCardBloc extends Bloc<AddCardEvent, AddCardState> {
  final AddCardRepository repository;

  AddCardBloc({AddCardRepository? repository})
      : repository = repository ?? MockAddCardRepository(),
        super(const AddCardState()) {
    on<AddCardStarted>(_onStarted);
    on<AddCardNumberChanged>(_onNumberChanged);
    on<AddCardExpiryChanged>(_onExpiryChanged);
    on<AddCardCvcChanged>(_onCvcChanged);
    on<AddCardPostalCodeChanged>(_onPostalCodeChanged);
    on<AddCardNameChanged>(_onNameChanged);
    on<AddCardDefaultToggled>(_onDefaultToggled);
    on<AddCardSaveTapped>(_onSaveTapped);
    on<AddCardOtpChanged>(_onOtpChanged);
    on<AddCardOtpSubmitted>(_onOtpSubmitted);
    on<AddCard3DCancelled>(_on3DCancelled);
    on<AddCardRetryTapped>(_onRetryTapped);
    on<AddCardUseDifferentCardTapped>(_onUseDifferentCardTapped);
    on<AddCardRefreshPendingTapped>(_onRefreshPendingTapped);
    on<AddCardErrorDismissed>(_onErrorDismissed);
    on<AddCardReturnToPaymentMethodsTapped>(_onReturnToPaymentMethods);
    on<AddCardBackTapped>(_onBackTapped);
  }

  void _onStarted(
    AddCardStarted event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      status: event.initialStatus ?? AddCardStatus.initial,
      form: event.initialForm ?? state.form,
      threeD: event.initialThreeD ?? state.threeD,
      clearError: true,
      showBankConfirmDialog:
          event.initialStatus == AddCardStatus.confirmingBank,
      showThreeDDialog:
          event.initialStatus == AddCardStatus.threeDSecureOtp,
      navigateToPaymentMethods: false,
    ));
  }

  void _onNumberChanged(
    AddCardNumberChanged event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      form: state.form.copyWith(cardNumber: event.cardNumber),
    ));
  }

  void _onExpiryChanged(
    AddCardExpiryChanged event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      form: state.form.copyWith(expiry: event.expiry),
    ));
  }

  void _onCvcChanged(
    AddCardCvcChanged event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      form: state.form.copyWith(cvc: event.cvc),
    ));
  }

  void _onPostalCodeChanged(
    AddCardPostalCodeChanged event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      form: state.form.copyWith(postalCode: event.postalCode),
    ));
  }

  void _onNameChanged(
    AddCardNameChanged event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      form: state.form.copyWith(nameOnCard: event.name),
    ));
  }

  void _onDefaultToggled(
    AddCardDefaultToggled event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      form: state.form.copyWith(isDefault: event.isDefault),
    ));
  }

  Future<void> _onSaveTapped(
    AddCardSaveTapped event,
    Emitter<AddCardState> emit,
  ) async {
    emit(state.copyWith(
      status: AddCardStatus.tokenizing,
      clearError: true,
    ));

    try {
      await repository.tokenizeCard(state.form);

      if (repository is MockAddCardRepository) {
        final mock = repository as MockAddCardRepository;
        if (mock.require3DSecure) {
          emit(state.copyWith(
            status: AddCardStatus.confirmingBank,
            showBankConfirmDialog: true,
          ));
          await Future.delayed(const Duration(milliseconds: 700));
          emit(state.copyWith(
            status: AddCardStatus.threeDSecureOtp,
            showBankConfirmDialog: false,
            showThreeDDialog: true,
          ));
          return;
        }

        if (mock.requirePendingVerification) {
          emit(state.copyWith(
            status: AddCardStatus.verificationPending,
          ));
          return;
        }
      }

      emit(state.copyWith(
        status: AddCardStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddCardStatus.declined,
        errorMessage: AddCardConfig.cardDeclinedSubtitle,
      ));
    }
  }

  void _onOtpChanged(
    AddCardOtpChanged event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      threeD: state.threeD.copyWith(code: event.otpCode),
    ));
  }

  Future<void> _onOtpSubmitted(
    AddCardOtpSubmitted event,
    Emitter<AddCardState> emit,
  ) async {
    emit(state.copyWith(status: AddCardStatus.tokenizing));

    try {
      await repository.submit3DSecureOtp(code: state.threeD.code);
      emit(state.copyWith(
        status: AddCardStatus.success,
        showThreeDDialog: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddCardStatus.declined,
        showThreeDDialog: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _on3DCancelled(
    AddCard3DCancelled event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      status: AddCardStatus.initial,
      showThreeDDialog: false,
    ));
  }

  void _onRetryTapped(
    AddCardRetryTapped event,
    Emitter<AddCardState> emit,
  ) {
    add(const AddCardSaveTapped());
  }

  void _onUseDifferentCardTapped(
    AddCardUseDifferentCardTapped event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(
      status: AddCardStatus.initial,
      form: const CardFormData(),
      clearError: true,
    ));
  }

  Future<void> _onRefreshPendingTapped(
    AddCardRefreshPendingTapped event,
    Emitter<AddCardState> emit,
  ) async {
    emit(state.copyWith(status: AddCardStatus.tokenizing));
    await repository.refreshVerificationStatus(state.form.last4);
    emit(state.copyWith(status: AddCardStatus.success));
  }

  void _onErrorDismissed(
    AddCardErrorDismissed event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  void _onReturnToPaymentMethods(
    AddCardReturnToPaymentMethodsTapped event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(navigateToPaymentMethods: true));
  }

  void _onBackTapped(
    AddCardBackTapped event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(navigateToPaymentMethods: true));
  }
}
