import 'package:equatable/equatable.dart';
import '../../data/models/choose_ride_config.dart';
import '../../data/models/choose_ride_qa_scenario.dart';
import '../../data/models/promo_code.dart';
import '../../data/models/ride_option_tier.dart';
import '../../data/models/ride_preference.dart';

enum ChooseRideStatus {
  loading,
  loaded,
  promoApplied,
  promoError,
  expiringQuote,
}

class ChooseRideState extends Equatable {
  final ChooseRideStatus status;
  final List<RideOptionTier> tiers;
  final String selectedTierId;
  final PromoCode? appliedPromo;
  final String couponInput;
  final String? promoInputError;
  final QaPromoScenario qaScenario;
  final ChooseRideDemoState demoState;
  final bool isInspectorMode;
  final bool showPromoTermsModal;
  final RidePreference preference;
  final String paymentMethod;
  final String paymentMethodLabel;
  final String routeText;
  final String routeAreaLabel;
  final String distanceText;
  final String destinationText;
  final int validitySeconds;
  final bool isExpiring;
  final String? feedbackMessage;
  final bool isContinueTriggered;
  final String? targetRoute;

  const ChooseRideState({
    this.status = ChooseRideStatus.loading,
    this.tiers = const [],
    this.selectedTierId = 'sedan',
    this.appliedPromo,
    this.couponInput = 'WINTER50',
    this.promoInputError,
    this.qaScenario = QaPromoScenario.invalidCode,
    this.demoState = ChooseRideDemoState.collapsed,
    this.isInspectorMode = false,
    this.showPromoTermsModal = false,
    this.preference = const RidePreference(),
    this.paymentMethod = ChooseRideConfig.defaultPaymentTerminal,
    this.paymentMethodLabel = 'Personal · Visa 4022',
    this.routeText = 'West Campus ➔ 1st Ave S',
    this.routeAreaLabel = 'High Level Viaduct Area',
    this.distanceText = '7.4 km',
    this.destinationText = '501 1st Ave S',
    this.validitySeconds = 300,
    this.isExpiring = false,
    this.feedbackMessage,
    this.isContinueTriggered = false,
    this.targetRoute,
  });

  bool get isLoading => status == ChooseRideStatus.loading;
  bool get isPromoApplied => appliedPromo != null && appliedPromo!.isValid;
  bool get hasPromoError =>
      promoInputError != null && promoInputError!.isNotEmpty;

  RideOptionTier? get selectedTier {
    try {
      return tiers.firstWhere((t) => t.id == selectedTierId);
    } catch (_) {
      return tiers.isNotEmpty ? tiers.first : null;
    }
  }

  double get finalPrice {
    final tier = selectedTier;
    if (tier == null) return 0.0;
    return tier.totalFareCad;
  }

  double get subtotalCad {
    final tier = selectedTier;
    if (tier == null) return 0.0;
    return tier.baseFareCad;
  }

  double get gstCad {
    final tier = selectedTier;
    if (tier == null) return 0.0;
    return tier.gstCad;
  }

  double get discountAmountCad {
    return isPromoApplied ? (appliedPromo?.discountAmountCad ?? 0.0) : 0.0;
  }

  String get formattedFinalPrice => '\$${finalPrice.toStringAsFixed(2)} CAD';

  String get validityTimerText {
    final minutes = validitySeconds ~/ 60;
    final seconds = validitySeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  ChooseRideState copyWith({
    ChooseRideStatus? status,
    List<RideOptionTier>? tiers,
    String? selectedTierId,
    PromoCode? appliedPromo,
    bool clearPromo = false,
    String? couponInput,
    String? promoInputError,
    bool clearPromoError = false,
    QaPromoScenario? qaScenario,
    ChooseRideDemoState? demoState,
    bool? isInspectorMode,
    bool? showPromoTermsModal,
    RidePreference? preference,
    String? paymentMethod,
    String? paymentMethodLabel,
    String? routeText,
    String? routeAreaLabel,
    String? distanceText,
    String? destinationText,
    int? validitySeconds,
    bool? isExpiring,
    String? Function()? feedbackMessage,
    bool? isContinueTriggered,
    String? targetRoute,
  }) {
    return ChooseRideState(
      status: status ?? this.status,
      tiers: tiers ?? this.tiers,
      selectedTierId: selectedTierId ?? this.selectedTierId,
      appliedPromo: clearPromo ? null : (appliedPromo ?? this.appliedPromo),
      couponInput: couponInput ?? this.couponInput,
      promoInputError: clearPromoError
          ? null
          : (promoInputError ?? this.promoInputError),
      qaScenario: qaScenario ?? this.qaScenario,
      demoState: demoState ?? this.demoState,
      isInspectorMode: isInspectorMode ?? this.isInspectorMode,
      showPromoTermsModal: showPromoTermsModal ?? this.showPromoTermsModal,
      preference: preference ?? this.preference,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentMethodLabel: paymentMethodLabel ?? this.paymentMethodLabel,
      routeText: routeText ?? this.routeText,
      routeAreaLabel: routeAreaLabel ?? this.routeAreaLabel,
      distanceText: distanceText ?? this.distanceText,
      destinationText: destinationText ?? this.destinationText,
      validitySeconds: validitySeconds ?? this.validitySeconds,
      isExpiring: isExpiring ?? this.isExpiring,
      feedbackMessage: feedbackMessage != null
          ? feedbackMessage()
          : this.feedbackMessage,
      isContinueTriggered: isContinueTriggered ?? this.isContinueTriggered,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tiers,
        selectedTierId,
        appliedPromo,
        couponInput,
        promoInputError,
        qaScenario,
        demoState,
        isInspectorMode,
        showPromoTermsModal,
        preference,
        paymentMethod,
        paymentMethodLabel,
        routeText,
        routeAreaLabel,
        distanceText,
        destinationText,
        validitySeconds,
        isExpiring,
        feedbackMessage,
        isContinueTriggered,
        targetRoute,
      ];
}
