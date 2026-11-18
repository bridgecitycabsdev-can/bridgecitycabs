enum PaymentMethodsStatus {
  loading,
  loaded,
  updatingDefault,
  removingCard,
  error,
}

enum CardBrand {
  visa,
  mastercard,
  amex,
  discover,
  unknown;

  String get displayName {
    switch (this) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.amex:
        return 'American Express';
      case CardBrand.discover:
        return 'Discover';
      case CardBrand.unknown:
        return 'Card';
    }
  }
}

enum SelectedPaymentType {
  cash,
  card,
}

class PaymentCard {
  final String id;
  final CardBrand brand;
  final String last4;
  final String expiry;
  final bool isDefault;
  final String? cardholderName;

  const PaymentCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    this.isDefault = false,
    this.cardholderName,
  });

  String get formattedTitle => '${brand.displayName} •••• $last4';
  String get formattedExpiry => 'Expires $expiry';

  PaymentCard copyWith({
    String? id,
    CardBrand? brand,
    String? last4,
    String? expiry,
    bool? isDefault,
    String? cardholderName,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
      cardholderName: cardholderName ?? this.cardholderName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentCard && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
