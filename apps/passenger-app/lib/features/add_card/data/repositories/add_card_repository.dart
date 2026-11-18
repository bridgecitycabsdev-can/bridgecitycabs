import 'dart:async';
import '../models/add_card_models.dart';

abstract class AddCardRepository {
  Future<void> tokenizeCard(CardFormData form);
  Future<void> confirmBankAuthentication(String cardLast4);
  Future<void> submit3DSecureOtp({required String code});
  Future<void> refreshVerificationStatus(String cardLast4);
}

class MockAddCardRepository implements AddCardRepository {
  final Duration delay;
  final bool shouldDecline;
  final bool require3DSecure;
  final bool requirePendingVerification;

  MockAddCardRepository({
    this.delay = const Duration(milliseconds: 600),
    this.shouldDecline = false,
    this.require3DSecure = false,
    this.requirePendingVerification = false,
  });

  @override
  Future<void> tokenizeCard(CardFormData form) async {
    await Future.delayed(delay);
    if (shouldDecline) {
      throw Exception('Card declined by issuing bank.');
    }
  }

  @override
  Future<void> confirmBankAuthentication(String cardLast4) async {
    await Future.delayed(delay);
    if (shouldDecline) {
      throw Exception('Card declined by issuing bank.');
    }
  }

  @override
  Future<void> submit3DSecureOtp({required String code}) async {
    await Future.delayed(delay);
    if (code.length < 6) {
      throw Exception('Invalid verification code.');
    }
  }

  @override
  Future<void> refreshVerificationStatus(String cardLast4) async {
    await Future.delayed(delay);
  }
}
