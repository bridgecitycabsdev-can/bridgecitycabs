import 'dart:async';
import '../models/card_auth_config.dart';
import '../models/card_auth_model.dart';

abstract class CardAuthRepository {
  Future<bool> initiate3dsChallenge({
    required String paymentMethodId,
    required double amountCad,
  });
  Future<CardAuthStage> checkChallengeStatus({required String challengeId});
  Future<List<AuthPaymentMethod>> getAvailablePaymentMethods();
  Future<bool> retryPaymentWithMethod({
    required String paymentMethodId,
    required double amountCad,
  });
}

class MockCardAuthRepository implements CardAuthRepository {
  final Duration delay;
  final bool simulateDecline;

  MockCardAuthRepository({
    this.delay = const Duration(milliseconds: 40),
    this.simulateDecline = false,
  });

  @override
  Future<bool> initiate3dsChallenge({
    required String paymentMethodId,
    required double amountCad,
  }) async {
    await Future.delayed(delay);
    return !simulateDecline;
  }

  @override
  Future<CardAuthStage> checkChallengeStatus({
    required String challengeId,
  }) async {
    await Future.delayed(delay);
    if (simulateDecline) {
      return CardAuthStage.declined;
    }
    return CardAuthStage.verified;
  }

  @override
  Future<List<AuthPaymentMethod>> getAvailablePaymentMethods() async {
    await Future.delayed(delay);
    return List.from(CardAuthConfig.mockMethods);
  }

  @override
  Future<bool> retryPaymentWithMethod({
    required String paymentMethodId,
    required double amountCad,
  }) async {
    await Future.delayed(delay);
    return true;
  }
}
