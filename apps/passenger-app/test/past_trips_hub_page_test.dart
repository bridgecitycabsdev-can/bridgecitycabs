import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/past_trip_detail/past_trip_detail.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: PastTripsHubPage(),
    );
  }

  group('PastTripsHubPage Widget Tests', () {
    testWidgets('renders Screen 3: last trip saved route and coming soon empty state',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // App bar
      expect(find.text('Past Trips'), findsOneWidget);

      // Section header
      expect(find.text('YOUR LAST TRIP'), findsOneWidget);
      expect(find.text('Saved route'), findsOneWidget);

      // Last trip card
      expect(find.text('Sat, 22 Aug · 2:48 PM'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('PICKUP'), findsOneWidget);
      expect(find.text('440 University Dr W, Lethbridge'), findsOneWidget);
      expect(find.text('DROPOFF'), findsOneWidget);
      expect(find.text('501 1st Ave S, Downtown Lethbr...'), findsOneWidget);
      expect(find.text('\$20.16 CAD'), findsOneWidget);
      expect(find.text('Visa •••• 4242'), findsOneWidget);
      expect(find.text('View details'), findsOneWidget);

      // Coming soon box
      expect(find.text('Past trips are coming soon'), findsOneWidget);
      expect(
        find.textContaining('For now, you can find your latest trip receipt'),
        findsOneWidget,
      );
      expect(find.text('Open notifications'), findsOneWidget);
      expect(find.text('Contact support'), findsOneWidget);

      // Email receipt footer
      expect(
        find.textContaining('Trip receipts and invoices are also sent'),
        findsOneWidget,
      );
    });
  });
}
