import 'package:equatable/equatable.dart';

enum TripDetailSegment {
  completedCard,
  completedCash,
  inProgress;

  String get label {
    switch (this) {
      case TripDetailSegment.completedCard:
        return 'Completed (Card)';
      case TripDetailSegment.completedCash:
        return 'Completed (Cash)';
      case TripDetailSegment.inProgress:
        return 'In Progress';
    }
  }
}

enum PastTripQaScenario {
  completedCard,
  completedCash,
  cashPending,
  inProgress,
  disputedFare,
  cancelledWithFee,
  promoApplied,
  airportSurcharge,
  multiStopTrip;

  String get chipLabel {
    switch (this) {
      case PastTripQaScenario.completedCard:
        return '1. Completed (Card)';
      case PastTripQaScenario.completedCash:
        return '2. Completed (Cash)';
      case PastTripQaScenario.cashPending:
        return '3. Cash Pending';
      case PastTripQaScenario.inProgress:
        return '4. In Progress';
      case PastTripQaScenario.disputedFare:
        return '5. Disputed Fare';
      case PastTripQaScenario.cancelledWithFee:
        return '6. Cancelled (Fee)';
      case PastTripQaScenario.promoApplied:
        return '7. Promo Applied';
      case PastTripQaScenario.airportSurcharge:
        return '8. Airport Surcharge';
      case PastTripQaScenario.multiStopTrip:
        return '9. Multi-stop Trip';
    }
  }
}

class PastTripDetailModel extends Equatable {
  final String tripId;
  final String formattedId; // e.g. "BC-123456" or "Trip #BCC-84920"
  final String dateTimeLabel;
  final String statusLabel; // "Completed", "In Progress", "Cancelled"
  final bool isCompleted;
  final bool isInProgress;

  // Route & Corridor
  final String routeTag; // e.g. "Whoop-Up Dr Route"
  final String crossingLabel; // e.g. "Oldman River Crossing"
  final String pickupAddress;
  final String pickupSubtext;
  final String pickupTime;
  final String dropoffAddress;
  final String dropoffSubtext;
  final String dropoffTime;
  final double distanceKm;
  final int durationMinutes;
  final String weather; // e.g. "22°C Clear"

  // Driver & Vehicle
  final String driverName;
  final double driverRating;
  final String vehicleName; // e.g. "Toyota Camry SE"
  final bool isHybrid;
  final String licensePlate; // e.g. "ALBERTA BCF-402" or "Alta 93-R10"
  final String bylawLicense; // e.g. "Bylaw License #LTC-8841"
  final String driverPhotoUrl;

  // Fare Details (Lethbridge Metered Rate #1)
  final String rateType; // "Metered Rate #1"
  final double baseDropRateCad;
  final double distanceRateCad;
  final double waitingDelayCad;
  final double subtotalCad;
  final double gstCad;
  final double totalChargedCad;

  // Payment Status
  final String paymentMethodTitle; // e.g. "Visa •••• 4242" or "Cash Payment"
  final String paymentStatusText; // e.g. "Paid", "Auto-charged & Settled", "Awaiting Driver"
  final bool isCash;
  final bool isSettled;

  const PastTripDetailModel({
    required this.tripId,
    required this.formattedId,
    required this.dateTimeLabel,
    this.statusLabel = 'Completed',
    this.isCompleted = true,
    this.isInProgress = false,
    this.routeTag = 'Whoop-Up Dr Route',
    this.crossingLabel = 'Oldman River Crossing',
    required this.pickupAddress,
    this.pickupSubtext = '',
    required this.pickupTime,
    required this.dropoffAddress,
    this.dropoffSubtext = '',
    required this.dropoffTime,
    this.distanceKm = 4.52,
    this.durationMinutes = 12,
    this.weather = '22°C Clear',
    required this.driverName,
    this.driverRating = 4.9,
    required this.vehicleName,
    this.isHybrid = true,
    required this.licensePlate,
    this.bylawLicense = 'Bylaw License #LTC-8841 · Verified Prairie Operator',
    this.driverPhotoUrl = '',
    this.rateType = 'Metered Rate #1',
    this.baseDropRateCad = 4.50,
    this.distanceRateCad = 11.30,
    this.waitingDelayCad = 3.40,
    this.subtotalCad = 19.20,
    this.gstCad = 0.96,
    this.totalChargedCad = 20.16,
    this.paymentMethodTitle = 'Visa •••• 4242',
    this.paymentStatusText = 'Paid',
    this.isCash = false,
    this.isSettled = true,
  });

  String get formattedTotal => '\$${totalChargedCad.toStringAsFixed(2)} CAD';

  PastTripDetailModel copyWith({
    String? tripId,
    String? formattedId,
    String? dateTimeLabel,
    String? statusLabel,
    bool? isCompleted,
    bool? isInProgress,
    String? routeTag,
    String? crossingLabel,
    String? pickupAddress,
    String? pickupSubtext,
    String? pickupTime,
    String? dropoffAddress,
    String? dropoffSubtext,
    String? dropoffTime,
    double? distanceKm,
    int? durationMinutes,
    String? weather,
    String? driverName,
    double? driverRating,
    String? vehicleName,
    bool? isHybrid,
    String? licensePlate,
    String? bylawLicense,
    String? driverPhotoUrl,
    String? rateType,
    double? baseDropRateCad,
    double? distanceRateCad,
    double? waitingDelayCad,
    double? subtotalCad,
    double? gstCad,
    double? totalChargedCad,
    String? paymentMethodTitle,
    String? paymentStatusText,
    bool? isCash,
    bool? isSettled,
  }) {
    return PastTripDetailModel(
      tripId: tripId ?? this.tripId,
      formattedId: formattedId ?? this.formattedId,
      dateTimeLabel: dateTimeLabel ?? this.dateTimeLabel,
      statusLabel: statusLabel ?? this.statusLabel,
      isCompleted: isCompleted ?? this.isCompleted,
      isInProgress: isInProgress ?? this.isInProgress,
      routeTag: routeTag ?? this.routeTag,
      crossingLabel: crossingLabel ?? this.crossingLabel,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupSubtext: pickupSubtext ?? this.pickupSubtext,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffSubtext: dropoffSubtext ?? this.dropoffSubtext,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      weather: weather ?? this.weather,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      vehicleName: vehicleName ?? this.vehicleName,
      isHybrid: isHybrid ?? this.isHybrid,
      licensePlate: licensePlate ?? this.licensePlate,
      bylawLicense: bylawLicense ?? this.bylawLicense,
      driverPhotoUrl: driverPhotoUrl ?? this.driverPhotoUrl,
      rateType: rateType ?? this.rateType,
      baseDropRateCad: baseDropRateCad ?? this.baseDropRateCad,
      distanceRateCad: distanceRateCad ?? this.distanceRateCad,
      waitingDelayCad: waitingDelayCad ?? this.waitingDelayCad,
      subtotalCad: subtotalCad ?? this.subtotalCad,
      gstCad: gstCad ?? this.gstCad,
      totalChargedCad: totalChargedCad ?? this.totalChargedCad,
      paymentMethodTitle: paymentMethodTitle ?? this.paymentMethodTitle,
      paymentStatusText: paymentStatusText ?? this.paymentStatusText,
      isCash: isCash ?? this.isCash,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        formattedId,
        dateTimeLabel,
        statusLabel,
        isCompleted,
        isInProgress,
        routeTag,
        crossingLabel,
        pickupAddress,
        pickupSubtext,
        pickupTime,
        dropoffAddress,
        dropoffSubtext,
        dropoffTime,
        distanceKm,
        durationMinutes,
        weather,
        driverName,
        driverRating,
        vehicleName,
        isHybrid,
        licensePlate,
        bylawLicense,
        driverPhotoUrl,
        rateType,
        baseDropRateCad,
        distanceRateCad,
        waitingDelayCad,
        subtotalCad,
        gstCad,
        totalChargedCad,
        paymentMethodTitle,
        paymentStatusText,
        isCash,
        isSettled,
      ];
}
