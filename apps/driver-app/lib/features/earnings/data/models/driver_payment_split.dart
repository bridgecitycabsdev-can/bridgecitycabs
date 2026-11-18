import 'package:equatable/equatable.dart';

class DriverPaymentSplit extends Equatable {
  final double cashAmount;
  final int cashPercent;
  final double cardAmount;
  final int cardPercent;
  final int totalTrips;
  final String advisoryText;

  const DriverPaymentSplit({
    this.cashAmount = 29.43,
    this.cashPercent = 55,
    this.cardAmount = 24.50,
    this.cardPercent = 45,
    this.totalTrips = 2,
    this.advisoryText =
        'Cash is collected directly by you in cab. Card earnings are automatically deposited by Bridge City Cabs.',
  });

  DriverPaymentSplit copyWith({
    double? cashAmount,
    int? cashPercent,
    double? cardAmount,
    int? cardPercent,
    int? totalTrips,
    String? advisoryText,
  }) {
    return DriverPaymentSplit(
      cashAmount: cashAmount ?? this.cashAmount,
      cashPercent: cashPercent ?? this.cashPercent,
      cardAmount: cardAmount ?? this.cardAmount,
      cardPercent: cardPercent ?? this.cardPercent,
      totalTrips: totalTrips ?? this.totalTrips,
      advisoryText: advisoryText ?? this.advisoryText,
    );
  }

  @override
  List<Object?> get props => [
    cashAmount,
    cashPercent,
    cardAmount,
    cardPercent,
    totalTrips,
    advisoryText,
  ];
}
