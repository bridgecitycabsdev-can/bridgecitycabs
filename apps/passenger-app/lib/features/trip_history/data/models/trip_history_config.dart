import 'trip_history_model.dart';

class TripHistoryConfig {
  static const String screenTitle = 'Trip Fare Breakdown';
  static const String historyTitle = 'Trips';
  static const String tripsHeaderTitle = 'Trips';

  static const String bylawAuditNotice =
      'City of Lethbridge Taxi Commission Bylaw 6138\nAll journeys GPS track-logged and audited. Thank you for riding with Bridge City Cabs.';

  static const String bylawShortNotice =
      'Regulated by Lethbridge Taxi Commission Bylaw';

  static const String emailReceiptNotice =
      'Trip receipts and invoices are also sent to your registered email address automatically after every completed ride.';

  static const String comingSoonTitle = 'Past trips are coming soon';
  static const String comingSoonSubtitle =
      'For now, you can find your latest trip receipt in your notifications or view your last completed journey above.';

  static const String permanentRecordNotice =
      'Past trips are permanent records and cannot be edited or removed.';

  // Default Last Trip (Ride 1)
  static const TripRecord defaultLastTrip = TripRecord(
    tripId: 'BC-123456',
    bookingTitle: 'University to Downtown Core',
    serviceTier: 'Priority Express',
    dateTimeLabel: 'Sat, 22 Aug · 2:48 PM',
    statusLabel: 'COMPLETED',
    pickupAddress: '440 University Dr W, Lethbridge',
    pickupSubtext: 'University Campus South Entrance',
    pickupTime: '2:48 PM',
    dropoffAddress: '501 1st Ave S, Downtown Core',
    dropoffSubtext: 'Downtown Core Commercial Hub',
    dropoffTime: '3:00 PM',
    corridorLabel: 'Lethbridge Central Corridor',
    routeTag: 'Whoop-Up Dr Route',
    distanceKm: 4.52,
    durationMinutes: 12,
    weather: '22°C Clear',
    driverName: 'Marcus V.',
    driverRating: 4.9,
    driverVehicle: 'Toyota Camry SE',
    driverVehicleUnit: 'Unit #44',
    isHybrid: true,
    licensePlate: 'ALBERTA BCF-402',
    bylawLicense: '#LTC-8841',
    paymentScenario: TripPaymentScenario.cardPaid,
    paymentMethod: 'Visa •••• 4242',
    paymentStatus: 'Paid',
    baseRateCad: 4.50,
    distanceRateCad: 11.30,
    waitingTimeCad: 3.40,
    subtotalCad: 19.20,
    gstCad: 0.96,
    totalCad: 20.16,
    vehicleTypePill: 'Camry SE',
  );

  // Ride 2
  static const TripRecord parkPlaceTrip = TripRecord(
    tripId: 'BC-123457',
    bookingTitle: 'Park Place Mall to U of L Hall 3',
    serviceTier: 'Standard Sedan',
    dateTimeLabel: 'Sat, 22 Aug · 10:15 AM',
    statusLabel: 'COMPLETED',
    pickupAddress: 'Park Place Mall, 501 1 Ave S',
    pickupSubtext: 'Mall Main Entrance',
    pickupTime: '10:15 AM',
    dropoffAddress: 'University of Lethbridge, Hall 3',
    dropoffSubtext: 'Hall 3 Quad Dropoff',
    dropoffTime: '10:28 AM',
    corridorLabel: 'West Lethbridge Arterial',
    routeTag: 'University Dr Corridor',
    distanceKm: 4.10,
    durationMinutes: 13,
    weather: '21°C Sun',
    driverName: 'David K.',
    driverRating: 4.92,
    driverVehicle: 'Toyota Corolla Sedan',
    driverVehicleUnit: 'Unit #12',
    isHybrid: true,
    licensePlate: 'ALBERTA BCC-892',
    bylawLicense: '#LTC-8841',
    paymentScenario: TripPaymentScenario.cashPaid,
    paymentMethod: 'Cash',
    paymentStatus: 'Paid in Cash',
    baseRateCad: 4.00,
    distanceRateCad: 10.50,
    waitingTimeCad: 2.00,
    subtotalCad: 16.50,
    gstCad: 1.90,
    totalCad: 18.40,
    vehicleTypePill: 'Sedan',
  );

  // Ride 3
  static const TripRecord enmaxTrip = TripRecord(
    tripId: 'BC-123458',
    bookingTitle: 'Enmax Centre to West Highlands',
    serviceTier: 'SUV Big',
    dateTimeLabel: 'Fri, 21 Aug · 6:30 PM',
    statusLabel: 'COMPLETED',
    pickupAddress: 'Enmax Centre, 2510 Scenic Dr S',
    pickupSubtext: 'South Event Gate',
    pickupTime: '6:30 PM',
    dropoffAddress: 'West Highlands Park, Lethbridge',
    dropoffSubtext: 'Park Community Loop',
    dropoffTime: '6:52 PM',
    corridorLabel: 'Scenic Heights Corridor',
    routeTag: 'Scenic Dr Route',
    distanceKm: 8.40,
    durationMinutes: 22,
    weather: '23°C Sunny',
    driverName: 'Sarah T.',
    driverRating: 4.98,
    driverVehicle: 'Ford Explorer SUV',
    driverVehicleUnit: 'Unit #78',
    isHybrid: false,
    licensePlate: 'ALBERTA BCF-990',
    bylawLicense: '#LTC-8841',
    paymentScenario: TripPaymentScenario.cardPaid,
    paymentMethod: 'Mastercard •••• 8842',
    paymentStatus: 'Paid',
    baseRateCad: 5.50,
    distanceRateCad: 28.00,
    waitingTimeCad: 8.25,
    subtotalCad: 41.75,
    gstCad: 2.09,
    totalCad: 43.84,
    vehicleTypePill: 'SUV · Big',
  );

  // Ride 4 (Canceled)
  static const TripRecord airportCanceledTrip = TripRecord(
    tripId: 'BC-123459',
    bookingTitle: 'Airport to Galt Museum',
    serviceTier: 'Standard',
    dateTimeLabel: 'Fri, 21 Aug · 1:12 PM',
    statusLabel: 'CANCELED',
    pickupAddress: 'Lethbridge Airport (YQL)',
    pickupSubtext: 'Terminal Arrival Curb',
    pickupTime: '1:12 PM',
    dropoffAddress: 'Galt Museum, 502 1 St S',
    dropoffSubtext: 'Museum Overlook Dropoff',
    dropoffTime: '1:14 PM',
    corridorLabel: 'Airport Highway 5 Corridor',
    routeTag: 'Hwy 5 Express',
    distanceKm: 0.0,
    durationMinutes: 2,
    weather: '20°C Breeze',
    driverName: 'Michael R.',
    driverRating: 4.94,
    driverVehicle: 'Toyota Camry',
    driverVehicleUnit: 'Unit #104',
    isHybrid: true,
    licensePlate: 'ALBERTA BCF-402',
    bylawLicense: '#LTC-8841',
    paymentScenario: TripPaymentScenario.cardPaid,
    paymentMethod: 'Visa •••• 4242',
    paymentStatus: 'No charge (Canceled)',
    baseRateCad: 0.0,
    distanceRateCad: 0.0,
    waitingTimeCad: 0.0,
    subtotalCad: 0.0,
    gstCad: 0.0,
    totalCad: 0.0,
    vehicleTypePill: 'Standard',
  );

  static const List<TripRecord> allHistoryTrips = [
    defaultLastTrip,
    parkPlaceTrip,
    enmaxTrip,
    airportCanceledTrip,
  ];

  static List<GroupedTripDate> get defaultGroupedTrips => [
        const GroupedTripDate(
          dateHeader: 'Sat, 22 Aug · 2 rides · \$38.56 CAD',
          dateLabel: 'Sat, 22 Aug',
          rideCount: 2,
          totalCad: 38.56,
          trips: [defaultLastTrip, parkPlaceTrip],
        ),
        const GroupedTripDate(
          dateHeader: 'Fri, 21 Aug · 2 rides · \$43.84 CAD',
          dateLabel: 'Fri, 21 Aug',
          rideCount: 2,
          totalCad: 43.84,
          trips: [enmaxTrip, airportCanceledTrip],
        ),
      ];

  static const TripSummaryData defaultSummary = TripSummaryData(
    totalTrips: 4,
    totalSpentCad: 82.40,
  );
}
