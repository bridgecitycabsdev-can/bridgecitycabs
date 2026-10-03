import 'package:bridgecabs_core/driver/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses an offer with payment and eligibility flags', () {
    final offer = Offer.tryParse({
      'offerId': '11111111-1111-4111-8111-111111111111',
      'bookingId': '22222222-2222-4222-8222-222222222222',
      'expiresAt': '2026-10-03T18:00:15.000Z',
      'serverNow': '2026-10-03T18:00:00.000Z',
      'pickup': {'address': 'City Hall', 'lat': 49.69, 'lng': -112.84},
      'dropoff': {'address': 'Airport', 'lat': 49.63, 'lng': -112.8},
      'distanceToPickupM': 400,
      'tripDistanceM': 8000,
      'quotedFareCents': 2500,
      'paymentMethod': 'CASH',
      'vanOnly': false,
      'ladyDriverOnly': true,
      'passengerFirstName': 'Leila',
      'notes': 'Side door',
    });
    expect(offer, isNotNull);
    expect(offer!.paymentMethod, 'CASH');
    expect(offer.ladyDriverOnly, isTrue);
    expect(offer.passengerFirstName, 'Leila');
  });

  test('keeps the Day 5 version guard for socket applies', () {
    final first = DriverSnapshot.tryParse({
      'v': 3,
      'status': 'OFFERED',
      'shift': null,
      'booking': null,
      'offer': {
        'id': '11111111-1111-4111-8111-111111111111',
        'expiresAt': '2026-10-03T18:00:15.000Z',
        'serverNow': '2026-10-03T18:00:00.000Z',
        'pickup': {'address': 'A', 'lat': 1.0, 'lng': 2.0},
        'dropoff': {'address': 'B', 'lat': 3.0, 'lng': 4.0},
        'distanceToPickupM': 1,
        'tripDistanceM': 2,
        'quotedFareCents': 100,
        'paymentMethod': 'CARD',
        'vanOnly': true,
        'ladyDriverOnly': false,
        'passengerFirstName': 'Sam',
        'notes': null,
      },
    });
    expect(first?.status, DriverStatus.offered);
    expect(first?.offer?.paymentMethod, 'CARD');
  });
}
