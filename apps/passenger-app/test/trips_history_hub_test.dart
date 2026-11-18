import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/trip_history/trip_history.dart';

void main() {
  Widget buildTestWidget({TripHistoryRepository? repository}) {
    return MaterialApp(
      home: TripsHistoryHubPage(repository: repository),
    );
  }

  group('TripsHistoryHubPage Unit & Widget Tests', () {
    testWidgets('renders Screen 1 with filters, summary, and ride cards', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify App Bar
      expect(find.text('Trips'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsWidgets);

      // Verify Pull to refresh hint
      expect(find.text('↓ Pull to refresh'), findsOneWidget);

      // Verify Date Filters
      expect(find.text('Today ●'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);

      // Verify Summary Row
      expect(find.text('Trips: 4'), findsOneWidget);
      expect(find.text('\$82.40 CAD'), findsOneWidget);

      // Verify Group Headers
      expect(find.textContaining('Sat, 22 Aug · 2 rides · \$38.56 CAD'), findsOneWidget);
      expect(find.textContaining('Fri, 21 Aug · 2 rides · \$43.84 CAD'), findsOneWidget);

      // Verify Ride Cards details
      expect(find.text('440 University Dr W, Lethbridge'), findsOneWidget);
      expect(find.text('501 1st Ave S, Downtown Core'), findsOneWidget);
      expect(find.text('\$20.16 CAD'), findsOneWidget);
      expect(find.text('Camry SE'), findsOneWidget);

      // Verify Canceled card details
      expect(find.text('Lethbridge Airport (YQL)'), findsOneWidget);
      expect(find.text('Galt Museum, 502 1 St S'), findsOneWidget);
      expect(find.text('No charge'), findsOneWidget);
      expect(find.text('Canceled'), findsOneWidget);

      // Verify footer
      expect(find.text('Loading more trips...'), findsOneWidget);
      expect(find.text(TripHistoryConfig.bylawShortNotice), findsOneWidget);
    });

    testWidgets('tapping a trip card opens Screen 2 (Trip Quick Actions Sheet)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap first trip card
      final firstCard = find.text('440 University Dr W, Lethbridge');
      expect(firstCard, findsOneWidget);
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Verify Screen 2 Quick Actions Sheet content
      expect(find.text('Trip #BC-123456'), findsOneWidget);
      expect(find.text('View receipt'), findsOneWidget);
      expect(find.text('Report a problem'), findsOneWidget);
      expect(find.text('Rate your driver'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Rating window closes in 21 hours'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text(TripHistoryConfig.permanentRecordNotice), findsOneWidget);

      // Tap Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Sheet is closed
      expect(find.text('View receipt'), findsNothing);
    });

    testWidgets('tapping calendar button opens Screen 3 (Date Range Filter Sheet)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap calendar icon
      final calendarBtn = find.byIcon(Icons.calendar_today_outlined);
      expect(calendarBtn, findsWidgets);
      await tester.tap(calendarBtn.first);
      await tester.pumpAndSettle();

      // Verify Screen 3 content
      expect(find.text('Select date range'), findsOneWidget);
      expect(find.text('Filter completed trips in Southern Alberta'), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('August 2026'), findsOneWidget);

      // Verify range pill
      expect(find.textContaining('15 Aug 2026 – 22 Aug 2026'), findsOneWidget);
      expect(find.text('8 days'), findsOneWidget);
      expect(find.text('Apply range'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Tap Apply range
      await tester.tap(find.text('Apply range'));
      await tester.pumpAndSettle();

      // Sheet is closed and filter active
      expect(find.text('Select date range'), findsNothing);
    });
  });
}
