import 'package:equatable/equatable.dart';

class DayBarValue extends Equatable {
  final String day;
  final double amount;
  final double normalizedHeight; // 0.0 to 1.0
  final bool isHighlight;

  const DayBarValue({
    required this.day,
    required this.amount,
    required this.normalizedHeight,
    this.isHighlight = false,
  });

  @override
  List<Object?> get props => [day, amount, normalizedHeight, isHighlight];
}

class DriverEarningsMock extends Equatable {
  final double todayTotal;
  final int tripCount;
  final String onlineDuration;
  final double totalKm;
  final List<DayBarValue> weekBars;
  final String currentDepositRange;
  final double currentDepositAmount;
  final String previousDepositRange;
  final double previousDepositAmount;

  const DriverEarningsMock({
    this.todayTotal = 148.60,
    this.tripCount = 8,
    this.onlineDuration = '4h 15m Online',
    this.totalKm = 64.2,
    this.currentDepositRange = 'May 26 - Jun 01',
    this.currentDepositAmount = 1084.50,
    this.previousDepositRange = 'May 19 - May 25',
    this.previousDepositAmount = 942.10,
    this.weekBars = const [
      DayBarValue(day: 'M', amount: 20.0, normalizedHeight: 0.25),
      DayBarValue(day: 'T', amount: 25.0, normalizedHeight: 0.30),
      DayBarValue(day: 'W', amount: 22.0, normalizedHeight: 0.27),
      DayBarValue(day: 'T', amount: 48.0, normalizedHeight: 0.45),
      DayBarValue(day: 'F', amount: 110.0, normalizedHeight: 0.78, isHighlight: true),
      DayBarValue(day: 'S', amount: 148.60, normalizedHeight: 0.95, isHighlight: true),
      DayBarValue(day: 'S', amount: 95.0, normalizedHeight: 0.65, isHighlight: true),
    ],
  });

  @override
  List<Object?> get props => [
        todayTotal,
        tripCount,
        onlineDuration,
        totalKm,
        weekBars,
        currentDepositRange,
        currentDepositAmount,
        previousDepositRange,
        previousDepositAmount,
      ];
}
