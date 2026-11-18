import 'package:equatable/equatable.dart';

enum ReceiptPaymentType {
  cash,
  card,
}

class ReceiptFareBreakdown extends Equatable {
  final double baseSubtotal;
  final double gst;
  final double? discountAmount;
  final String? discountCode;
  final double totalAmount;
  final ReceiptPaymentType paymentType;
  final String? cardLast4;
  final String? cardBrand;
  final String paymentStatusText;

  const ReceiptFareBreakdown({
    this.baseSubtotal = 21.05,
    this.gst = 1.05,
    this.discountAmount,
    this.discountCode,
    this.totalAmount = 22.10,
    this.paymentType = ReceiptPaymentType.cash,
    this.cardLast4,
    this.cardBrand,
    this.paymentStatusText = 'Awaiting Driver',
  });

  bool get hasDiscount => discountAmount != null && discountAmount! > 0;
  bool get isCash => paymentType == ReceiptPaymentType.cash;
  bool get isCard => paymentType == ReceiptPaymentType.card;

  String get formattedSubtotal => '\$${baseSubtotal.toStringAsFixed(2)} CAD';
  String get formattedGst => '\$${gst.toStringAsFixed(2)} CAD';
  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)} CAD';
  String get formattedDiscount =>
      discountAmount != null ? '-\$${discountAmount!.toStringAsFixed(2)} CAD' : '';

  ReceiptFareBreakdown copyWith({
    double? baseSubtotal,
    double? gst,
    double? discountAmount,
    String? discountCode,
    double? totalAmount,
    ReceiptPaymentType? paymentType,
    String? cardLast4,
    String? cardBrand,
    String? paymentStatusText,
  }) {
    return ReceiptFareBreakdown(
      baseSubtotal: baseSubtotal ?? this.baseSubtotal,
      gst: gst ?? this.gst,
      discountAmount: discountAmount ?? this.discountAmount,
      discountCode: discountCode ?? this.discountCode,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentType: paymentType ?? this.paymentType,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardBrand: cardBrand ?? this.cardBrand,
      paymentStatusText: paymentStatusText ?? this.paymentStatusText,
    );
  }

  @override
  List<Object?> get props => [
        baseSubtotal,
        gst,
        discountAmount,
        discountCode,
        totalAmount,
        paymentType,
        cardLast4,
        cardBrand,
        paymentStatusText,
      ];
}
