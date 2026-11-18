import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/trip_history/trip_history.dart';

void main() {
  Widget createTestWidget({TripRecord? initialTrip, TripHistoryRepository? repository}) {
    return MaterialApp(
      home: TripHistoryPage(
        initialTrip: initialTrip,
        repository: repository,
      ),
    );
  }

  group('TripHistoryPage Widget Tests (Screen 1)', () {
    testWidgets('renders last trip summary and coming soon section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Trip Fare Breakdown'), findsOneWidget);
      expect(find.text('YOUR LAST TRIP'), findsOneWidget);
      expect(find.text('• 1 recent record'), findsOneWidget);

      // Last Trip Card
      expect(find.text('Sat, 22 Aug • 2:48 PM'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('440 University Dr W, Lethbridge'), findsOneWidget);
      expect(find.text('501 1st Ave S, Downtown Lethbridge'), findsOneWidget);
      expect(find.text('\$20.16 CAD • Visa •••• 4242'), findsOneWidget);
      expect(find.text('View details'), findsOneWidget);

      // Coming soon section
      expect(find.text(TripHistoryConfig.comingSoonTitle), findsOneWidget);
      expect(find.text(TripHistoryConfig.comingSoonSubtitle), findsOneWidget);
      expect(find.text('Open notifications'), findsOneWidget);
      expect(find.text('Contact support'), findsOneWidget);
      expect(find.text(TripHistoryConfig.emailReceiptNotice), findsOneWidget);
    });

    testWidgets('tapping view details triggers navigation to breakdown page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final detailsFinder = find.text('View details');
      expect(detailsFinder, findsOneWidget);

      await tester.tap(detailsFinder);
      await tester.pumpAndSettle();

      // Now on TripFareBreakdownPage
      expect(find.text('QA Scenario Inspector'), findsOneWidget);
      expect(find.text('Fare summary'), findsOneWidget);
      expect(find.text('TOTAL CHARGED'), findsOneWidget);
    });
  });
}
