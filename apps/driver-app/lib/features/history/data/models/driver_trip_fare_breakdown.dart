import 'package:equatable/equatable.dart';

class DriverTripFareBreakdown extends Equatable {
  final double grossMeterFare;
  final double passengerTip;
  final double platformFee;
  final double gstRemitted;
  final double netEarning;
  final String paymentMethodTitle;
  final String paymentMethodSubtitle;
  final String maskedCard;

  const DriverTripFareBreakdown({
    this.grossMeterFare = 21.50,
    this.passengerTip = 3.00,
    this.platformFee = -3.23,
    this.gstRemitted = -1.08,
    this.netEarning = 20.19,
    this.paymentMethodTitle = 'Card paid via app',
    this.paymentMethodSubtitle = 'Processed instantly',
    this.maskedCard = '•••• 8842',
  });

  DriverTripFareBreakdown copyWith({
    double? grossMeterFare,
    double? passengerTip,
    double? platformFee,
    double? gstRemitted,
    double? netEarning,
    String? paymentMethodTitle,
    String? paymentMethodSubtitle,
    String? maskedCard,
  }) {
    return DriverTripFareBreakdown(
      grossMeterFare: grossMeterFare ?? this.grossMeterFare,
      passengerTip: passengerTip ?? this.passengerTip,
      platformFee: platformFee ?? this.platformFee,
      gstRemitted: gstRemitted ?? this.gstRemitted,
      netEarning: netEarning ?? this.netEarning,
      paymentMethodTitle: paymentMethodTitle ?? this.paymentMethodTitle,
      paymentMethodSubtitle:
          paymentMethodSubtitle ?? this.paymentMethodSubtitle,
      maskedCard: maskedCard ?? this.maskedCard,
    );
  }

  @override
  List<Object?> get props => [
    grossMeterFare,
    passengerTip,
    platformFee,
    gstRemitted,
    netEarning,
    paymentMethodTitle,
    paymentMethodSubtitle,
    maskedCard,
  ];
}
