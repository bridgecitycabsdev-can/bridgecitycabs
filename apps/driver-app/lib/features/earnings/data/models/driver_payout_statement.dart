import 'package:equatable/equatable.dart';

class StatementTripItem extends Equatable {
  final String id;
  final String timestampText;
  final String paymentType;
  final String pickupAddress;
  final String dropoffAddress;
  final double fareCad;

  const StatementTripItem({
    required this.id,
    required this.timestampText,
    required this.paymentType,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.fareCad,
  });

  @override
  List<Object?> get props => [
    id,
    timestampText,
    paymentType,
    pickupAddress,
    dropoffAddress,
    fareCad,
  ];
}

class DriverPayoutStatement extends Equatable {
  final String id;
  final String periodLabel;
  final double netPayout;
  final String statusLabel;
  final String? paidDateText;
  final String bankAccountText;
  final double grossFares;
  final double tips;
  final double platformFee;
  final double taxRemitted;
  final double cashCollectedByDriver;
  final double cardDisbursed;
  final int tripCount;
  final List<StatementTripItem> trips;

  const DriverPayoutStatement({
    this.id = 'stmt_jun_30',
    this.periodLabel = '16 Jun – 30 Jun, 2024',
    this.netPayout = 341.49,
    this.statusLabel = 'PAID',
    this.paidDateText = 'Paid on Jul 03, 2024',
    this.bankAccountText = 'Deposited to RBC Royal Bank •••• 4821',
    this.grossFares = 392.50,
    this.tips = 18.00,
    this.platformFee = -58.88,
    this.taxRemitted = -10.13,
    this.cashCollectedByDriver = 112.50,
    this.cardDisbursed = 228.99,
    this.tripCount = 12,
    this.trips = const [
      StatementTripItem(
        id: 'trip_1',
        timestampText: 'Fri, 28 Jun • 10:14 PM',
        paymentType: 'Card',
        pickupAddress: '440 University Dr W',
        dropoffAddress: '501 1st Ave S',
        fareCad: 24.50,
      ),
      StatementTripItem(
        id: 'trip_2',
        timestampText: 'Fri, 28 Jun • 08:30 PM',
        paymentType: 'Cash',
        pickupAddress: 'Park Place Mall',
        dropoffAddress: 'Scenic Dr S',
        fareCad: 18.00,
      ),
      StatementTripItem(
        id: 'trip_3',
        timestampText: 'Thu, 27 Jun • 03:15 PM',
        paymentType: 'Card',
        pickupAddress: 'Lethbridge Airport (YQL)',
        dropoffAddress: 'Downtown',
        fareCad: 38.20,
      ),
      StatementTripItem(
        id: 'trip_4',
        timestampText: 'Wed, 26 Jun • 11:45 AM',
        paymentType: 'Cash',
        pickupAddress: 'Senator Buchanan',
        dropoffAddress: 'Henderson Lake',
        fareCad: 15.80,
      ),
    ],
  });

  DriverPayoutStatement copyWith({
    String? id,
    String? periodLabel,
    double? netPayout,
    String? statusLabel,
    String? paidDateText,
    String? bankAccountText,
    double? grossFares,
    double? tips,
    double? platformFee,
    double? taxRemitted,
    double? cashCollectedByDriver,
    double? cardDisbursed,
    int? tripCount,
    List<StatementTripItem>? trips,
  }) {
    return DriverPayoutStatement(
      id: id ?? this.id,
      periodLabel: periodLabel ?? this.periodLabel,
      netPayout: netPayout ?? this.netPayout,
      statusLabel: statusLabel ?? this.statusLabel,
      paidDateText: paidDateText ?? this.paidDateText,
      bankAccountText: bankAccountText ?? this.bankAccountText,
      grossFares: grossFares ?? this.grossFares,
      tips: tips ?? this.tips,
      platformFee: platformFee ?? this.platformFee,
      taxRemitted: taxRemitted ?? this.taxRemitted,
      cashCollectedByDriver:
          cashCollectedByDriver ?? this.cashCollectedByDriver,
      cardDisbursed: cardDisbursed ?? this.cardDisbursed,
      tripCount: tripCount ?? this.tripCount,
      trips: trips ?? this.trips,
    );
  }

  @override
  List<Object?> get props => [
    id,
    periodLabel,
    netPayout,
    statusLabel,
    paidDateText,
    bankAccountText,
    grossFares,
    tips,
    platformFee,
    taxRemitted,
    cashCollectedByDriver,
    cardDisbursed,
    tripCount,
    trips,
  ];
}
