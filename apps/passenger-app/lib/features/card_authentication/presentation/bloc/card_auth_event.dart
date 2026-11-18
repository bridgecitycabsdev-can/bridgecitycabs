import 'package:equatable/equatable.dart';
import '../../data/models/card_auth_model.dart';

abstract class CardAuthEvent extends Equatable {
  const CardAuthEvent();

  @override
  List<Object?> get props => [];
}

class CardAuthStarted extends CardAuthEvent {
  final CardAuthStage? initialStage;
  final AuthTestScenario? initialTestScenario;
  final EdgeCaseScenario? initialEdgeScenario;

  const CardAuthStarted({
    this.initialStage,
    this.initialTestScenario,
    this.initialEdgeScenario,
  });

  @override
  List<Object?> get props => [
        initialStage,
        initialTestScenario,
        initialEdgeScenario,
      ];
}

class CardAuthContinueToVerifyTapped extends CardAuthEvent {
  const CardAuthContinueToVerifyTapped();
}

class CardAuthPayCashInsteadTapped extends CardAuthEvent {
  const CardAuthPayCashInsteadTapped();
}

class CardAuthTestScenarioSelected extends CardAuthEvent {
  final AuthTestScenario scenario;
  const CardAuthTestScenarioSelected(this.scenario);

  @override
  List<Object?> get props => [scenario];
}

class CardAuthEdgeCaseSelected extends CardAuthEvent {
  final EdgeCaseScenario scenario;
  const CardAuthEdgeCaseSelected(this.scenario);

  @override
  List<Object?> get props => [scenario];
}

class CardAuthPaymentMethodSelected extends CardAuthEvent {
  final String paymentMethodId;
  const CardAuthPaymentMethodSelected(this.paymentMethodId);

  @override
  List<Object?> get props => [paymentMethodId];
}

class CardAuthBookWithSelectedMethodTapped extends CardAuthEvent {
  const CardAuthBookWithSelectedMethodTapped();
}

class CardAuthCancelTapped extends CardAuthEvent {
  const CardAuthCancelTapped();
}

class CardAuthChangeCardTapped extends CardAuthEvent {
  const CardAuthChangeCardTapped();
}

class CardAuthAddNewCardTapped extends CardAuthEvent {
  const CardAuthAddNewCardTapped();
}
