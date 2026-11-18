import 'package:equatable/equatable.dart';
import '../../data/models/choose_ride_qa_scenario.dart';
import '../../data/models/promo_code.dart';

abstract class ChooseRideEvent extends Equatable {
  const ChooseRideEvent();

  @override
  List<Object?> get props => [];
}

class ChooseRideStarted extends ChooseRideEvent {
  final bool simulateUnavailable;
  final bool isExpiring;
  final PromoCode? initialPromo;
  final QaPromoScenario? initialQaScenario;
  final ChooseRideDemoState? initialDemoState;
  final bool isInspectorMode;

  const ChooseRideStarted({
    this.simulateUnavailable = false,
    this.isExpiring = false,
    this.initialPromo,
    this.initialQaScenario,
    this.initialDemoState,
    this.isInspectorMode = false,
  });

  @override
  List<Object?> get props => [
        simulateUnavailable,
        isExpiring,
        initialPromo,
        initialQaScenario,
        initialDemoState,
        isInspectorMode,
      ];
}

class ChooseRideTierSelected extends ChooseRideEvent {
  final String tierId;

  const ChooseRideTierSelected(this.tierId);

  @override
  List<Object?> get props => [tierId];
}

class ChooseRidePromoInputChanged extends ChooseRideEvent {
  final String code;

  const ChooseRidePromoInputChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class ChooseRideClearPromoInputTapped extends ChooseRideEvent {
  const ChooseRideClearPromoInputTapped();
}

class ChooseRidePromoApplied extends ChooseRideEvent {
  final String code;

  const ChooseRidePromoApplied(this.code);

  @override
  List<Object?> get props => [code];
}

class ChooseRidePromoRemoved extends ChooseRideEvent {
  const ChooseRidePromoRemoved();
}

class ChooseRidePreferenceChanged extends ChooseRideEvent {
  final bool? vanOnly;
  final bool? ladyDriverOnly;

  const ChooseRidePreferenceChanged({
    this.vanOnly,
    this.ladyDriverOnly,
  });

  @override
  List<Object?> get props => [vanOnly, ladyDriverOnly];
}

class ChooseRideQaScenarioSelected extends ChooseRideEvent {
  final QaPromoScenario scenario;

  const ChooseRideQaScenarioSelected(this.scenario);

  @override
  List<Object?> get props => [scenario];
}

class ChooseRideDemoStateSelected extends ChooseRideEvent {
  final ChooseRideDemoState demoState;

  const ChooseRideDemoStateSelected(this.demoState);

  @override
  List<Object?> get props => [demoState];
}

class ChooseRideOpenPromoTermsTapped extends ChooseRideEvent {
  const ChooseRideOpenPromoTermsTapped();
}

class ChooseRideClosePromoTermsTapped extends ChooseRideEvent {
  const ChooseRideClosePromoTermsTapped();
}

class ChooseRidePaymentChanged extends ChooseRideEvent {
  final String paymentMethod;

  const ChooseRidePaymentChanged(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class ChooseRideToggleInspectorMode extends ChooseRideEvent {
  const ChooseRideToggleInspectorMode();
}

class ChooseRideContinueTapped extends ChooseRideEvent {
  const ChooseRideContinueTapped();
}

class ChooseRideBackTapped extends ChooseRideEvent {
  const ChooseRideBackTapped();
}
