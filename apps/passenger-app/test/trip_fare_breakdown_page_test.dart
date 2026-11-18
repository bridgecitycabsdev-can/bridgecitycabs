import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/trip_history/trip_history.dart';

void main() {
  Widget createTestWidget({
    String? tripId,
    TripPaymentScenario? initialScenario,
    TripHistoryRepository? repository,
  }) {
    return MaterialApp(
      home: TripFareBreakdownPage(
        tripId: tripId,
        initialScenario: initialScenario,
        repository: repository,
      ),
    );
  }

  group('TripFareBreakdownPage Widget Tests (Screen 2 & 3)', () {
    testWidgets('renders route telemetry, driver card, metered breakdown and audit footer', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Trip Fare Breakdown'), findsOneWidget);
      expect(find.text('QA Scenario Inspector'), findsOneWidget);
      expect(find.text('v3.4.2 • Lethbridge'), findsOneWidget);

      // QA Scenario Selector
      expect(find.text('1. Card Paid'), findsOneWidget);
      expect(find.text('2. Cash Paid'), findsOneWidget);
      expect(find.text('3. Cash Pending'), findsOneWidget);

      // Trip Route Telemetry
      expect(find.text('Trip #BC-123456'), findsOneWidget);
      expect(find.text('Bridge City Cabs • Priority Express'), findsOneWidget);
      expect(find.text('Lethbridge Central Corridor'), findsOneWidget);
      expect(find.text('Whoop-Up Dr Route'), findsOneWidget);
      expect(find.text('4.52 km'), findsWidgets);
      expect(find.text('12 min transit'), findsOneWidget);
      expect(find.text('22°C Clear'), findsOneWidget);
      expect(find.text('440 University Dr W, Lethbridge'), findsOneWidget);
      expect(find.text('501 1st Ave S, Downtown Lethbridge'), findsOneWidget);

      // Driver info
      expect(find.text('Marcus V.'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('Camry SE • Silver Gray'), findsOneWidget);
      expect(find.text('HYBRID'), findsOneWidget);
      expect(find.text('BCF-402'), findsOneWidget);
      expect(find.text('Bylaw License #LTC-8841'), findsOneWidget);
      expect(find.text('Verified Operator'), findsOneWidget);

      // Metered Fare Summary
      expect(find.text('Fare summary'), findsOneWidget);
      expect(find.text('Metered Rate #1'), findsOneWidget);
      expect(find.text('Base Drop Rate'), findsOneWidget);
      expect(find.text('\$4.50 CAD'), findsOneWidget);
      expect(find.text('\$11.30 CAD'), findsOneWidget);
      expect(find.text('Waiting / Transit Delay'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('\$19.20 CAD'), findsOneWidget);
      expect(find.text('GST (5% Alberta)'), findsOneWidget);
      expect(find.text('\$0.96 CAD'), findsOneWidget);
      expect(find.text('TOTAL CHARGED'), findsOneWidget);
      expect(find.text('\$20.16 CAD'), findsOneWidget);
      expect(find.text('Visa •••• 4242'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);

      // Action Tiles
      expect(find.text('Rate your driver'), findsOneWidget);
      expect(find.text('Download official tax receipt'), findsOneWidget);
      expect(find.text('Report a problem'), findsOneWidget);

      // Bylaw 6138 notice
      expect(find.text(TripHistoryConfig.bylawAuditNotice), findsOneWidget);
    });

    testWidgets('switching scenario to 2. Cash Paid updates payment badge', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final cashPaidPill = find.text('2. Cash Paid');
      expect(cashPaidPill, findsOneWidget);

      await tester.tap(cashPaidPill);
      await tester.pumpAndSettle();

      expect(find.text('Cash Payment'), findsOneWidget);
      expect(find.text('Paid in Cash'), findsOneWidget);
    });

    testWidgets('tapping download receipt triggers CRA compliant receipt event', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final downloadTile = find.text('Download official tax receipt');
      expect(downloadTile, findsOneWidget);

      await tester.tap(downloadTile);
      await tester.pumpAndSettle();

      expect(find.textContaining('CRA compliant'), findsOneWidget);
    });
  });
}
