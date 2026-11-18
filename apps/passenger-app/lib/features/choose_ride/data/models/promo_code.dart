import 'package:equatable/equatable.dart';

class PromoCode extends Equatable {
  final String code;
  final String description;
  final double discountAmountCad;
  final bool isValid;
  final String? errorMessage;

  const PromoCode({
    required this.code,
    required this.description,
    required this.discountAmountCad,
    this.isValid = true,
    this.errorMessage,
  });

  static const PromoCode lethbridge3 = PromoCode(
    code: 'LETHBRIDGE3',
    description: '\$3.00 off City-Centre Trips',
    discountAmountCad: 3.00,
    isValid: true,
  );

  static const PromoCode invalidCode = PromoCode(
    code: 'SAVE50NOW',
    description: '',
    discountAmountCad: 0.0,
    isValid: false,
    errorMessage: 'Invalid or expired promo code. Check code and try again.',
  );

  @override
  List<Object?> get props => [
        code,
        description,
        discountAmountCad,
        isValid,
        errorMessage,
      ];
}
