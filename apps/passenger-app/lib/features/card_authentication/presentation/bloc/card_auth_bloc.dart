import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/card_auth_config.dart';
import '../../data/models/card_auth_model.dart';
import '../../data/repositories/card_auth_repository.dart';
import 'card_auth_event.dart';
import 'card_auth_state.dart';

class CardAuthBloc extends Bloc<CardAuthEvent, CardAuthState> {
  final CardAuthRepository _repository;

  CardAuthBloc({required CardAuthRepository repository})
      : _repository = repository,
        super(const CardAuthState()) {
    on<CardAuthStarted>(_onStarted);
    on<CardAuthContinueToVerifyTapped>(_onContinueToVerifyTapped);
    on<CardAuthPayCashInsteadTapped>(_onPayCashInsteadTapped);
    on<CardAuthTestScenarioSelected>(_onTestScenarioSelected);
    on<CardAuthEdgeCaseSelected>(_onEdgeCaseSelected);
    on<CardAuthPaymentMethodSelected>(_onPaymentMethodSelected);
    on<CardAuthBookWithSelectedMethodTapped>(_onBookWithSelectedMethodTapped);
    on<CardAuthCancelTapped>(_onCancelTapped);
    on<CardAuthChangeCardTapped>(_onChangeCardTapped);
    on<CardAuthAddNewCardTapped>(_onAddNewCardTapped);
  }

  Future<void> _onStarted(
    CardAuthStarted event,
    Emitter<CardAuthState> emit,
  ) async {
    final stage = event.initialStage ?? state.stage;
    final testScenario = event.initialTestScenario ?? state.selectedTestScenario;
    final edgeScenario = event.initialEdgeScenario ?? state.selectedEdgeScenario;

    final currentCard = stage == CardAuthStage.expiredCard
        ? CardAuthConfig.expiredCardMethod
        : state.currentCard;

    emit(state.copyWith(
      stage: stage,
      selectedTestScenario: testScenario,
      selectedEdgeScenario: edgeScenario,
      currentCard: currentCard,
    ));
  }

  Future<void> _onContinueToVerifyTapped(
    CardAuthContinueToVerifyTapped event,
    Emitter<CardAuthState> emit,
  ) async {
    emit(state.copyWith(
      stage: CardAuthStage.waitingForBank,
      isProcessing: true,
      feedbackMessage: () => 'Contacting card issuer for 3D Secure challenge...',
    ));

    try {
      await _repository.initiate3dsChallenge(
        paymentMethodId: state.currentCard.id,
        amountCad: state.fareCad,
      );
      emit(state.copyWith(isProcessing: false));
    } catch (_) {
      emit(state.copyWith(
        stage: CardAuthStage.declined,
        isProcessing: false,
      ));
    }
  }

  void _onPayCashInsteadTapped(
    CardAuthPayCashInsteadTapped event,
    Emitter<CardAuthState> emit,
  ) {
    emit(state.copyWith(
      selectedPaymentMethodId: 'pm_cash',
      feedbackMessage: () => 'Switched to Cash payment with driver.',
    ));
  }

  void _onTestScenarioSelected(
    CardAuthTestScenarioSelected event,
    Emitter<CardAuthState> emit,
  ) {
    switch (event.scenario) {
      case AuthTestScenario.waiting:
        emit(state.copyWith(
          selectedTestScenario: event.scenario,
          stage: CardAuthStage.waitingForBank,
        ));
        break;
      case AuthTestScenario.verified:
        emit(state.copyWith(
          selectedTestScenario: event.scenario,
          stage: CardAuthStage.verified,
          feedbackMessage: () => 'Bank authentication verified successfully.',
        ));
        break;
      case AuthTestScenario.failed:
        emit(state.copyWith(
          selectedTestScenario: event.scenario,
          stage: CardAuthStage.declined,
          errorCode: CardAuthConfig.errDeclinedGeneric,
          errorMessage: CardAuthConfig.declinedErrorMessage,
        ));
        break;
      case AuthTestScenario.canceled:
        emit(state.copyWith(
          selectedTestScenario: event.scenario,
          stage: CardAuthStage.canceled,
          feedbackMessage: () => 'Card verification canceled.',
        ));
        break;
    }
  }

  void _onEdgeCaseSelected(
    CardAuthEdgeCaseSelected event,
    Emitter<CardAuthState> emit,
  ) {
    String msg = CardAuthConfig.expiredErrorMessage;
    AuthPaymentMethod card = CardAuthConfig.expiredCardMethod;

    switch (event.scenario) {
      case EdgeCaseScenario.expiredCard:
        msg = 'This card has expired. Please choose another payment method.';
        card = CardAuthConfig.expiredCardMethod;
        break;
      case EdgeCaseScenario.insufficientFunds:
        msg = 'Insufficient funds in account. Please select another payment method.';
        card = CardAuthConfig.mockMethods[0].copyWith(
          subtitle: 'Declined (Insufficient funds)',
        );
        break;
      case EdgeCaseScenario.paymentError:
        msg = 'Payment gateway timeout. Please choose another payment method.';
        card = CardAuthConfig.mockMethods[0].copyWith(
          subtitle: 'Payment gateway error',
        );
        break;
    }

    emit(state.copyWith(
      selectedEdgeScenario: event.scenario,
      stage: CardAuthStage.expiredCard,
      currentCard: card,
      errorMessage: msg,
    ));
  }

  void _onPaymentMethodSelected(
    CardAuthPaymentMethodSelected event,
    Emitter<CardAuthState> emit,
  ) {
    emit(state.copyWith(selectedPaymentMethodId: event.paymentMethodId));
  }

  Future<void> _onBookWithSelectedMethodTapped(
    CardAuthBookWithSelectedMethodTapped event,
    Emitter<CardAuthState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));
    try {
      await _repository.retryPaymentWithMethod(
        paymentMethodId: state.selectedPaymentMethodId,
        amountCad: state.fareCad,
      );
      emit(state.copyWith(
        stage: CardAuthStage.verified,
        isProcessing: false,
        feedbackMessage: () => 'Ride booked successfully with selected payment method!',
      ));
    } catch (_) {
      emit(state.copyWith(isProcessing: false));
    }
  }

  void _onCancelTapped(
    CardAuthCancelTapped event,
    Emitter<CardAuthState> emit,
  ) {
    emit(state.copyWith(stage: CardAuthStage.canceled));
  }

  void _onChangeCardTapped(
    CardAuthChangeCardTapped event,
    Emitter<CardAuthState> emit,
  ) {
    emit(state.copyWith(
      stage: CardAuthStage.declined,
      feedbackMessage: () => 'Select an alternate payment method below.',
    ));
  }

  void _onAddNewCardTapped(
    CardAuthAddNewCardTapped event,
    Emitter<CardAuthState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Navigating to Add New Card screen...',
    ));
  }
}
