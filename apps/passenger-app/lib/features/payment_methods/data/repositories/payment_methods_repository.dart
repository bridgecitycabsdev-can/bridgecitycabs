import 'dart:async';
import '../models/payment_card_model.dart';
import '../models/payment_methods_config.dart';

abstract class PaymentMethodsRepository {
  Future<List<PaymentCard>> fetchCards();
  Future<void> setDefaultCard(String cardId);
  Future<void> removeCard(String cardId);
  Future<PaymentCard> addCard({
    required CardBrand brand,
    required String last4,
    required String expiry,
  });
}

class MockPaymentMethodsRepository implements PaymentMethodsRepository {
  final Duration delay;
  final bool shouldFail;
  final List<PaymentCard> _cards;

  MockPaymentMethodsRepository({
    this.delay = const Duration(milliseconds: 600),
    this.shouldFail = false,
    List<PaymentCard>? initialCards,
  }) : _cards = List<PaymentCard>.from(initialCards ?? PaymentMethodsConfig.mockCards);

  @override
  Future<List<PaymentCard>> fetchCards() async {
    await Future.delayed(delay);
    if (shouldFail) {
      throw Exception('Failed to load saved payment methods.');
    }
    return List.unmodifiable(_cards);
  }

  @override
  Future<void> setDefaultCard(String cardId) async {
    await Future.delayed(delay);
    if (shouldFail) {
      throw Exception(PaymentMethodsConfig.defaultUpdateErrorMessage);
    }
    for (int i = 0; i < _cards.length; i++) {
      final card = _cards[i];
      _cards[i] = card.copyWith(isDefault: card.id == cardId);
    }
  }

  @override
  Future<void> removeCard(String cardId) async {
    await Future.delayed(delay);
    if (shouldFail) {
      throw Exception('Failed to remove card from Bridge City account.');
    }
    _cards.removeWhere((c) => c.id == cardId);
    if (_cards.isNotEmpty && !_cards.any((c) => c.isDefault)) {
      _cards[0] = _cards[0].copyWith(isDefault: true);
    }
  }

  @override
  Future<PaymentCard> addCard({
    required CardBrand brand,
    required String last4,
    required String expiry,
  }) async {
    await Future.delayed(delay);
    if (shouldFail) {
      throw Exception('Failed to tokenize and save card with Stripe.');
    }
    final newCard = PaymentCard(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      brand: brand,
      last4: last4,
      expiry: expiry,
      isDefault: _cards.isEmpty,
    );
    _cards.add(newCard);
    return newCard;
  }
}
