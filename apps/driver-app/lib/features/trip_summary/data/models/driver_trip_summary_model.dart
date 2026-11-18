import 'package:equatable/equatable.dart';
import 'driver_edge_state.dart';
import 'driver_fast_change_calc.dart';
import 'driver_rate_passenger_model.dart';

class DriverTripSummaryModel extends Equatable {
  final String tripId;
  final String paymentMethod; // 'CARD' or 'CASH'
  final String cardEnding;
  final String cardBrand;
  final String paymentProcessedVia;
  final String paymentStatusLabel;
  final bool isPaid;
  final String pickupAddress;
  final String pickupSecondary;
  final String pickupTime;
  final String dropoffAddress;
  final String dropoffSecondary;
  final String dropoffTime;
  final double distanceKm;
  final int durationMinutes;
  final int avgSpeedKmh;
  final String passengerName;
  final String zone;
  final String routeCorridor;
  final double grossMeteredFare;
  final double subtotalMeterFare;
  final double gstAlberta;
  final double fleetFeePercent;
  final double fleetFeeAmount;
  final double netPayout;
  final List<DriverFastChangeOption> changeOptions;
  final DriverRatePassengerModel ratingModel;
  final DriverEdgeStateType? activeEdgeState;
  final bool isCashCollected;
  final bool isReceiptSent;

  const DriverTripSummaryModel({
    this.tripId = 'BC-123456',
    this.paymentMethod = 'CARD',
    this.cardEnding = '•••• 8842',
    this.cardBrand = 'VISA',
    this.paymentProcessedVia = 'Stripe Fleet Sync',
    this.paymentStatusLabel = 'Pre-authorized & Captured',
    this.isPaid = true,
    this.pickupAddress = '440 University Dr W',
    this.pickupSecondary = 'Lethbridge West Campus',
    this.pickupTime = '6:21 PM',
    this.dropoffAddress = '501 1st Ave S',
    this.dropoffSecondary = 'Downtown Plaza Core',
    this.dropoffTime = '6:35 PM',
    this.distanceKm = 4.52,
    this.durationMinutes = 14,
    this.avgSpeedKmh = 38,
    this.passengerName = 'Alex M.',
    this.zone = 'Lethbridge Central Zone',
    this.routeCorridor = 'Lethbridge West Campus → Downtown Core',
    this.grossMeteredFare = 22.10,
    this.subtotalMeterFare = 21.05,
    this.gstAlberta = 1.05,
    this.fleetFeePercent = 15.0,
    this.fleetFeeAmount = 3.32,
    this.netPayout = 18.78,
    this.changeOptions = const [
      DriverFastChangeOption(tenderAmount: 25.0, fareAmount: 22.10),
      DriverFastChangeOption(tenderAmount: 30.0, fareAmount: 22.10),
    ],
    this.ratingModel = const DriverRatePassengerModel(),
    this.activeEdgeState,
    this.isCashCollected = false,
    this.isReceiptSent = true,
  });

  bool get isCard => paymentMethod.toUpperCase() == 'CARD';
  bool get isCash => paymentMethod.toUpperCase() == 'CASH';

  DriverTripSummaryModel copyWith({
    String? tripId,
    String? paymentMethod,
    String? cardEnding,
    String? cardBrand,
    String? paymentProcessedVia,
    String? paymentStatusLabel,
    bool? isPaid,
    String? pickupAddress,
    String? pickupSecondary,
    String? pickupTime,
    String? dropoffAddress,
    String? dropoffSecondary,
    String? dropoffTime,
    double? distanceKm,
    int? durationMinutes,
    int? avgSpeedKmh,
    String? passengerName,
    String? zone,
    String? routeCorridor,
    double? grossMeteredFare,
    double? subtotalMeterFare,
    double? gstAlberta,
    double? fleetFeePercent,
    double? fleetFeeAmount,
    double? netPayout,
    List<DriverFastChangeOption>? changeOptions,
    DriverRatePassengerModel? ratingModel,
    DriverEdgeStateType? activeEdgeState,
    bool? isCashCollected,
    bool? isReceiptSent,
  }) {
    return DriverTripSummaryModel(
      tripId: tripId ?? this.tripId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardEnding: cardEnding ?? this.cardEnding,
      cardBrand: cardBrand ?? this.cardBrand,
      paymentProcessedVia: paymentProcessedVia ?? this.paymentProcessedVia,
      paymentStatusLabel: paymentStatusLabel ?? this.paymentStatusLabel,
      isPaid: isPaid ?? this.isPaid,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupSecondary: pickupSecondary ?? this.pickupSecondary,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffSecondary: dropoffSecondary ?? this.dropoffSecondary,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      passengerName: passengerName ?? this.passengerName,
      zone: zone ?? this.zone,
      routeCorridor: routeCorridor ?? this.routeCorridor,
      grossMeteredFare: grossMeteredFare ?? this.grossMeteredFare,
      subtotalMeterFare: subtotalMeterFare ?? this.subtotalMeterFare,
      gstAlberta: gstAlberta ?? this.gstAlberta,
      fleetFeePercent: fleetFeePercent ?? this.fleetFeePercent,
      fleetFeeAmount: fleetFeeAmount ?? this.fleetFeeAmount,
      netPayout: netPayout ?? this.netPayout,
      changeOptions: changeOptions ?? this.changeOptions,
      ratingModel: ratingModel ?? this.ratingModel,
      activeEdgeState: activeEdgeState ?? this.activeEdgeState,
      isCashCollected: isCashCollected ?? this.isCashCollected,
      isReceiptSent: isReceiptSent ?? this.isReceiptSent,
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        paymentMethod,
        cardEnding,
        cardBrand,
        paymentProcessedVia,
        paymentStatusLabel,
        isPaid,
        pickupAddress,
        pickupSecondary,
        pickupTime,
        dropoffAddress,
        dropoffSecondary,
        dropoffTime,
        distanceKm,
        durationMinutes,
        avgSpeedKmh,
        passengerName,
        zone,
        routeCorridor,
        grossMeteredFare,
        subtotalMeterFare,
        gstAlberta,
        fleetFeePercent,
        fleetFeeAmount,
        netPayout,
        changeOptions,
        ratingModel,
        activeEdgeState,
        isCashCollected,
        isReceiptSent,
      ];
}
