import 'package:equatable/equatable.dart';

abstract class DriverOnboardingEvent extends Equatable {
  const DriverOnboardingEvent();

  @override
  List<Object?> get props => [];
}

class DriverOnboardingStarted extends DriverOnboardingEvent {
  final int initialIndex;

  const DriverOnboardingStarted({this.initialIndex = 0});

  @override
  List<Object?> get props => [initialIndex];
}

class DriverOnboardingPageChanged extends DriverOnboardingEvent {
  final int index;

  const DriverOnboardingPageChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class DriverOnboardingNextTapped extends DriverOnboardingEvent {
  const DriverOnboardingNextTapped();
}

class DriverOnboardingSkipTapped extends DriverOnboardingEvent {
  const DriverOnboardingSkipTapped();
}

class DriverOnboardingGetStartedTapped extends DriverOnboardingEvent {
  const DriverOnboardingGetStartedTapped();
}

class DriverOnboardingLoginTapped extends DriverOnboardingEvent {
  const DriverOnboardingLoginTapped();
}

class DriverOnboardingStepSwitched extends DriverOnboardingEvent {
  final int targetIndex;
  final bool isSubmitting;

  const DriverOnboardingStepSwitched(
    this.targetIndex, {
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [targetIndex, isSubmitting];
}
