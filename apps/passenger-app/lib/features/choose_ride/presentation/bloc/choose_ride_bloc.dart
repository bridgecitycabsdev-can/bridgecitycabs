import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/choose_ride_qa_scenario.dart';
import '../../data/models/promo_code.dart';
import '../../data/models/ride_option_tier.dart';
import '../../data/models/ride_preference.dart';
import '../../data/repositories/choose_ride_repository.dart';
import 'choose_ride_event.dart';
import 'choose_ride_state.dart';

class ChooseRideBloc extends Bloc<ChooseRideEvent, ChooseRideState> {
  final ChooseRideRepository repository;

  ChooseRideBloc({ChooseRideRepository? repository})
      : repository = repository ?? ChooseRideRepositoryImpl(),
        super(const ChooseRideState()) {
    on<ChooseRideStarted>(_onStarted);
    on<ChooseRideTierSelected>(_onTierSelected);
    on<ChooseRidePromoInputChanged>(_onPromoInputChanged);
    on<ChooseRideClearPromoInputTapped>(_onClearPromoInputTapped);
    on<ChooseRidePromoApplied>(_onPromoApplied);
    on<ChooseRidePromoRemoved>(_onPromoRemoved);
    on<ChooseRidePreferenceChanged>(_onPreferenceChanged);
    on<ChooseRideQaScenarioSelected>(_onQaScenarioSelected);
    on<ChooseRideDemoStateSelected>(_onDemoStateSelected);
    on<ChooseRideOpenPromoTermsTapped>(_onOpenPromoTermsTapped);
    on<ChooseRideClosePromoTermsTapped>(_onClosePromoTermsTapped);
    on<ChooseRidePaymentChanged>(_onPaymentChanged);
    on<ChooseRideToggleInspectorMode>(_onToggleInspectorMode);
    on<ChooseRideContinueTapped>(_onContinueTapped);
    on<ChooseRideBackTapped>(_onBackTapped);
  }

  Future<void> _onStarted(
    ChooseRideStarted event,
    Emitter<ChooseRideState> emit,
  ) async {
    emit(state.copyWith(status: ChooseRideStatus.loading));

    if (event.initialPromo != null ||
        event.initialQaScenario == QaPromoScenario.validApplied) {
      final promo = event.initialPromo ??
          const PromoCode(
            code: 'WELCOME5',
            description: 'Promo applied · \$3.00 off total fare',
            discountAmountCad: 3.00,
            isValid: true,
          );

      emit(state.copyWith(
        status: ChooseRideStatus.promoApplied,
        tiers: RideOptionTier.promoAppliedTiers(),
        appliedPromo: promo,
        selectedTierId: 'sedan',
        demoState: event.initialDemoState ?? ChooseRideDemoState.collapsed,
        isInspectorMode: event.isInspectorMode,
      ));
      return;
    }

    if (event.initialQaScenario != null) {
      final scenario = event.initialQaScenario!;
      emit(state.copyWith(
        status: scenario.isValid
            ? ChooseRideStatus.promoApplied
            : ChooseRideStatus.promoError,
        qaScenario: scenario,
        couponInput: scenario.defaultCouponCode,
        promoInputError: scenario.isValid ? null : scenario.errorMessage,
        isInspectorMode: event.isInspectorMode,
        demoState: event.initialDemoState ?? ChooseRideDemoState.collapsed,
        tiers: scenario.isValid
            ? RideOptionTier.promoAppliedTiers()
            : RideOptionTier.standardTiers,
      ));
      return;
    }

    final tiers = await repository.getRideTiers(
      simulateUnavailable: event.simulateUnavailable,
    );

    emit(state.copyWith(
      status: event.isExpiring
          ? ChooseRideStatus.expiringQuote
          : ChooseRideStatus.loaded,
      tiers: tiers,
      validitySeconds: event.isExpiring ? 25 : 300,
      isExpiring: event.isExpiring,
      demoState: event.initialDemoState ?? ChooseRideDemoState.collapsed,
      isInspectorMode: event.isInspectorMode,
    ));
  }

  void _onTierSelected(
    ChooseRideTierSelected event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(selectedTierId: event.tierId));
  }

  void _onPromoInputChanged(
    ChooseRidePromoInputChanged event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(couponInput: event.code));
  }

  void _onClearPromoInputTapped(
    ChooseRideClearPromoInputTapped event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(
      couponInput: '',
      clearPromoError: true,
    ));
  }

  Future<void> _onPromoApplied(
    ChooseRidePromoApplied event,
    Emitter<ChooseRideState> emit,
  ) async {
    final code = event.code.trim().toUpperCase();

    if (code == 'WELCOME5' || code == 'LETHBRIDGE3' || code == 'LETH3') {
      const promo = PromoCode(
        code: 'WELCOME5',
        description: 'Promo applied · \$3.00 off total fare',
        discountAmountCad: 3.00,
        isValid: true,
      );

      emit(state.copyWith(
        status: ChooseRideStatus.promoApplied,
        appliedPromo: promo,
        tiers: RideOptionTier.promoAppliedTiers(),
        clearPromoError: true,
        feedbackMessage: () => 'WELCOME5 verified: \$3.00 off total fare',
      ));
    } else {
      final validated = await repository.validatePromoCode(code);
      if (validated.isValid) {
        emit(state.copyWith(
          status: ChooseRideStatus.promoApplied,
          appliedPromo: validated,
          tiers: state.tiers.map((t) => t.applyDiscount(validated.discountAmountCad)).toList(),
          clearPromoError: true,
        ));
      } else {
        emit(state.copyWith(
          status: ChooseRideStatus.promoError,
          promoInputError: validated.errorMessage ??
              "This promo code isn't valid.\nCheck for typos or contact Bridge City support.",
          clearPromo: true,
          tiers: RideOptionTier.standardTiers,
        ));
      }
    }
  }

  void _onPromoRemoved(
    ChooseRidePromoRemoved event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(
      status: ChooseRideStatus.loaded,
      clearPromo: true,
      clearPromoError: true,
      tiers: RideOptionTier.standardTiers,
      feedbackMessage: () => 'Promo code removed',
    ));
  }

  void _onPreferenceChanged(
    ChooseRidePreferenceChanged event,
    Emitter<ChooseRideState> emit,
  ) {
    final updated = state.preference.copyWith(
      vanOnly: event.vanOnly,
      ladyDriverOnly: event.ladyDriverOnly,
    );
    emit(state.copyWith(preference: updated));
  }

  void _onQaScenarioSelected(
    ChooseRideQaScenarioSelected event,
    Emitter<ChooseRideState> emit,
  ) {
    final scenario = event.scenario;

    if (scenario.isValid) {
      const promo = PromoCode(
        code: 'WELCOME5',
        description: 'Promo applied · \$3.00 off total fare',
        discountAmountCad: 3.00,
        isValid: true,
      );

      emit(state.copyWith(
        status: ChooseRideStatus.promoApplied,
        qaScenario: scenario,
        couponInput: scenario.defaultCouponCode,
        appliedPromo: promo,
        tiers: RideOptionTier.promoAppliedTiers(),
        clearPromoError: true,
        feedbackMessage: () => 'Scenario: Valid Applied (WELCOME5)',
      ));
    } else {
      emit(state.copyWith(
        status: ChooseRideStatus.promoError,
        qaScenario: scenario,
        couponInput: scenario.defaultCouponCode,
        promoInputError: scenario.errorMessage,
        clearPromo: true,
        tiers: RideOptionTier.standardTiers,
        feedbackMessage: () => 'Scenario: ${scenario.chipLabel}',
      ));
    }
  }

  void _onDemoStateSelected(
    ChooseRideDemoStateSelected event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(demoState: event.demoState));
  }

  void _onOpenPromoTermsTapped(
    ChooseRideOpenPromoTermsTapped event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(showPromoTermsModal: true));
  }

  void _onClosePromoTermsTapped(
    ChooseRideClosePromoTermsTapped event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(showPromoTermsModal: false));
  }

  void _onPaymentChanged(
    ChooseRidePaymentChanged event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(
      paymentMethodLabel: event.paymentMethod,
      feedbackMessage: () => 'Payment updated to ${event.paymentMethod}',
    ));
  }

  void _onToggleInspectorMode(
    ChooseRideToggleInspectorMode event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(
      isInspectorMode: !state.isInspectorMode,
      feedbackMessage: () => state.isInspectorMode
          ? 'Switched to Passenger Selection View'
          : 'Switched to QA Promo Inspector View',
    ));
  }

  void _onContinueTapped(
    ChooseRideContinueTapped event,
    Emitter<ChooseRideState> emit,
  ) {
    final tier = state.selectedTier?.name ?? 'Sedan';
    emit(state.copyWith(
      isContinueTriggered: true,
      targetRoute: '/confirm',
      feedbackMessage: () =>
          'Continuing with $tier · ${state.formattedFinalPrice}',
    ));
  }

  void _onBackTapped(
    ChooseRideBackTapped event,
    Emitter<ChooseRideState> emit,
  ) {
    emit(state.copyWith(targetRoute: '/home'));
  }
}
