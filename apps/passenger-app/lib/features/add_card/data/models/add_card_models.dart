import '../models/add_card_config.dart';

enum AddCardStatus {
  initial,
  tokenizing,
  confirmingBank,
  threeDSecureOtp,
  success,
  declined,
  verificationPending,
}

enum CardBrand {
  visa,
  mastercard,
  amex,
  unknown;

  String get displayName {
    switch (this) {
      case CardBrand.visa:
        return 'VISA';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.amex:
        return 'AMEX';
      case CardBrand.unknown:
        return 'CARD';
    }
  }
}

class CardFormData {
  final String cardNumber;
  final String expiry;
  final String cvc;
  final String postalCode;
  final String nameOnCard;
  final bool isDefault;

  const CardFormData({
    this.cardNumber = '',
    this.expiry = '',
    this.cvc = '',
    this.postalCode = 'T1K 4A8',
    this.nameOnCard = 'R. Vance',
    this.isDefault = true,
  });

  String get cleanCardNumber => cardNumber.replaceAll(' ', '');

  String get last4 {
    final clean = cleanCardNumber;
    if (clean.length >= 4) {
      return clean.substring(clean.length - 4);
    }
    return '4242';
  }

  CardBrand get detectedBrand {
    final clean = cleanCardNumber;
    if (clean.startsWith('4')) return CardBrand.visa;
    if (clean.startsWith('5') || clean.startsWith('2')) return CardBrand.mastercard;
    if (clean.startsWith('3')) return CardBrand.amex;
    return CardBrand.visa; // default to visa for tests/mock
  }

  bool get isCardNumberValid => cleanCardNumber.length >= 15;
  bool get isExpiryValid => expiry.length >= 4 && expiry.contains('/');
  bool get isCvcValid => cvc.length >= 3;
  bool get isPostalCodeValid => postalCode.trim().length >= 6;

  bool get isFormValid =>
      isCardNumberValid && isExpiryValid && isCvcValid && isPostalCodeValid;

  CardFormData copyWith({
    String? cardNumber,
    String? expiry,
    String? cvc,
    String? postalCode,
    String? nameOnCard,
    bool? isDefault,
  }) {
    return CardFormData(
      cardNumber: cardNumber ?? this.cardNumber,
      expiry: expiry ?? this.expiry,
      cvc: cvc ?? this.cvc,
      postalCode: postalCode ?? this.postalCode,
      nameOnCard: nameOnCard ?? this.nameOnCard,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class ThreeDSecureData {
  final String maskedPhone;
  final String code;
  final int expiresInSeconds;
  final String cardLast4;

  const ThreeDSecureData({
    this.maskedPhone = '(•••) •••-8921',
    this.code = '641',
    this.expiresInSeconds = 297,
    this.cardLast4 = '4242',
  });

  String get formattedExpiresIn {
    final minutes = expiresInSeconds ~/ 60;
    final seconds = expiresInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  ThreeDSecureData copyWith({
    String? maskedPhone,
    String? code,
    int? expiresInSeconds,
    String? cardLast4,
  }) {
    return ThreeDSecureData(
      maskedPhone: maskedPhone ?? this.maskedPhone,
      code: code ?? this.code,
      expiresInSeconds: expiresInSeconds ?? this.expiresInSeconds,
      cardLast4: cardLast4 ?? this.cardLast4,
    );
  }
}
