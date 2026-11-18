import 'driver_trip_fare_breakdown.dart';
import 'driver_trip_passenger.dart';
import 'driver_trip_record.dart';

class DriverTripHistoryConfig {
  static DriverTripRecord sampleCompletedTrip() {
    return const DriverTripRecord(
      id: 'BC-123456',
      dateFormatted: 'Tue, 25 Jun 2024',
      unitNumber: 'Lethbridge Unit #42',
      status: 'COMPLETED',
      manifestType: 'ARCHIVED MANIFEST',
      pickupTime: '6:21 PM',
      pickupAddress: '440 University Dr W',
      pickupSubtitle: 'Univ of Lethbridge Student Union',
      dropoffTime: '6:35 PM',
      dropoffAddress: '501 1st Ave S',
      dropoffSubtitle: 'Downtown Civic Centre',
      distanceKm: 4.52,
      durationMinutes: 14,
      avgSpeedKmh: 38,
      fare: 20.19,
      fareBreakdown: DriverTripFareBreakdown(
        grossMeterFare: 21.50,
        passengerTip: 3.00,
        platformFee: -3.23,
        gstRemitted: -1.08,
        netEarning: 20.19,
        paymentMethodTitle: 'Card paid via app',
        paymentMethodSubtitle: 'Processed instantly',
        maskedCard: '•••• 8842',
      ),
      passenger: DriverTripPassenger(
        name: 'Jordan S.',
        rating: 4.9,
        totalRides: 114,
        isVerified: true,
        verificationText: 'Passenger verification verified',
      ),
    );
  }

  static DriverTripRecord sampleCancelledTrip() {
    return const DriverTripRecord(
      id: 'BC-987654',
      dateFormatted: '19 Jun, 14:22',
      unitNumber: 'Lethbridge Unit #42',
      status: 'CANCELLED',
      manifestType: 'ARCHIVED MANIFEST',
      pickupTime: '2:22 PM',
      pickupAddress: 'Park Place Mall, 501 1 Ave S',
      pickupSubtitle: 'Shopping Centre Entrance',
      dropoffTime: '2:25 PM',
      dropoffAddress: 'Enmax Centre, Lethbridge',
      dropoffSubtitle: 'West Gate Arena',
      distanceKm: 0.8,
      durationMinutes: 3,
      avgSpeedKmh: 20,
      fare: 0.00,
      fareNote: 'No fare recorded',
      fareBreakdown: DriverTripFareBreakdown(
        grossMeterFare: 0.0,
        passengerTip: 0.0,
        platformFee: 0.0,
        gstRemitted: 0.0,
        netEarning: 0.0,
        paymentMethodTitle: 'Trip Cancelled',
        paymentMethodSubtitle: 'No fee charged',
        maskedCard: '•••• ----',
      ),
      passenger: DriverTripPassenger(
        name: 'Alex R.',
        rating: 4.8,
        totalRides: 32,
      ),
    );
  }
}
