import 'past_trip_detail_model.dart';

class PastTripDetailConfig {
  static const String bylawNotice =
      'City of Lethbridge Taxi Commission Bylaw 6138. All journeys GPS track-logged and audited. Thank you for riding with Bridge City Cabs.';

  static const String emailReceiptNotice =
      'Trip receipts and invoices are also sent to your registered email address automatically after every completed ride.';

  static const String comingSoonTitle = 'Past trips are coming soon';
  static const String comingSoonSubtitle =
      'For now, you can find your latest trip receipt in your notifications or view your last completed journey above.';

  static const PastTripDetailModel defaultTripMarcus = PastTripDetailModel(
    tripId: 'BC-123456',
    formattedId: 'BC-123456',
    dateTimeLabel: 'Sat, 22 Aug · 2:48 PM',
    statusLabel: 'Completed',
    isCompleted: true,
    isInProgress: false,
    routeTag: 'Whoop-Up Dr Route',
    crossingLabel: 'Oldman River Crossing',
    pickupAddress: '440 University Dr W, Lethbridge',
    pickupSubtext: 'University Campus South Entrance',
    pickupTime: '2:48 PM',
    dropoffAddress: '501 1st Ave S, Downtown Lethbr...',
    dropoffSubtext: 'Downtown Core Commercial Hub',
    dropoffTime: '3:00 PM',
    distanceKm: 4.52,
    durationMinutes: 12,
    weather: '22°C Clear',
    driverName: 'Marcus V.',
    driverRating: 4.9,
    vehicleName: 'Toyota Camry SE',
    isHybrid: true,
    licensePlate: 'ALBERTA BCF-402',
    bylawLicense: 'Bylaw License #LTC-8841 · Verified Prairie Operator',
    rateType: 'Metered Rate #1',
    baseDropRateCad: 4.50,
    distanceRateCad: 11.30,
    waitingDelayCad: 3.40,
    subtotalCad: 19.20,
    gstCad: 0.96,
    totalChargedCad: 20.16,
    paymentMethodTitle: 'Visa •••• 4242',
    paymentStatusText: 'Paid',
    isCash: false,
    isSettled: true,
  );

  static const PastTripDetailModel defaultTripHarpreet = PastTripDetailModel(
    tripId: 'BCC-84920',
    formattedId: 'Trip #BCC-84920',
    dateTimeLabel: 'Oct 24, 2:45 PM · 18 min',
    statusLabel: 'Completed',
    isCompleted: true,
    isInProgress: false,
    routeTag: 'Crowsnest Hwy / Scenic Dr',
    crossingLabel: 'Oldman High-Level Viaduct',
    pickupAddress: 'Park Place Mall, 501 1 Ave S',
    pickupSubtext: 'Main Mall Entrance',
    pickupTime: '2:27 PM',
    dropoffAddress: 'University of Lethbridge, Hall 3',
    dropoffSubtext: 'Campus Transit Loop',
    dropoffTime: '2:45 PM',
    distanceKm: 5.20,
    durationMinutes: 18,
    weather: '18°C Sunny',
    driverName: 'Harpreet S.',
    driverRating: 4.96,
    vehicleName: 'Toyota Camry Hybrid',
    isHybrid: true,
    licensePlate: 'Alta 93-R10',
    bylawLicense: 'Bylaw License #LTC-8841 · Verified Prairie Operator',
    rateType: 'Metered Rate #1',
    baseDropRateCad: 4.50,
    distanceRateCad: 13.00,
    waitingDelayCad: 3.55,
    subtotalCad: 21.05,
    gstCad: 1.05,
    totalChargedCad: 22.10,
    paymentMethodTitle: 'Visa •••• 4242',
    paymentStatusText: 'Auto-charged & Settled',
    isCash: false,
    isSettled: true,
  );

  static PastTripDetailModel getTripForScenario(PastTripQaScenario scenario) {
    switch (scenario) {
      case PastTripQaScenario.completedCard:
        return defaultTripMarcus;

      case PastTripQaScenario.completedCash:
        return defaultTripMarcus.copyWith(
          paymentMethodTitle: 'Cash Payment',
          paymentStatusText: 'Paid in Cash',
          isCash: true,
        );

      case PastTripQaScenario.cashPending:
        return defaultTripMarcus.copyWith(
          paymentMethodTitle: 'Cash Payment',
          paymentStatusText: 'Awaiting Driver Terminal',
          isCash: true,
          isSettled: false,
        );

      case PastTripQaScenario.inProgress:
        return defaultTripMarcus.copyWith(
          statusLabel: 'In Progress',
          isCompleted: false,
          isInProgress: true,
          paymentStatusText: 'Meter Running...',
          dropoffTime: 'Est. 3:00 PM',
        );

      case PastTripQaScenario.disputedFare:
        return defaultTripMarcus.copyWith(
          statusLabel: 'Under Review',
          paymentStatusText: 'Fare Adjustment Pending',
        );

      case PastTripQaScenario.cancelledWithFee:
        return defaultTripMarcus.copyWith(
          statusLabel: 'Cancelled',
          isCompleted: false,
          baseDropRateCad: 5.00,
          distanceRateCad: 0.00,
          waitingDelayCad: 0.00,
          subtotalCad: 5.00,
          gstCad: 0.25,
          totalChargedCad: 5.25,
          paymentStatusText: 'Cancellation Fee Paid',
        );

      case PastTripQaScenario.promoApplied:
        return defaultTripMarcus.copyWith(
          subtotalCad: 14.20,
          gstCad: 0.71,
          totalChargedCad: 14.91,
          paymentStatusText: 'Promo BRIDGE5 Applied (-\$5.00)',
        );

      case PastTripQaScenario.airportSurcharge:
        return defaultTripMarcus.copyWith(
          dropoffAddress: 'Lethbridge Airport (YQL)',
          dropoffSubtext: 'Terminal Departure Curb',
          subtotalCad: 25.20,
          gstCad: 1.26,
          totalChargedCad: 26.46,
          paymentStatusText: 'Paid (Airport Fee Included)',
        );

      case PastTripQaScenario.multiStopTrip:
        return defaultTripMarcus.copyWith(
          distanceKm: 8.40,
          durationMinutes: 24,
          subtotalCad: 28.50,
          gstCad: 1.43,
          totalChargedCad: 29.93,
          routeTag: '2-Stop Scenic Transit',
          dropoffSubtext: 'Stop 1: Safeway, Stop 2: Downtown',
        );
    }
  }
}
