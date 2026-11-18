import 'package:equatable/equatable.dart';
import '../../data/models/card_auth_config.dart';
import '../../data/models/card_auth_model.dart';

class CardAuthState extends Equatable {
  final CardAuthStage stage;
  final AuthTestScenario selectedTestScenario;
  final EdgeCaseScenario selectedEdgeScenario;
  final double fareCad;
  final String selectedPaymentMethodId;
  final List<AuthPaymentMethod> availableMethods;
  final AuthPaymentMethod currentCard;
  final String errorCode;
  final String errorMessage;
  final bool isProcessing;
  final String? feedbackMessage;

  const CardAuthState({
    this.stage = CardAuthStage.prompt3ds,
    this.selectedTestScenario = AuthTestScenario.waiting,
    this.selectedEdgeScenario = EdgeCaseScenario.expiredCard,
    this.fareCad = CardAuthConfig.defaultFareCad,
    this.selectedPaymentMethodId = 'pm_mc_1984',
    this.availableMethods = CardAuthConfig.mockMethods,
    this.currentCard = const AuthPaymentMethod(
      id: 'pm_visa_4242',
      brand: 'Visa',
      last4: '4242',
      expiry: '08/26',
      accountType: 'Debit card',
    ),
    this.errorCode = CardAuthConfig.errDeclinedGeneric,
    this.errorMessage = CardAuthConfig.declinedErrorMessage,
    this.isProcessing = false,
    this.feedbackMessage,
  });

  bool get isPrompt3ds => stage == CardAuthStage.prompt3ds;
  bool get isWaitingForBank => stage == CardAuthStage.waitingForBank;
  bool get isVerified => stage == CardAuthStage.verified;
  bool get isDeclined => stage == CardAuthStage.declined;
  bool get isExpiredCard => stage == CardAuthStage.expiredCard;
  bool get isCanceled => stage == CardAuthStage.canceled;

  String get formattedFare => '\$${fareCad.toStringAsFixed(2)} CAD';

  CardAuthState copyWith({
    CardAuthStage? stage,
    AuthTestScenario? selectedTestScenario,
    EdgeCaseScenario? selectedEdgeScenario,
    double? fareCad,
    String? selectedPaymentMethodId,
    List<AuthPaymentMethod>? availableMethods,
    AuthPaymentMethod? currentCard,
    String? errorCode,
    String? errorMessage,
    bool? isProcessing,
    String? Function()? feedbackMessage,
  }) {
    return CardAuthState(
      stage: stage ?? this.stage,
      selectedTestScenario: selectedTestScenario ?? this.selectedTestScenario,
      selectedEdgeScenario: selectedEdgeScenario ?? this.selectedEdgeScenario,
      fareCad: fareCad ?? this.fareCad,
      selectedPaymentMethodId:
          selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      availableMethods: availableMethods ?? this.availableMethods,
      currentCard: currentCard ?? this.currentCard,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      feedbackMessage: feedbackMessage != null
          ? feedbackMessage()
          : this.feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        stage,
        selectedTestScenario,
        selectedEdgeScenario,
        fareCad,
        selectedPaymentMethodId,
        availableMethods,
        currentCard,
        errorCode,
        errorMessage,
        isProcessing,
        feedbackMessage,
      ];
}
