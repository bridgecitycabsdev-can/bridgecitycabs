import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/ride_tier.dart';
import '../../data/repositories/onboarding_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingBloc({required OnboardingRepository repository})
      : _repository = repository,
        super(const OnboardingChooseRideState()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextTapped>(_onNextTapped);
    on<OnboardingPreviousTapped>(_onPreviousTapped);
    on<OnboardingSkipTapped>(_onSkipTapped);
    on<OnboardingGetStartedTapped>(_onGetStartedTapped);
    on<OnboardingSignInTapped>(_onSignInTapped);
    on<OnboardingTierSelected>(_onTierSelected);
  }

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    final completed = await _repository.hasCompletedOnboarding();
    if (completed) {
      emit(OnboardingNavigateState(
        pageIndex: 0,
        selectedTier: state.selectedTier,
        action: OnboardingAction.skipped,
        targetRoute: '/phone',
      ));
      return;
    }
    emit(OnboardingChooseRideState(selectedTier: state.selectedTier));
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(_stateForIndex(event.pageIndex, state.selectedTier));
  }

  void _onNextTapped(
    OnboardingNextTapped event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.pageIndex < 2) {
      final nextIndex = state.pageIndex + 1;
      emit(_stateForIndex(nextIndex, state.selectedTier));
    } else {
      add(const OnboardingGetStartedTapped());
    }
  }

  void _onPreviousTapped(
    OnboardingPreviousTapped event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.pageIndex > 0) {
      final prevIndex = state.pageIndex - 1;
      emit(_stateForIndex(prevIndex, state.selectedTier));
    }
  }

  Future<void> _onSkipTapped(
    OnboardingSkipTapped event,
    Emitter<OnboardingState> emit,
  ) async {
    await _repository.markOnboardingCompleted();
    emit(OnboardingNavigateState(
      pageIndex: state.pageIndex,
      selectedTier: state.selectedTier,
      action: OnboardingAction.skipped,
      targetRoute: '/phone',
    ));
  }

  Future<void> _onGetStartedTapped(
    OnboardingGetStartedTapped event,
    Emitter<OnboardingState> emit,
  ) async {
    await _repository.markOnboardingCompleted();
    emit(OnboardingNavigateState(
      pageIndex: 2,
      selectedTier: state.selectedTier,
      action: OnboardingAction.getStarted,
      targetRoute: '/phone',
    ));
  }

  Future<void> _onSignInTapped(
    OnboardingSignInTapped event,
    Emitter<OnboardingState> emit,
  ) async {
    await _repository.markOnboardingCompleted();
    emit(OnboardingNavigateState(
      pageIndex: 2,
      selectedTier: state.selectedTier,
      action: OnboardingAction.signIn,
      targetRoute: '/phone',
    ));
  }

  void _onTierSelected(
    OnboardingTierSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingChooseRideState(selectedTier: event.tier));
  }

  OnboardingState _stateForIndex(int index, RideTier tier) {
    switch (index) {
      case 0:
        return OnboardingChooseRideState(selectedTier: tier);
      case 1:
        return OnboardingRideAnywhereState(selectedTier: tier);
      case 2:
        return OnboardingSafetySupportedState(selectedTier: tier);
      default:
        return OnboardingChooseRideState(selectedTier: tier);
    }
  }
}
