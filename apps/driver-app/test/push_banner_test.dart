import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:driver_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('denied notifications show the persistent banner', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_SignedIn.new),
          driverStateProvider.overrideWith(_IdleDriver.new),
          pushControllerProvider.overrideWith(_DeniedPush.new),
        ],
        child: const DriverApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      find.text("You won't receive ride requests while the app is closed."),
      findsOneWidget,
    );
  });

  testWidgets('stale offered state redirects home without crash', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_SignedIn.new),
          driverStateProvider.overrideWith(_StaleOfferThenHome.new),
        ],
        child: const DriverApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // After reload, available → home (Start/End shift chrome).
    expect(find.text('End shift'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _SignedIn extends SessionController {
  @override
  Future<bool> build() async => true;
}

class _IdleDriver extends DriverStateController {
  @override
  Future<DriverSnapshot> build() async => const DriverSnapshot(
    version: 1,
    status: DriverStatus.available,
    shiftStartedAt: null,
    unitNumber: '7',
    booking: null,
    offer: null,
    pendingPayment: null,
  );
}

class _DeniedPush extends PushController {
  @override
  PushPermissionStatus build() => PushPermissionStatus.denied;
}

class _StaleOfferThenHome extends DriverStateController {
  @override
  Future<DriverSnapshot> build() async {
    // Simulate tap on expired offer: state refresh lands on available.
    return DriverSnapshot(
      version: 2,
      status: DriverStatus.available,
      shiftStartedAt: DateTime.utc(2026, 10, 3),
      unitNumber: '7',
      booking: null,
      offer: null,
      pendingPayment: null,
    );
  }
}
