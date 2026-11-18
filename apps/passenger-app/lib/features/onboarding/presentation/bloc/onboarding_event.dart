import 'package:equatable/equatable.dart';
import '../../data/models/ride_tier.dart';

/// Base class for all Onboarding events.
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the onboarding screen is mounted.
class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

/// Dispatched when the user swipes or transitions to a different page index.
class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

/// Dispatched when the user taps the circular red "→" advance button.
class OnboardingNextTapped extends OnboardingEvent {
  const OnboardingNextTapped();
}

/// Dispatched when the user taps the back navigation.
class OnboardingPreviousTapped extends OnboardingEvent {
  const OnboardingPreviousTapped();
}

/// Dispatched when the user taps the "Skip" pill in the top header.
class OnboardingSkipTapped extends OnboardingEvent {
  const OnboardingSkipTapped();
}

/// Dispatched when the user taps the primary "Get started →" button on the final step.
class OnboardingGetStartedTapped extends OnboardingEvent {
  const OnboardingGetStartedTapped();
}

/// Dispatched when the user taps "I already have an account" on the final step.
class OnboardingSignInTapped extends OnboardingEvent {
  const OnboardingSignInTapped();
}

/// Dispatched when the user selects a vehicle tier (Medium, Big, Premium) on Step 1.
class OnboardingTierSelected extends OnboardingEvent {
  final RideTier tier;

  const OnboardingTierSelected(this.tier);

  @override
  List<Object?> get props => [tier];
}
