import 'driver_edge_state.dart';
import 'driver_fast_change_calc.dart';
import 'driver_rate_passenger_model.dart';
import 'driver_trip_summary_model.dart';

class DriverTripSummaryConfig {
  // Screenshot 3: Card Auto-Settled Summary
  static const DriverTripSummaryModel cardSummaryPreset = DriverTripSummaryModel(
    tripId: 'BC-123456',
    paymentMethod: 'CARD',
    cardEnding: '•••• 8842',
    cardBrand: 'VISA',
    paymentProcessedVia: 'Stripe Fleet Sync',
    paymentStatusLabel: 'Pre-authorized & Captured',
    isPaid: true,
    pickupAddress: '440 University Dr W',
    pickupSecondary: 'Lethbridge West Campus',
    pickupTime: '6:21 PM',
    dropoffAddress: '501 1st Ave S',
    dropoffSecondary: 'Downtown Plaza Core',
    dropoffTime: '6:35 PM',
    distanceKm: 4.52,
    durationMinutes: 14,
    avgSpeedKmh: 38,
    passengerName: 'Alex M.',
    zone: 'Lethbridge Central Zone',
    routeCorridor: 'Lethbridge West Campus → Downtown Core',
    grossMeteredFare: 22.10,
    subtotalMeterFare: 21.05,
    gstAlberta: 1.05,
    fleetFeePercent: 15.0,
    fleetFeeAmount: 3.32,
    netPayout: 18.78,
    isReceiptSent: true,
  );

  // Screenshot 4: Cash Payment Due Summary
  static const DriverTripSummaryModel cashSummaryPreset = DriverTripSummaryModel(
    tripId: 'BC-123456',
    paymentMethod: 'CASH',
    cardEnding: '',
    cardBrand: '',
    paymentProcessedVia: 'Dispatch Local Meter',
    paymentStatusLabel: 'CASH PAYMENT DUE',
    isPaid: false,
    pickupAddress: '440 University Dr W',
    pickupSecondary: 'University Centre North Pickup Bay',
    pickupTime: '6:21 PM',
    dropoffAddress: '501 1st Ave S',
    dropoffSecondary: 'Downtown Core Terminal Corner',
    dropoffTime: '6:35 PM',
    distanceKm: 4.52,
    durationMinutes: 14,
    avgSpeedKmh: 38,
    passengerName: 'Alex M.',
    zone: 'Lethbridge Transit Zone',
    routeCorridor: 'Lethbridge West Campus → Downtown Core',
    grossMeteredFare: 22.10,
    subtotalMeterFare: 21.05,
    gstAlberta: 1.05,
    fleetFeePercent: 15.0,
    fleetFeeAmount: 3.32,
    netPayout: 18.78,
    changeOptions: [
      DriverFastChangeOption(tenderAmount: 25.0, fareAmount: 22.10),
      DriverFastChangeOption(tenderAmount: 30.0, fareAmount: 22.10),
    ],
    isCashCollected: false,
    isReceiptSent: false,
  );

  // Screenshot 5 Top: Rate Passenger Preset
  static const DriverTripSummaryModel ratePassengerPreset = DriverTripSummaryModel(
    tripId: 'BC-9942',
    paymentMethod: 'CASH',
    passengerName: 'Alex M.',
    netPayout: 18.78,
    ratingModel: DriverRatePassengerModel(
      passengerName: 'Alex M.',
      tripId: 'BC-9942',
      routeSummary: '4th Ave S to Scenic Dr',
      ridesCompletedSummary: 'Lethbridge Rider • 42 rides completed',
      tripFareTypeSummary: '\$18.78 Cash Trip',
      rating: 4.5,
      selectedTags: ['Polite', 'On time'],
      dispatcherFeedbackNotes: '',
    ),
  );

  // Screenshot 5 Bottom: Edge States Gallery Preset
  static const DriverTripSummaryModel edgeStatesGalleryPreset = DriverTripSummaryModel(
    tripId: 'BC-123456',
    activeEdgeState: DriverEdgeStateType.pendingVerification,
  );
}
