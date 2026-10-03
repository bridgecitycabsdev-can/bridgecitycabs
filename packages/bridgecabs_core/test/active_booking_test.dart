import 'package:bridgecabs_core/models/active_booking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final payload = {
    'id': '11111111-1111-4111-8111-111111111111',
    'trackingId': 'BC-100',
    'status': 'DRIVER_ARRIVING',
    'etaSeconds': 180,
    'scheduledAt': null,
    'quotedFareCents': 2500,
    'quotedTaxCents': 125,
    'notes': null,
    'passengerName': 'Alex',
    'vehicleType': {
      'id': '22222222-2222-4222-8222-222222222222',
      'name': 'Sedan',
    },
    'stops': [
      {
        'sequence': 0,
        'type': 'PICKUP',
        'address': 'City Hall',
        'lat': 49.69,
        'lng': -112.84,
      },
      {
        'sequence': 1,
        'type': 'DROPOFF',
        'address': 'Airport',
        'lat': 49.63,
        'lng': -112.8,
      },
    ],
    'driver': {
      'firstName': 'Sam',
      'rating': 4.8,
      'vehicle': {
        'make': 'Toyota',
        'model': 'Camry',
        'colour': 'Black',
        'plate': 'ABC123',
        'unitNumber': '42',
      },
    },
  };

  test('parses passenger booking card fields for tracking', () {
    final booking = ActiveBooking.tryParse(payload);
    expect(booking, isNotNull);
    expect(booking!.isTracking, isTrue);
    expect(booking.isLive, isTrue);
    expect(booking.canCancel, isTrue);
    expect(booking.driver?.firstName, 'Sam');
    expect(booking.driver?.vehicle?.plate, 'ABC123');
    expect(booking.pickupAddress, 'City Hall');
  });

  test('treats completed trips as terminal receipt', () {
    final booking = ActiveBooking.tryParse({
      ...payload,
      'status': 'PAYMENT_PENDING',
      'driver': null,
      'finalSubtotalCents': 2500,
      'finalTaxCents': 125,
      'finalFareCents': 2625,
    });
    expect(booking!.isTerminal, isTrue);
    expect(booking.isLive, isFalse);
    expect(booking.isReceipt, isTrue);
    expect(booking.receiptTotalCents, 2625);
  });

  test('classifies searching and no-driver states', () {
    final searching = ActiveBooking.tryParse({
      ...payload,
      'status': 'SEARCHING_DRIVER',
      'driver': null,
    });
    expect(searching!.isSearching, isTrue);
    expect(searching.isTracking, isFalse);

    final none = ActiveBooking.tryParse({
      ...payload,
      'status': 'NO_DRIVER_FOUND',
      'driver': null,
    });
    expect(none!.noDriverFound, isTrue);
    expect(none.isSearching, isTrue);
  });

  test('parses driver location pings', () {
    final ping = DriverLocationPing.tryParse({
      'bookingId': '11111111-1111-4111-8111-111111111111',
      'lat': 49.7,
      'lng': -112.85,
      'heading': 90.0,
      'ts': 1710000000,
    });
    expect(ping?.lat, 49.7);
    expect(ping?.heading, 90.0);
  });
}
