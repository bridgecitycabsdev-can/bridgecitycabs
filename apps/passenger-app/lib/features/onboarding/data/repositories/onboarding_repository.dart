import 'dart:async';
import 'package:bridgecabs_core/bridgecabs_core.dart';

abstract class OnboardingRepository {
  /// Checks whether the user has previously completed the onboarding flow.
  Future<bool> hasCompletedOnboarding();

  /// Persists that the user has completed or skipped onboarding.
  Future<void> markOnboardingCompleted();

  /// Clears the onboarding completion flag (e.g. for testing or logout).
  Future<void> resetOnboarding();
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  static const String _onboardingKey = 'passenger_onboarding_completed_v1';
  final SecureStore _secureStore;

  OnboardingRepositoryImpl({SecureStore? secureStore})
      : _secureStore = secureStore ?? FlutterSecureStore();

  @override
  Future<bool> hasCompletedOnboarding() async {
    final value = await _secureStore.read(_onboardingKey);
    return value == 'true';
  }

  @override
  Future<void> markOnboardingCompleted() async {
    await _secureStore.write(_onboardingKey, 'true');
  }

  @override
  Future<void> resetOnboarding() async {
    await _secureStore.delete(_onboardingKey);
  }
}
