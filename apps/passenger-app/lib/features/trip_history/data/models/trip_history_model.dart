import 'package:equatable/equatable.dart';

enum TripPaymentScenario {
  cardPaid,
  cashPaid,
  cashPending;

  String get label {
    switch (this) {
      case TripPaymentScenario.cardPaid:
        return 'Completed (Card)';
      case TripPaymentScenario.cashPaid:
        return 'Completed (Cash)';
      case TripPaymentScenario.cashPending:
        return 'Cash Pending';
    }
  }

  String get qaLabel {
    switch (this) {
      case TripPaymentScenario.cardPaid:
        return '1. Card Paid';
      case TripPaymentScenario.cashPaid:
        return '2. Cash Paid';
      case TripPaymentScenario.cashPending:
        return '3. Cash Pending';
    }
  }
}

enum TripHistoryFilter {
  today('Today ●'),
  yesterday('Yesterday'),
  thisWeek('This week'),
  thisMonth('This month'),
  custom('Custom');

  final String displayName;
  const TripHistoryFilter(this.displayName);
}

class CustomDateRange extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const CustomDateRange({
    required this.startDate,
    required this.endDate,
  });

  int get dayCount => endDate.difference(startDate).inDays + 1;

  String get formattedRange {
    final startDay = startDate.day;
    final startMonth = _monthShort(startDate.month);
    final startYear = startDate.year;

    final endDay = endDate.day;
    final endMonth = _monthShort(endDate.month);
    final endYear = endDate.year;

    if (startYear == endYear) {
      return '$startDay $startMonth $startYear – $endDay $endMonth $endYear';
    }
    return '$startDay $startMonth $startYear – $endDay $endMonth $endYear';
  }

  static String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [startDate, endDate];
}

class TripSummaryData extends Equatable {
  final int totalTrips;
  final double totalSpentCad;

  const TripSummaryData({
    required this.totalTrips,
    required this.totalSpentCad,
  });

  String get formattedTotalSpent => '\$${totalSpentCad.toStringAsFixed(2)} CAD';

  @override
  List<Object?> get props => [totalTrips, totalSpentCad];
}

class GroupedTripDate extends Equatable {
  final String dateHeader; // e.g. "Sat, 22 Aug · 2 rides · $38.56 CAD"
  final String dateLabel;  // e.g. "Sat, 22 Aug"
  final int rideCount;
  final double totalCad;
  final List<TripRecord> trips;

  const GroupedTripDate({
    required this.dateHeader,
    required this.dateLabel,
    required this.rideCount,
    required this.totalCad,
    required this.trips,
  });

  @override
  List<Object?> get props => [dateHeader, dateLabel, rideCount, totalCad, trips];
}

class TripRecord extends Equatable {
  final String tripId;
  final String bookingTitle;
  final String serviceTier;
  final String dateTimeLabel;
  final String statusLabel; // 'COMPLETED' or 'CANCELED'
  final String pickupAddress;
  final String pickupSubtext;
  final String pickupTime;
  final String dropoffAddress;
  final String dropoffSubtext;
  final String dropoffTime;
  final String corridorLabel;
  final String routeTag;
  final double distanceKm;
  final int durationMinutes;
  final String weather;
  final String driverName;
  final double driverRating;
  final String driverVehicle;
  final String driverVehicleUnit;
  final bool isHybrid;
  final String licensePlate;
  final String bylawLicense;
  final TripPaymentScenario paymentScenario;
  final String paymentMethod;
  final String paymentStatus;
  final double baseRateCad;
  final double distanceRateCad;
  final double waitingTimeCad;
  final double subtotalCad;
  final double gstCad;
  final double totalCad;
  final String vehicleTypePill; // e.g. 'Camry SE', 'Sedan', 'SUV · Big', 'Standard'

  const TripRecord({
    required this.tripId,
    required this.bookingTitle,
    this.serviceTier = 'Priority Express',
    required this.dateTimeLabel,
    this.statusLabel = 'COMPLETED',
    required this.pickupAddress,
    this.pickupSubtext = '',
    required this.pickupTime,
    required this.dropoffAddress,
    this.dropoffSubtext = '',
    required this.dropoffTime,
    this.corridorLabel = 'Lethbridge Central Corridor',
    this.routeTag = 'Whoop-Up Dr Route',
    this.distanceKm = 4.52,
    this.durationMinutes = 12,
    this.weather = '22°C Clear',
    required this.driverName,
    this.driverRating = 4.9,
    required this.driverVehicle,
    this.driverVehicleUnit = 'Unit #44',
    this.isHybrid = true,
    required this.licensePlate,
    this.bylawLicense = '#LTC-8841',
    this.paymentScenario = TripPaymentScenario.cardPaid,
    this.paymentMethod = 'Visa •••• 4242',
    this.paymentStatus = 'Paid',
    this.baseRateCad = 4.50,
    this.distanceRateCad = 11.30,
    this.waitingTimeCad = 3.40,
    this.subtotalCad = 19.20,
    this.gstCad = 0.96,
    this.totalCad = 20.16,
    this.vehicleTypePill = 'Camry SE',
  });

  bool get isCompleted => statusLabel.toUpperCase() == 'COMPLETED';
  bool get isCanceled => statusLabel.toUpperCase() == 'CANCELED';
  String get formattedTotal => totalCad > 0 ? '\$${totalCad.toStringAsFixed(2)} CAD' : 'No charge';

  TripRecord copyWith({
    String? tripId,
    String? bookingTitle,
    String? serviceTier,
    String? dateTimeLabel,
    String? statusLabel,
    String? pickupAddress,
    String? pickupSubtext,
    String? pickupTime,
    String? dropoffAddress,
    String? dropoffSubtext,
    String? dropoffTime,
    String? corridorLabel,
    String? routeTag,
    double? distanceKm,
    int? durationMinutes,
    String? weather,
    String? driverName,
    double? driverRating,
    String? driverVehicle,
    String? driverVehicleUnit,
    bool? isHybrid,
    String? licensePlate,
    String? bylawLicense,
    TripPaymentScenario? paymentScenario,
    String? paymentMethod,
    String? paymentStatus,
    double? baseRateCad,
    double? distanceRateCad,
    double? waitingTimeCad,
    double? subtotalCad,
    double? gstCad,
    double? totalCad,
    String? vehicleTypePill,
  }) {
    return TripRecord(
      tripId: tripId ?? this.tripId,
      bookingTitle: bookingTitle ?? this.bookingTitle,
      serviceTier: serviceTier ?? this.serviceTier,
      dateTimeLabel: dateTimeLabel ?? this.dateTimeLabel,
      statusLabel: statusLabel ?? this.statusLabel,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupSubtext: pickupSubtext ?? this.pickupSubtext,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffSubtext: dropoffSubtext ?? this.dropoffSubtext,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      corridorLabel: corridorLabel ?? this.corridorLabel,
      routeTag: routeTag ?? this.routeTag,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      weather: weather ?? this.weather,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      driverVehicleUnit: driverVehicleUnit ?? this.driverVehicleUnit,
      isHybrid: isHybrid ?? this.isHybrid,
      licensePlate: licensePlate ?? this.licensePlate,
      bylawLicense: bylawLicense ?? this.bylawLicense,
      paymentScenario: paymentScenario ?? this.paymentScenario,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      baseRateCad: baseRateCad ?? this.baseRateCad,
      distanceRateCad: distanceRateCad ?? this.distanceRateCad,
      waitingTimeCad: waitingTimeCad ?? this.waitingTimeCad,
      subtotalCad: subtotalCad ?? this.subtotalCad,
      gstCad: gstCad ?? this.gstCad,
      totalCad: totalCad ?? this.totalCad,
      vehicleTypePill: vehicleTypePill ?? this.vehicleTypePill,
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        bookingTitle,
        serviceTier,
        dateTimeLabel,
        statusLabel,
        pickupAddress,
        pickupSubtext,
        pickupTime,
        dropoffAddress,
        dropoffSubtext,
        dropoffTime,
        corridorLabel,
        routeTag,
        distanceKm,
        durationMinutes,
        weather,
        driverName,
        driverRating,
        driverVehicle,
        driverVehicleUnit,
        isHybrid,
        licensePlate,
        bylawLicense,
        paymentScenario,
        paymentMethod,
        paymentStatus,
        baseRateCad,
        distanceRateCad,
        waitingTimeCad,
        subtotalCad,
        gstCad,
        totalCad,
        vehicleTypePill,
      ];
}
