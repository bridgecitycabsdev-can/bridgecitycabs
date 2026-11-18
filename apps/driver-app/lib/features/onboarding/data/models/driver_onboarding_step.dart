import 'package:equatable/equatable.dart';

enum DriverOnboardingStep {
  getRides,
  earnMore,
  driveWithConfidence,
}

class DriverOnboardingStepData extends Equatable {
  final int index;
  final DriverOnboardingStep step;
  final String categoryTag;
  final String title;
  final String description;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final bool isLastStep;

  const DriverOnboardingStepData({
    required this.index,
    required this.step,
    required this.categoryTag,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    this.secondaryButtonText,
    required this.isLastStep,
  });

  static const List<DriverOnboardingStepData> steps = [
    DriverOnboardingStepData(
      index: 0,
      step: DriverOnboardingStep.getRides,
      categoryTag: 'GET RIDES',
      title: 'Go online, get\nrequests.',
      description:
          'Switch to Active and ride requests find you. See the route, distance and fare before you accept.',
      primaryButtonText: '',
      secondaryButtonText: null,
      isLastStep: false,
    ),
    DriverOnboardingStepData(
      index: 1,
      step: DriverOnboardingStep.earnMore,
      categoryTag: 'EARN MORE',
      title: 'Track every dollar you earn.',
      description:
          "Check today's earnings, rides and distance, and open your weekly statements any time.",
      primaryButtonText: '',
      secondaryButtonText: null,
      isLastStep: false,
    ),
    DriverOnboardingStepData(
      index: 2,
      step: DriverOnboardingStep.driveWithConfidence,
      categoryTag: 'DRIVE WITH CONFIDENCE',
      title: 'Support when you\nneed it.',
      description:
          'Build your rating with great rides, get help from our team, and keep your documents up to date in one place.',
      primaryButtonText: 'Get started',
      secondaryButtonText: 'I already have an account',
      isLastStep: true,
    ),
  ];

  @override
  List<Object?> get props => [
        index,
        step,
        categoryTag,
        title,
        description,
        primaryButtonText,
        secondaryButtonText,
        isLastStep,
      ];
}
