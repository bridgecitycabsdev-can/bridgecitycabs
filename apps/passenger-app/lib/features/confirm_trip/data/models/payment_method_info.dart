import 'package:equatable/equatable.dart';

enum PaymentType {
  cash,
  card,
}

class PaymentMethodInfo extends Equatable {
  final PaymentType type;
  final String? cardLast4;
  final String? brand;
  final bool isLinked;
  final bool isDeclined;
  final String? expiry;
  final String? declinedReason;

  const PaymentMethodInfo({
    required this.type,
    this.cardLast4,
    this.brand,
    this.isLinked = true,
    this.isDeclined = false,
    this.expiry,
    this.declinedReason,
  });

  bool get isCash => type == PaymentType.cash;
  bool get isCard => type == PaymentType.card;

  String get displayName {
    if (isCash) return 'Cash';
    if (!isLinked) return 'No card linked';
    return '$brand •••• $cardLast4';
  }

  static const PaymentMethodInfo cash = PaymentMethodInfo(
    type: PaymentType.cash,
  );

  static const PaymentMethodInfo linkedVisa = PaymentMethodInfo(
    type: PaymentType.card,
    brand: 'Visa',
    cardLast4: '4242',
    expiry: '08/26',
    isLinked: true,
  );

  static const PaymentMethodInfo unlinkedCard = PaymentMethodInfo(
    type: PaymentType.card,
    isLinked: false,
  );

  static const PaymentMethodInfo declinedVisa = PaymentMethodInfo(
    type: PaymentType.card,
    brand: 'Visa',
    cardLast4: '4242',
    isLinked: true,
    isDeclined: true,
    declinedReason:
        'Issuer flagged card or insufficient funds. Retry, use Google Pay, or select cash.',
  );

  PaymentMethodInfo copyWith({
    PaymentType? type,
    String? cardLast4,
    String? brand,
    bool? isLinked,
    bool? isDeclined,
    String? expiry,
    String? declinedReason,
  }) {
    return PaymentMethodInfo(
      type: type ?? this.type,
      cardLast4: cardLast4 ?? this.cardLast4,
      brand: brand ?? this.brand,
      isLinked: isLinked ?? this.isLinked,
      isDeclined: isDeclined ?? this.isDeclined,
      expiry: expiry ?? this.expiry,
      declinedReason: declinedReason ?? this.declinedReason,
    );
  }

  @override
  List<Object?> get props => [
        type,
        cardLast4,
        brand,
        isLinked,
        isDeclined,
        expiry,
        declinedReason,
      ];
}
