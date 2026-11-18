import '../models/driver_onboarding_step.dart';
import '../models/driver_ride_request_mock.dart';
import '../models/driver_earnings_mock.dart';
import '../models/driver_profile_compliance_mock.dart';

abstract class DriverOnboardingRepository {
  List<DriverOnboardingStepData> getSteps();
  DriverRideRequestMock getRideRequestMock();
  DriverEarningsMock getEarningsMock();
  DriverProfileComplianceMock getProfileComplianceMock();
  Future<bool> setupDispatch();
}

class MockDriverOnboardingRepository implements DriverOnboardingRepository {
  @override
  List<DriverOnboardingStepData> getSteps() => DriverOnboardingStepData.steps;

  @override
  DriverRideRequestMock getRideRequestMock() => const DriverRideRequestMock();

  @override
  DriverEarningsMock getEarningsMock() => const DriverEarningsMock();

  @override
  DriverProfileComplianceMock getProfileComplianceMock() =>
      const DriverProfileComplianceMock();

  @override
  Future<bool> setupDispatch() async {
    // Simulate network delay for setting up dispatch
    await Future.delayed(const Duration(milliseconds: 1500));
    return true;
  }
}
