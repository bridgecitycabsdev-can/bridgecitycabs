import 'package:equatable/equatable.dart';
import '../data/models/driver_earnings_mock.dart';
import '../data/models/driver_onboarding_step.dart';
import '../data/models/driver_profile_compliance_mock.dart';
import '../data/models/driver_ride_request_mock.dart';

class DriverOnboardingState extends Equatable {
  final int currentIndex;
  final bool isSubmitting;
  final bool isCompleted;
  final bool navigateToPhone;
  final List<DriverOnboardingStepData> steps;
  final DriverRideRequestMock rideRequest;
  final DriverEarningsMock earnings;
  final DriverProfileComplianceMock profileCompliance;
  final String? feedbackMessage;

  const DriverOnboardingState({
    this.currentIndex = 0,
    this.isSubmitting = false,
    this.isCompleted = false,
    this.navigateToPhone = false,
    this.steps = DriverOnboardingStepData.steps,
    this.rideRequest = const DriverRideRequestMock(),
    this.earnings = const DriverEarningsMock(),
    this.profileCompliance = const DriverProfileComplianceMock(),
    this.feedbackMessage,
  });

  DriverOnboardingStepData get currentStep =>
      steps.isNotEmpty && currentIndex < steps.length
          ? steps[currentIndex]
          : DriverOnboardingStepData.steps.first;

  bool get isLastStep => currentIndex == steps.length - 1;

  DriverOnboardingState copyWith({
    int? currentIndex,
    bool? isSubmitting,
    bool? isCompleted,
    bool? navigateToPhone,
    List<DriverOnboardingStepData>? steps,
    DriverRideRequestMock? rideRequest,
    DriverEarningsMock? earnings,
    DriverProfileComplianceMock? profileCompliance,
    String? feedbackMessage,
  }) {
    return DriverOnboardingState(
      currentIndex: currentIndex ?? this.currentIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCompleted: isCompleted ?? this.isCompleted,
      navigateToPhone: navigateToPhone ?? this.navigateToPhone,
      steps: steps ?? this.steps,
      rideRequest: rideRequest ?? this.rideRequest,
      earnings: earnings ?? this.earnings,
      profileCompliance: profileCompliance ?? this.profileCompliance,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentIndex,
        isSubmitting,
        isCompleted,
        navigateToPhone,
        steps,
        rideRequest,
        earnings,
        profileCompliance,
        feedbackMessage,
      ];
}
