import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/profile/profile.dart';

void main() {
  group('DriverProfilePage Widget Tests', () {
    late FakeDriverProfileRepository repository;

    setUp(() {
      repository = FakeDriverProfileRepository(latency: Duration.zero);
    });

    Widget createWidget({
      DriverProfileStatus initialStatus = DriverProfileStatus.activeOnline,
    }) {
      return MaterialApp(
        home: DriverProfilePage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders State 1: Active Online Profile with Info tab properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverProfileStatus.activeOnline));
      await tester.pumpAndSettle();

      expect(find.text('Driver Profile'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Shajil Kunhumon'), findsOneWidget);
      expect(find.text('\$41.77'), findsOneWidget);
      expect(find.text('FULL NAME'), findsOneWidget);
      expect(find.text('DISPATCH EMAIL'), findsOneWidget);
      expect(find.text('PHONE NUMBER'), findsOneWidget);
      expect(find.text('White Toyota Camry Hybrid (2021)'), findsOneWidget);
      expect(find.text('Unit #42'), findsOneWidget);
      expect(find.text('GPS Linked'), findsOneWidget);
    });

    testWidgets('Renders State 2: Expired Locked Profile with Documents tab properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverProfileStatus.credentialExpiredLocked));
      await tester.pumpAndSettle();

      expect(find.text('Action Required'), findsOneWidget);
      expect(find.text('LOCKED'), findsOneWidget);
      expect(find.textContaining("Your driver's licence has expired"), findsOneWidget);
      expect(find.text("Class 4 Driver's Licence"), findsOneWidget);
      expect(find.text('Expired Oct 24, 2024'), findsOneWidget);
      expect(find.text('Upload New Licence'), findsOneWidget);
      expect(find.text('Update Documents to Go Online'), findsOneWidget);
    });

    testWidgets('Renders State 3: Expiring Soon with Active Inspection Sheet properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverProfileStatus.expiringSoonInspection));
      await tester.pumpAndSettle();

      expect(find.text('Vehicle insurance expires soon'), findsOneWidget);
      expect(find.text('3 of 4 Verified'), findsOneWidget);
      expect(find.text('ACTIVE INSPECTION'), findsOneWidget);
      expect(find.text('Vehicle Insurance (Pink Card)'), findsOneWidget);
      expect(find.text('Policy Document Shielded'), findsOneWidget);
      expect(find.text('Replace document'), findsOneWidget);
    });

    testWidgets('Renders State 4: Offline Partner Profile with sync alert and Activity tab', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverProfileStatus.offlineSyncAlert));
      await tester.pumpAndSettle();

      expect(find.textContaining("You're offline. Some info may be out of sync."), findsOneWidget);
      expect(find.text('New Partner'), findsOneWidget);
      expect(find.text('No reviews yet'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('BCC Fleet Unit #14'), findsOneWidget);
    });

    testWidgets('QA Matrix bar toggles between states when tapped', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverProfileStatus.activeOnline));
      await tester.pumpAndSettle();

      expect(find.text('Shajil Kunhumon'), findsOneWidget);

      final expiredChip = find.text('2: Expired Locked');
      expect(expiredChip, findsOneWidget);
      await tester.tap(expiredChip);
      await tester.pumpAndSettle();

      expect(find.text('Action Required'), findsOneWidget);
      expect(find.text('Upload New Licence'), findsOneWidget);
    });
  });
}
