import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/driver_onboarding_repository.dart';
import 'driver_onboarding_event.dart';
import 'driver_onboarding_state.dart';

class DriverOnboardingBloc
    extends Bloc<DriverOnboardingEvent, DriverOnboardingState> {
  final DriverOnboardingRepository repository;

  DriverOnboardingBloc({DriverOnboardingRepository? repository})
      : repository = repository ?? MockDriverOnboardingRepository(),
        super(const DriverOnboardingState()) {
    on<DriverOnboardingStarted>(_onStarted);
    on<DriverOnboardingPageChanged>(_onPageChanged);
    on<DriverOnboardingNextTapped>(_onNextTapped);
    on<DriverOnboardingSkipTapped>(_onSkipTapped);
    on<DriverOnboardingGetStartedTapped>(_onGetStartedTapped);
    on<DriverOnboardingLoginTapped>(_onLoginTapped);
    on<DriverOnboardingStepSwitched>(_onStepSwitched);
  }

  void _onStarted(
    DriverOnboardingStarted event,
    Emitter<DriverOnboardingState> emit,
  ) {
    emit(state.copyWith(
      currentIndex: event.initialIndex,
      steps: repository.getSteps(),
      rideRequest: repository.getRideRequestMock(),
      earnings: repository.getEarningsMock(),
      profileCompliance: repository.getProfileComplianceMock(),
      isSubmitting: false,
      isCompleted: false,
      navigateToPhone: false,
    ));
  }

  void _onPageChanged(
    DriverOnboardingPageChanged event,
    Emitter<DriverOnboardingState> emit,
  ) {
    emit(state.copyWith(
      currentIndex: event.index,
      isSubmitting: false,
    ));
  }

  void _onNextTapped(
    DriverOnboardingNextTapped event,
    Emitter<DriverOnboardingState> emit,
  ) {
    if (state.currentIndex < state.steps.length - 1) {
      emit(state.copyWith(
        currentIndex: state.currentIndex + 1,
        isSubmitting: false,
      ));
    }
  }

  void _onSkipTapped(
    DriverOnboardingSkipTapped event,
    Emitter<DriverOnboardingState> emit,
  ) {
    emit(state.copyWith(
      navigateToPhone: true,
      feedbackMessage: 'Skipping to driver sign-in...',
    ));
  }

  void _onLoginTapped(
    DriverOnboardingLoginTapped event,
    Emitter<DriverOnboardingState> emit,
  ) {
    emit(state.copyWith(
      navigateToPhone: true,
      feedbackMessage: 'Opening driver sign-in...',
    ));
  }

  Future<void> _onGetStartedTapped(
    DriverOnboardingGetStartedTapped event,
    Emitter<DriverOnboardingState> emit,
  ) async {
    emit(state.copyWith(
      isSubmitting: true,
      feedbackMessage: 'Setting up dispatch...',
    ));

    final success = await repository.setupDispatch();
    if (success) {
      emit(state.copyWith(
        isSubmitting: false,
        isCompleted: true,
        navigateToPhone: true,
        feedbackMessage: 'Dispatch configured. Welcome to Bridge City Cabs!',
      ));
    } else {
      emit(state.copyWith(
        isSubmitting: false,
        feedbackMessage: 'Failed to setup dispatch. Please try again.',
      ));
    }
  }

  void _onStepSwitched(
    DriverOnboardingStepSwitched event,
    Emitter<DriverOnboardingState> emit,
  ) {
    emit(state.copyWith(
      currentIndex: event.targetIndex.clamp(0, state.steps.length - 1),
      isSubmitting: event.isSubmitting,
    ));
  }
}
