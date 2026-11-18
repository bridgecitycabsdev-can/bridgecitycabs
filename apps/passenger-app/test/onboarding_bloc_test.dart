import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/onboarding/onboarding.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  bool isCompleted = false;

  @override
  Future<bool> hasCompletedOnboarding() async => isCompleted;

  @override
  Future<void> markOnboardingCompleted() async {
    isCompleted = true;
  }

  @override
  Future<void> resetOnboarding() async {
    isCompleted = false;
  }
}

void main() {
  group('OnboardingBloc Tests', () {
    late FakeOnboardingRepository repository;
    late OnboardingBloc bloc;

    setUp(() {
      repository = FakeOnboardingRepository();
      bloc = OnboardingBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is OnboardingChooseRideState', () {
      expect(bloc.state, isA<OnboardingChooseRideState>());
      expect(bloc.state.pageIndex, 0);
      expect(bloc.state.isFirstStep, isTrue);
    });

    test('transitions through steps on OnboardingPageChanged', () {
      bloc.add(const OnboardingPageChanged(1));
      expectLater(
        bloc.stream,
        emits(isA<OnboardingRideAnywhereState>()),
      );

      bloc.add(const OnboardingPageChanged(2));
      expectLater(
        bloc.stream,
        emits(isA<OnboardingSafetySupportedState>()),
      );
    });

    test('advances step on OnboardingNextTapped', () async {
      bloc.add(const OnboardingNextTapped());
      await expectLater(
        bloc.stream,
        emits(isA<OnboardingRideAnywhereState>()),
      );

      bloc.add(const OnboardingNextTapped());
      await expectLater(
        bloc.stream,
        emits(isA<OnboardingSafetySupportedState>()),
      );
    });

    test('updates selected ride tier on OnboardingTierSelected', () async {
      final bigTier = RideTier.sampleTiers[1]; // 'Big'
      bloc.add(OnboardingTierSelected(bigTier));

      await expectLater(
        bloc.stream,
        emits(predicate<OnboardingState>((state) {
          return state.selectedTier.id == 'big';
        })),
      );
    });

    test('marks onboarding completed and navigates on OnboardingSkipTapped', () async {
      bloc.add(const OnboardingSkipTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<OnboardingState>((state) {
          return state is OnboardingNavigateState &&
              state.action == OnboardingAction.skipped &&
              state.targetRoute == '/phone';
        })),
      );

      expect(repository.isCompleted, isTrue);
    });

    test('marks onboarding completed and navigates on OnboardingGetStartedTapped', () async {
      bloc.add(const OnboardingGetStartedTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<OnboardingState>((state) {
          return state is OnboardingNavigateState &&
              state.action == OnboardingAction.getStarted &&
              state.targetRoute == '/phone';
        })),
      );

      expect(repository.isCompleted, isTrue);
    });

    test('navigates with signIn action on OnboardingSignInTapped', () async {
      bloc.add(const OnboardingSignInTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<OnboardingState>((state) {
          return state is OnboardingNavigateState &&
              state.action == OnboardingAction.signIn &&
              state.targetRoute == '/phone';
        })),
      );

      expect(repository.isCompleted, isTrue);
    });
  });
}
