import 'package:equatable/equatable.dart';
import 'driver_bank_details.dart';
import 'driver_earnings_period.dart';
import 'driver_payment_split.dart';
import 'driver_payout_statement.dart';

class DayEarningPoint extends Equatable {
  final String dayName;
  final double amount;
  final int rideCount;
  final bool isHighlighted;

  const DayEarningPoint({
    required this.dayName,
    required this.amount,
    this.rideCount = 0,
    this.isHighlighted = false,
  });

  @override
  List<Object?> get props => [dayName, amount, rideCount, isHighlighted];
}

class DriverEarningsSummary extends Equatable {
  final String driverName;
  final DriverEarningsPeriod period;
  final double totalEarnings;
  final double tips;
  final int totalRides;
  final double totalDistanceKm;
  final String zoneLabel;
  final String periodDateRange;
  final List<DayEarningPoint> dailyPoints;
  final DriverPaymentSplit split;
  final DriverBankDetails bankDetails;
  final List<DriverPayoutStatement> recentStatements;

  const DriverEarningsSummary({
    this.driverName = 'Shajil',
    this.period = DriverEarningsPeriod.thisWeek,
    this.totalEarnings = 53.93,
    this.tips = 0.00,
    this.totalRides = 2,
    this.totalDistanceKm = 11.0,
    this.zoneLabel = 'Lethbridge Zone',
    this.periodDateRange = 'Jun 24 - Jun 30',
    this.dailyPoints = const [
      DayEarningPoint(dayName: 'Mon', amount: 14.50, rideCount: 1),
      DayEarningPoint(dayName: 'Tue', amount: 24.30, rideCount: 1, isHighlighted: true),
      DayEarningPoint(dayName: 'Wed', amount: 15.13, rideCount: 0),
      DayEarningPoint(dayName: 'Thu', amount: 0.0, rideCount: 0),
      DayEarningPoint(dayName: 'Fri', amount: 0.0, rideCount: 0),
      DayEarningPoint(dayName: 'Sat', amount: 0.0, rideCount: 0),
      DayEarningPoint(dayName: 'Sun', amount: 0.0, rideCount: 0),
    ],
    this.split = const DriverPaymentSplit(),
    this.bankDetails = const DriverBankDetails(),
    this.recentStatements = const [
      DriverPayoutStatement(
        id: 'stmt_1',
        periodLabel: '16 Jun – 30 Jun',
        netPayout: 341.49,
        statusLabel: 'PAID',
        tripCount: 12,
      ),
      DriverPayoutStatement(
        id: 'stmt_2',
        periodLabel: '01 Jun – 15 Jun',
        netPayout: 218.70,
        statusLabel: 'PROCESSING',
        tripCount: 9,
      ),
    ],
  });

  DriverEarningsSummary copyWith({
    String? driverName,
    DriverEarningsPeriod? period,
    double? totalEarnings,
    double? tips,
    int? totalRides,
    double? totalDistanceKm,
    String? zoneLabel,
    String? periodDateRange,
    List<DayEarningPoint>? dailyPoints,
    DriverPaymentSplit? split,
    DriverBankDetails? bankDetails,
    List<DriverPayoutStatement>? recentStatements,
  }) {
    return DriverEarningsSummary(
      driverName: driverName ?? this.driverName,
      period: period ?? this.period,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      tips: tips ?? this.tips,
      totalRides: totalRides ?? this.totalRides,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      zoneLabel: zoneLabel ?? this.zoneLabel,
      periodDateRange: periodDateRange ?? this.periodDateRange,
      dailyPoints: dailyPoints ?? this.dailyPoints,
      split: split ?? this.split,
      bankDetails: bankDetails ?? this.bankDetails,
      recentStatements: recentStatements ?? this.recentStatements,
    );
  }

  @override
  List<Object?> get props => [
    driverName,
    period,
    totalEarnings,
    tips,
    totalRides,
    totalDistanceKm,
    zoneLabel,
    periodDateRange,
    dailyPoints,
    split,
    bankDetails,
    recentStatements,
  ];
}
