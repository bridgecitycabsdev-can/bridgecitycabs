import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:driver_app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final entry in _routes.entries) {
    testWidgets('maps ${entry.key.name} to ${entry.value}', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_SignedIn.new),
            driverStateProvider.overrideWith(() => _FixedDriver(entry.key)),
          ],
          child: const DriverApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(entry.value), findsOneWidget);
    });
  }
}

/// Unique visible copy for the screen each status should land on.
const _routes = {
  DriverStatus.offline: 'Start shift',
  DriverStatus.available: 'End shift',
  DriverStatus.away: 'End shift',
  DriverStatus.offered: 'New offer',
  DriverStatus.assigned: 'BC-1',
  DriverStatus.enRoutePickup: 'BC-1',
  DriverStatus.arrived: 'BC-1',
  DriverStatus.onTrip: 'BC-1',
};

class _SignedIn extends SessionController {
  @override
  Future<bool> build() async => true;
}

class _FixedDriver extends DriverStateController {
  _FixedDriver(this.status);

  final DriverStatus status;

  @override
  Future<DriverSnapshot> build() async {
    final trip = status == DriverStatus.offered ||
        status == DriverStatus.available ||
        status == DriverStatus.away ||
        status == DriverStatus.offline;
    return DriverSnapshot(
      version: 1,
      status: status,
      shiftStartedAt: status == DriverStatus.offline
          ? null
          : DateTime.utc(2026, 10, 3),
      unitNumber: '7',
      booking: trip
          ? null
          : const DriverBooking(
              id: '11111111-1111-4111-8111-111111111111',
              trackingId: 'BC-1',
              status: 'DRIVER_ASSIGNED',
              stops: [
                DriverBookingStop(
                  sequence: 0,
                  type: 'PICKUP',
                  address: 'A',
                  lat: 1,
                  lng: 2,
                ),
                DriverBookingStop(
                  sequence: 1,
                  type: 'DROPOFF',
                  address: 'B',
                  lat: 3,
                  lng: 4,
                ),
              ],
              passengerFirstName: 'Sam',
              quotedFareCents: 1000,
              notes: null,
            ),
      pendingPayment: null,
      offer: status == DriverStatus.offered
          ? Offer(
              id: '22222222-2222-4222-8222-222222222222',
              bookingId: '11111111-1111-4111-8111-111111111111',
              expiresAt: DateTime.utc(2030),
              serverNow: DateTime.utc(2026, 10, 3),
              pickup: const OfferPlace(address: 'A', lat: 1, lng: 2),
              dropoff: const OfferPlace(address: 'B', lat: 3, lng: 4),
              distanceToPickupM: 100,
              tripDistanceM: 1000,
              quotedFareCents: 1000,
              paymentMethod: 'CASH',
              vanOnly: false,
              ladyDriverOnly: false,
              passengerFirstName: 'Sam',
              notes: null,
            )
          : null,
    );
  }
}
