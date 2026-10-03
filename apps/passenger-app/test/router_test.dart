import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/app.dart';
import 'package:passenger_app/features/booking/draft.dart';

void main() {
  testWidgets('sends an assigned booking to tracking', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_SignedIn.new),
          activeBookingProvider.overrideWith(_Assigned.new),
        ],
        child: const PassengerApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('DRIVER ARRIVING'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
  });

  testWidgets('sends a searching booking to the search screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_SignedIn.new),
          activeBookingProvider.overrideWith(_Searching.new),
        ],
        child: const PassengerApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Finding a driver'), findsOneWidget);
  });

  testWidgets('opens Where to when there is no active booking', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_SignedIn.new),
          activeBookingProvider.overrideWith(_None.new),
          bookingDraftProvider.overrideWith(_ReadyDraft.new),
        ],
        child: const PassengerApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Where to?'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
  });
}

class _SignedIn extends SessionController {
  @override
  Future<bool> build() async => true;
}

class _None extends ActiveBookingController {
  @override
  Future<ActiveBooking?> build() async => null;
}

class _ReadyDraft extends BookingDraftController {
  @override
  BookingDraft build() => const BookingDraft(
    pickup: PlaceStop(address: 'City Hall', lat: 49.69, lng: -112.84),
  );
}

class _Searching extends ActiveBookingController {
  @override
  Future<ActiveBooking?> build() async => ActiveBooking.tryParse({
    'id': '11111111-1111-4111-8111-111111111111',
    'trackingId': 'BC-1',
    'status': 'SEARCHING_DRIVER',
    'etaSeconds': null,
    'scheduledAt': null,
    'quotedFareCents': 1000,
    'quotedTaxCents': 50,
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
        'address': 'A',
        'lat': 1.0,
        'lng': 2.0,
      },
      {
        'sequence': 1,
        'type': 'DROPOFF',
        'address': 'B',
        'lat': 3.0,
        'lng': 4.0,
      },
    ],
    'driver': null,
  });
}

class _Assigned extends ActiveBookingController {
  @override
  Future<ActiveBooking?> build() async => ActiveBooking.tryParse({
    'id': '11111111-1111-4111-8111-111111111111',
    'trackingId': 'BC-1',
    'status': 'DRIVER_ARRIVING',
    'etaSeconds': 120,
    'scheduledAt': null,
    'quotedFareCents': 1000,
    'quotedTaxCents': 50,
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
        'address': 'A',
        'lat': 1.0,
        'lng': 2.0,
      },
      {
        'sequence': 1,
        'type': 'DROPOFF',
        'address': 'B',
        'lat': 3.0,
        'lng': 4.0,
      },
    ],
    'driver': {
      'firstName': 'Sam',
      'rating': 4.9,
      'vehicle': {
        'make': 'Toyota',
        'model': 'Corolla',
        'colour': 'Blue',
        'plate': 'XYZ',
        'unitNumber': '7',
      },
    },
  });
}
