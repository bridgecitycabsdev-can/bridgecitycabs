import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/settings/settings.dart';

void main() {
  group('DriverSettingsPage Widget Tests', () {
    late FakeDriverSettingsRepository repository;

    setUp(() {
      repository = FakeDriverSettingsRepository(latency: Duration.zero);
    });

    Widget createWidget({
      DriverSettingsStatus initialStatus = DriverSettingsStatus.hub,
    }) {
      return MaterialApp(
        home: DriverSettingsPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders Screen 1 (Image 1): Driver Settings Hub properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverSettingsStatus.hub));
      await tester.pumpAndSettle();

      expect(find.text('Driver Settings Hub'), findsOneWidget);
      expect(find.text('Marcus Vance'), findsOneWidget);
      expect(find.text('UNIT #42'), findsOneWidget);
      expect(find.text('AVAILABLE'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Trip\nActive'), findsOneWidget);
      expect(find.text('Modal'), findsOneWidget);

      // Preferences
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Navigation app'), findsOneWidget);
      expect(find.text('Google Maps'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light (High Contrast)'), findsOneWidget);

      // Support & Legal
      expect(find.text('SUPPORT & LEGAL'), findsOneWidget);
      expect(find.text('FAQs'), findsOneWidget);
      expect(find.text('Insurance & Cover...'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
      expect(find.text('24/7 Lethbridge Central Dispatch'), findsOneWidget);

      // Banner & Log out & Version
      expect(find.text('Oldman River Valley District'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(find.textContaining('Version 1.0.32'), findsOneWidget);
    });

    testWidgets('Renders Screen 2 (Image 2): Notifications View properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverSettingsStatus.notifications));
      await tester.pumpAndSettle();

      expect(find.text('Notifications are off'), findsOneWidget);
      expect(find.text('Open settings'), findsOneWidget);
      expect(find.text('DISPATCH & TRIP ALERTS'), findsOneWidget);
      expect(find.text('3 of 4 Active'), findsOneWidget);
      expect(find.text('Ride requests'), findsOneWidget);
      expect(find.text('Trip updates'), findsOneWidget);
      expect(find.text('Earnings and statements'), findsOneWidget);
      expect(find.text('Promotions & announcements'), findsOneWidget);

      expect(find.text('SOUND & HAPTICS'), findsOneWidget);
      expect(find.text('Cockpit Mode'), findsOneWidget);
      expect(find.text('Request sound'), findsOneWidget);
      expect(find.text('Bridge City Chime'), findsOneWidget);
      expect(find.text('Lethbridge Pulse'), findsOneWidget);
      expect(find.text('High Alert Horn'), findsOneWidget);
      expect(find.text('Vibration pattern'), findsOneWidget);
      expect(find.text('In-cab priority audio'), findsOneWidget);
      expect(find.text('Simulate Dispatch Chime'), findsOneWidget);
    });

    testWidgets('Renders Screen 3 (Image 3): Navigation View properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverSettingsStatus.navigation));
      await tester.pumpAndSettle();

      expect(find.text('FLEET GPS\nPROFILE'), findsOneWidget);
      expect(find.text('Lethbridge Grid Ready'), findsOneWidget);
      expect(find.text('Default Navigation Provider'), findsOneWidget);
      expect(find.text('Google Maps'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);
      expect(find.text('Apple Maps'), findsOneWidget);
      expect(find.text('iOS Only'), findsOneWidget);
      expect(find.text('Waze'), findsOneWidget);

      expect(find.text('In-app audio alerts'), findsOneWidget);
      expect(find.text('Auto-return upon arrival'), findsOneWidget);
      expect(find.text('Save preference'), findsOneWidget);
    });

    testWidgets('Renders Screen 4 (Image 4): Theme View properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverSettingsStatus.theme));
      await tester.pumpAndSettle();

      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Day cockpit'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Night shift'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Auto-synced'), findsOneWidget);

      expect(find.text('Independent Map HUD'), findsOneWidget);
      expect(find.text('Display Ergonomics'), findsOneWidget);
      expect(find.text('SHIFT CONTROLS'), findsOneWidget);
      expect(find.text('Auto-dim on low battery'), findsOneWidget);
      expect(find.text('Keep screen awake while online'), findsOneWidget);
      expect(find.text('Large font accessibility'), findsOneWidget);
      expect(find.text('Apply Theme'), findsOneWidget);
    });

    testWidgets('Renders Screen 5 (Image 5): Insurance & Legal View properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverSettingsStatus.insurance));
      await tester.pumpAndSettle();

      expect(find.text('Insurance'), findsOneWidget);
      expect(find.text('FAQs'), findsOneWidget);
      expect(find.text('Terms'), findsOneWidget);

      expect(find.text('Lethbridge Fleet Sync: Operational'), findsOneWidget);
      expect(find.text('ACTIVE POLICY'), findsOneWidget);
      expect(find.text('AB-LCC-9821'), findsOneWidget);
      expect(find.text('Commercial Vehicle Insurance Policy'), findsOneWidget);

      expect(find.text("What's Covered During Trips"), findsOneWidget);
      expect(find.text('\$5,000,000 Third-Party Liability'), findsOneWidget);
      expect(find.text('Collision & Passenger Property Damage'), findsOneWidget);
      expect(find.text('Comprehensive Roadside Assistance'), findsOneWidget);

      expect(find.text('Required In-Cab Documents'), findsOneWidget);
      expect(find.text('MANDATORY'), findsOneWidget);
      expect(find.text('Alberta Class 4 Commercial...'), findsOneWidget);
      expect(find.text('Annual CVIP Mechanical C...'), findsOneWidget);
      expect(find.text('City of Lethbridge Livery P...'), findsOneWidget);

      expect(find.text('Collision & Incident Protocol'), findsOneWidget);
      expect(find.text('Secure Safety & Hazard Lights'), findsOneWidget);
      expect(find.text('Call 911 If Medical Care Needed'), findsOneWidget);
      expect(find.text('Contact 24/7 Fleet Dispatch Support'), findsOneWidget);
      expect(find.text('Download Insurance Certificate (PDF)'), findsOneWidget);
    });

    testWidgets('QA switcher toggles screens interactively in widget tree', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverSettingsStatus.hub));
      await tester.pumpAndSettle();

      expect(find.text('Preferences'), findsNothing); // It's uppercase
      expect(find.text('PREFERENCES'), findsOneWidget);

      // Switch to Notifications
      await tester.tap(find.text('2. Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('DISPATCH & TRIP ALERTS'), findsOneWidget);

      // Switch to Navigation
      await tester.tap(find.text('3. Navigation GPS'));
      await tester.pumpAndSettle();
      expect(find.text('Default Navigation Provider'), findsOneWidget);

      // Switch to Theme
      await tester.tap(find.text('4. Theme & Ergonomics'));
      await tester.pumpAndSettle();
      expect(find.text('Apply Theme'), findsOneWidget);

      // Switch to Insurance
      await tester.tap(find.text('5. Insurance & Legal'));
      await tester.pumpAndSettle();
      expect(find.text('ACTIVE POLICY'), findsOneWidget);
    });
  });
}
