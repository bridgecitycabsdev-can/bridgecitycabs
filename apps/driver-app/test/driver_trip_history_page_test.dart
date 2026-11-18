import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/history/history.dart';

void main() {
  group('DriverTripHistoryPage Widget Tests', () {
    late FakeDriverTripHistoryRepository repository;

    setUp(() {
      repository = FakeDriverTripHistoryRepository(latency: Duration.zero);
    });

    Widget createWidget({
      DriverTripHistoryStatus initialStatus = DriverTripHistoryStatus.gallery,
    }) {
      return MaterialApp(
        home: DriverTripHistoryPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders Screen 1 (Image 2): History & States Gallery properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverTripHistoryStatus.gallery));
      await tester.pumpAndSettle();

      // Top Portal & Status Bar
      expect(find.text('BRIDGE CITY'), findsOneWidget);
      expect(find.text('Driver Portal'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.textContaining("You're offline. Showing saved trips"), findsOneWidget);

      // Header row
      expect(find.text('History & States'), findsOneWidget);
      expect(find.text('Showcase & edge state gallery'), findsOneWidget);
      expect(find.text('Filter'), findsOneWidget);

      // Quick action demo chips
      expect(find.text('Demo Fare Modal'), findsOneWidget);
      expect(find.text('Demo Date Picker'), findsOneWidget);

      // Edge State: Zero Active Dispatches / No rides for today
      expect(find.text('ZERO ACTIVE DISPATCHES'), findsOneWidget);
      expect(find.text('No rides for today'), findsOneWidget);
      expect(find.text('Go online'), findsOneWidget);

      // Edge State: Period Notice
      expect(find.text('No rides found in selected period'), findsOneWidget);
      expect(find.textContaining('May 2024'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);

      // Trip Card (Cancelled state)
      expect(find.text('CANCELLED'), findsOneWidget);
      expect(find.text('19 Jun, 14:22'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);
      expect(find.text('Park Place Mall, 501 1 Ave S'), findsOneWidget);
      expect(find.text('Enmax Centre, Lethbridge'), findsOneWidget);
      expect(find.text('No fare recorded'), findsOneWidget);
      expect(find.text('View details'), findsOneWidget);

      // Syncing skeleton section
      expect(find.text('RECENT TRIPS (SYNCING)'), findsOneWidget);
      expect(find.text('Fetching records'), findsOneWidget);

      // Bottom Bar
      expect(find.text('Dispatch'), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('Renders Screen 2 (Image 3): Trip Details & Archived Manifest properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverTripHistoryStatus.tripDetail));
      await tester.pumpAndSettle();

      expect(find.text('Trip Details'), findsOneWidget);
      expect(find.text('ARCHIVED MANIFEST'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);

      // Route and stops
      expect(find.text('PICKUP • 6:21 PM'), findsOneWidget);
      expect(find.text('440 University Dr W'), findsOneWidget);
      expect(find.text('Univ of Lethbridge Student Union'), findsOneWidget);
      expect(find.text('DROPOFF • 6:35 PM'), findsOneWidget);
      expect(find.text('501 1st Ave S'), findsOneWidget);
      expect(find.text('Downtown Civic Centre'), findsOneWidget);

      // Metrics
      expect(find.text('DISTANCE'), findsOneWidget);
      expect(find.text('4.52 km'), findsOneWidget);
      expect(find.text('DURATION'), findsOneWidget);
      expect(find.text('14 min'), findsOneWidget);
      expect(find.text('AVG SPEED'), findsOneWidget);
      expect(find.text('38 km/h'), findsOneWidget);

      // Fare Breakdown
      expect(find.text('Fare breakdown'), findsOneWidget);
      expect(find.text('CAD Currency'), findsOneWidget);
      expect(find.text('Gross meter fare'), findsOneWidget);
      expect(find.text('\$21.50'), findsOneWidget);
      expect(find.text('Passenger Tip (100% kept)'), findsOneWidget);
      expect(find.text('+\$3.00'), findsOneWidget);
      expect(find.text('Bridge City Cabs fee (15%)'), findsOneWidget);
      expect(find.text('-\$3.23'), findsOneWidget);
      expect(find.text('Tax (GST 5% remitted)'), findsOneWidget);
      expect(find.text('-\$1.08'), findsOneWidget);
      expect(find.text('Your net earning'), findsOneWidget);
      expect(find.text('\$20.19 CAD'), findsOneWidget);
      expect(find.text('Card paid via app'), findsOneWidget);
      expect(find.text('•••• 8842'), findsOneWidget);

      // Passenger Card
      expect(find.text('Jordan S.'), findsOneWidget);
      expect(find.text('Passenger verification verified'), findsOneWidget);
      expect(find.text('4.9 • 114 rides'), findsOneWidget);

      // Manifest Audit & Report button
      expect(find.text('Trip ID: BC-123456'), findsOneWidget);
      expect(find.text('Report an issue with this trip'), findsOneWidget);
    });

    testWidgets('Renders Screen 3 (Image 1): Period Filter Sheet properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverTripHistoryStatus.filterSheet));
      await tester.pumpAndSettle();

      expect(find.text('Earnings period'), findsOneWidget);
      expect(find.text('Select statement view or custom dates'), findsOneWidget);

      // Periods
      expect(find.text('Today'), findsOneWidget);
      expect(find.text("Today's active shift • \$41.77"), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('24 Jun – 30 Jun • \$53.93'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
      expect(find.text('1 Jun – 30 Jun • \$1,248.50'), findsOneWidget);
      expect(find.text('Last month'), findsOneWidget);
      expect(find.text('1 May – 31 May • \$2,840.10'), findsOneWidget);
      expect(find.text('Custom date range'), findsOneWidget);

      // Custom Range box
      expect(find.text('CONFIGURE FILTER RANGE'), findsOneWidget);
      expect(find.text('START DATE'), findsOneWidget);
      expect(find.text('10 Jun 2024'), findsOneWidget);
      expect(find.text('END DATE'), findsOneWidget);
      expect(find.text('24 Jun 2024'), findsOneWidget);
      expect(find.text('14 days selected (historical ledger)'), findsOneWidget);

      // Apply button
      expect(find.text('Apply period filter'), findsOneWidget);
    });

    testWidgets('QA switcher toggles screens interactively in widget tree', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverTripHistoryStatus.gallery));
      await tester.pumpAndSettle();

      expect(find.text('History & States'), findsOneWidget);

      // Switch to Trip Details via QA chip
      await tester.tap(find.text('2. Trip Details & Manifest'));
      await tester.pumpAndSettle();
      expect(find.text('Trip Details'), findsOneWidget);
      expect(find.text('ARCHIVED MANIFEST'), findsOneWidget);

      // Switch to Filter Sheet via QA chip
      await tester.tap(find.text('3. Period Filter Sheet'));
      await tester.pumpAndSettle();
      expect(find.text('Earnings period'), findsOneWidget);
      expect(find.text('Apply period filter'), findsOneWidget);

      // Switch to Empty State via QA chip
      await tester.tap(find.text('4. Empty State (Zero Dispatches)'));
      await tester.pumpAndSettle();
      expect(find.text('ZERO ACTIVE DISPATCHES'), findsOneWidget);
    });
  });
}
