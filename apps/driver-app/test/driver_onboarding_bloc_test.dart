import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/onboarding/onboarding.dart';

class TestDriverOnboardingRepository implements DriverOnboardingRepository {
  final bool shouldSucceed;

  TestDriverOnboardingRepository({this.shouldSucceed = true});

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
  Future<bool> setupDispatch() async => shouldSucceed;
}

void main() {
  group('DriverOnboardingBloc Tests', () {
    test('initial state has index 0, not submitting and default steps', () {
      final bloc = DriverOnboardingBloc(repository: TestDriverOnboardingRepository());
      expect(bloc.state.currentIndex, 0);
      expect(bloc.state.isSubmitting, isFalse);
      expect(bloc.state.isCompleted, isFalse);
      expect(bloc.state.navigateToPhone, isFalse);
      expect(bloc.state.steps.length, 3);
    });

    test('started event initializes with provided index and mocks', () {
      final bloc = DriverOnboardingBloc(repository: TestDriverOnboardingRepository());
      bloc.add(const DriverOnboardingStarted(initialIndex: 1));

      expectLater(
        bloc.stream,
        emits(predicate<DriverOnboardingState>(
          (s) => s.currentIndex == 1 && s.steps.length == 3,
        )),
      );
    });

    test('page changed event updates currentIndex', () {
      final bloc = DriverOnboardingBloc(repository: TestDriverOnboardingRepository());
      bloc.add(const DriverOnboardingPageChanged(2));

      expectLater(
        bloc.stream,
        emits(predicate<DriverOnboardingState>((s) => s.currentIndex == 2)),
      );
    });

    test('next tapped event increments currentIndex until last step', () async {
      final bloc = DriverOnboardingBloc(repository: TestDriverOnboardingRepository());

      bloc.add(const DriverOnboardingNextTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<DriverOnboardingState>((s) => s.currentIndex == 1)),
      );

      bloc.add(const DriverOnboardingNextTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<DriverOnboardingState>((s) => s.currentIndex == 2)),
      );

      // Tapping next on last step does not exceed bounds
      bloc.add(const DriverOnboardingNextTapped());
      expect(bloc.state.currentIndex, 2);
    });

    test('skip tapped triggers navigateToPhone', () {
      final bloc = DriverOnboardingBloc(repository: TestDriverOnboardingRepository());
      bloc.add(const DriverOnboardingSkipTapped());

      expectLater(
        bloc.stream,
        emits(predicate<DriverOnboardingState>(
          (s) => s.navigateToPhone == true && s.feedbackMessage != null,
        )),
      );
    });

    test('login tapped triggers navigateToPhone', () {
      final bloc = DriverOnboardingBloc(repository: TestDriverOnboardingRepository());
      bloc.add(const DriverOnboardingLoginTapped());

      expectLater(
        bloc.stream,
        emits(predicate<DriverOnboardingState>(
          (s) => s.navigateToPhone == true && s.feedbackMessage != null,
        )),
      );
    });

    test('get started tapped emits submitting then completes successfully', () async {
      final bloc = DriverOnboardingBloc(
        repository: TestDriverOnboardingRepository(shouldSucceed: true),
      );

      bloc.add(const DriverOnboardingGetStartedTapped());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverOnboardingState>((s) => s.isSubmitting == true),
          predicate<DriverOnboardingState>((s) =>
              s.isSubmitting == false &&
              s.isCompleted == true &&
              s.navigateToPhone == true),
        ]),
      );
    });

    test('step switched event sets target index and submitting flag', () {
      final bloc = DriverOnboardingBloc(repository: TestDriverOnboardingRepository());

      bloc.add(const DriverOnboardingStepSwitched(2, isSubmitting: true));

      expectLater(
        bloc.stream,
        emits(predicate<DriverOnboardingState>(
          (s) => s.currentIndex == 2 && s.isSubmitting == true,
        )),
      );
    });
  });
}
