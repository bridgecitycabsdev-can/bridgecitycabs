import 'package:equatable/equatable.dart';
import '../../data/models/onboarding_step_data.dart';
import '../../data/models/ride_tier.dart';

/// Navigation target when onboarding concludes.
enum OnboardingAction {
  none,
  getStarted,
  signIn,
  skipped,
}

/// Base state for Onboarding.
abstract class OnboardingState extends Equatable {
  final int pageIndex;
  final RideTier selectedTier;
  final OnboardingAction action;
  final String? targetRoute;

  const OnboardingState({
    required this.pageIndex,
    required this.selectedTier,
    this.action = OnboardingAction.none,
    this.targetRoute,
  });

  bool get isFirstStep => pageIndex == 0;
  bool get isSecondStep => pageIndex == 1;
  bool get isLastStep => pageIndex == 2;
  bool get shouldNavigate => targetRoute != null;

  OnboardingStepData get currentStepData =>
      OnboardingStepData.steps[pageIndex.clamp(0, OnboardingStepData.steps.length - 1)];

  @override
  List<Object?> get props => [pageIndex, selectedTier, action, targetRoute];
}

/// Screen 1 (First uploaded screenshot):
/// - Category: "● CHOOSE YOUR RIDE"
/// - Title: "Pick the ride that fits you."
/// - Description: "Choose Medium, Big or Premium, see the full fare upfront, and book in a few taps."
/// - Floating ride tier options (Medium, Big, Premium)
/// - "Guaranteed Upfront Fare • $14.20 CAD" pill
/// - First dot active, circular next button
class OnboardingChooseRideState extends OnboardingState {
  const OnboardingChooseRideState({
    super.selectedTier = RideTier.defaultTier,
    super.action = OnboardingAction.none,
  }) : super(pageIndex: 0);
}

/// Screen 2 (Second uploaded screenshot):
/// - Category: "● RIDE ANYWHERE"
/// - Title: "Now, later or city to city."
/// - Description: "Book instantly, schedule ahead for airport trips and meetings, or go long distance between cities."
/// - Overlays: "Schedule Ahead (7:30 AM Lethbridge Airport)" & "HWY 4 YQL -> YYC / Coaldale"
/// - Feature tags: "✓ Fixed Rates", "✓ 24/7 Dispatch", "✓ YYC Flights"
/// - Second dot active, circular next button
class OnboardingRideAnywhereState extends OnboardingState {
  const OnboardingRideAnywhereState({
    super.selectedTier = RideTier.defaultTier,
    super.action = OnboardingAction.none,
  }) : super(pageIndex: 1);
}

/// Screen 3 (Third uploaded screenshot):
/// - Category: "SAFE AND SUPPORTED"
/// - Title: "We've got your back, 24/7."
/// - Description: "Track your driver live, reach our local support team anytime, and trigger one-touch SOS if you ever need immediate assistance in Lethbridge."
/// - Overlays: "SECURE" badge, "SOS Signal • Lethbridge 911 Link", "24/7 Dispatch", "Share Trip Live"
/// - Third dot active
/// - Primary: "Get started →" full-width button
/// - Secondary: "I already have an account" button
class OnboardingSafetySupportedState extends OnboardingState {
  const OnboardingSafetySupportedState({
    super.selectedTier = RideTier.defaultTier,
    super.action = OnboardingAction.none,
  }) : super(pageIndex: 2);
}

/// Terminal State: Dispatched when user finishes, skips, or chooses sign-in.
class OnboardingNavigateState extends OnboardingState {
  const OnboardingNavigateState({
    required super.pageIndex,
    required super.selectedTier,
    required super.action,
    required String targetRoute,
  }) : super(targetRoute: targetRoute);
}
