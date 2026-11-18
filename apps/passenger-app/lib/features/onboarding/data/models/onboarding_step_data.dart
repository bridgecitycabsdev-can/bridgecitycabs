/// Data content model representing each step of the passenger onboarding journey.
class OnboardingStepData {
  final int index;
  final String categoryTag;
  final String title;
  final String description;
  final String headerLocation;
  final List<String> highlightTags;
  final bool isLastStep;

  const OnboardingStepData({
    required this.index,
    required this.categoryTag,
    required this.title,
    required this.description,
    required this.headerLocation,
    this.highlightTags = const [],
    this.isLastStep = false,
  });

  static const List<OnboardingStepData> steps = [
    // Step 1: Ride Options & Upfront Fares
    OnboardingStepData(
      index: 0,
      categoryTag: 'CHOOSE YOUR RIDE',
      title: 'Pick the ride that\nfits you.',
      description:
          'Choose Medium, Big or Premium, see the full fare upfront, and book in a few taps.',
      headerLocation: 'Lethbridge, AB',
      isLastStep: false,
    ),

    // Step 2: Instant, Scheduled & Intercity Airport Trips
    OnboardingStepData(
      index: 1,
      categoryTag: 'RIDE ANYWHERE',
      title: 'Now, later or city to\ncity.',
      description:
          'Book instantly, schedule ahead for airport trips and meetings, or go long distance between cities.',
      headerLocation: 'CABS • YQL',
      highlightTags: ['Fixed Rates', '24/7 Dispatch', 'YYC Flights'],
      isLastStep: false,
    ),

    // Step 3: Safety, Live Tracking & Local Dispatch Support
    OnboardingStepData(
      index: 2,
      categoryTag: 'SAFE AND SUPPORTED',
      title: "We've got your back,\n24/7.",
      description:
          'Track your driver live, reach our local support team anytime, and trigger one-touch SOS if you ever need immediate assistance in Lethbridge.',
      headerLocation: 'LETHBRIDGE',
      isLastStep: true,
    ),
  ];
}
