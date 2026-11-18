import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/past_trip_detail/past_trip_detail.dart';

void main() {
  Widget createTestWidget({String? tripId}) {
    return MaterialApp(
      home: PassengerTripDetailPage(tripId: tripId),
    );
  }

  group('PassengerTripDetailPage Widget Tests', () {
    testWidgets('renders Screen 1: segmented toggle, metered breakdown, and actions',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // App bar title
      expect(find.text('Passenger Trip Detail'), findsOneWidget);

      // Segment Toggle
      expect(find.text('Completed (Card)'), findsOneWidget);
      expect(find.text('Completed (Cash)'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);

      // Route schematic & Trip ID
      expect(find.text('BC-123456'), findsOneWidget);
      expect(find.text('Sat, 22 Aug · 2:48 PM'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Whoop-Up Dr Route'), findsOneWidget);
      expect(find.text('Oldman River Crossing'), findsOneWidget);
      expect(find.textContaining('440 University Dr W'), findsWidgets);
      expect(find.textContaining('501 1st Ave S'), findsWidgets);
      expect(find.text('4.52 km'), findsOneWidget);
      expect(find.text('12 min transit'), findsOneWidget);
      expect(find.text('22°C Clear'), findsOneWidget);

      // Driver & Vehicle Card
      expect(find.text('Toyota Camry SE'), findsOneWidget);
      expect(find.text('Hybrid'), findsOneWidget);
      expect(find.text('Marcus V.'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('BCF-402'), findsOneWidget);
      expect(find.textContaining('Bylaw License #LTC-8841'), findsOneWidget);

      // Metered Fare Summary Card
      expect(find.text('Fare summary'), findsOneWidget);
      expect(find.text('Metered Rate #1'), findsOneWidget);
      expect(find.text('Base Drop Rate'), findsOneWidget);
      expect(find.text('\$4.50 CAD'), findsOneWidget);
      expect(find.text('Distance (4.52 km)'), findsOneWidget);
      expect(find.text('\$11.30 CAD'), findsOneWidget);
      expect(find.text('Waiting / Transit Delay'), findsOneWidget);
      expect(find.text('\$3.40 CAD'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('\$19.20 CAD'), findsOneWidget);
      expect(find.text('GST (5% Alberta)'), findsOneWidget);
      expect(find.text('\$0.96 CAD'), findsOneWidget);
      expect(find.text('Total Charged'), findsOneWidget);
      expect(find.text('\$20.16 CAD'), findsOneWidget);
      expect(find.text('Visa •••• 4242'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);

      // Action List Tiles
      expect(find.text('Rate your driver'), findsOneWidget);
      expect(find.text('Feedback window closes in 24 hours'), findsOneWidget);
      expect(find.text('Download official tax receipt'), findsOneWidget);
      expect(find.text('Alberta CRA compliant PDF receipt'), findsOneWidget);
      expect(find.text('Report a problem'), findsOneWidget);
      expect(find.textContaining('Bylaw 6138'), findsOneWidget);
    });

    testWidgets('renders Screen 2: QA scenario inspector, map view, and return booking bar',
        (tester) async {
      await tester.pumpWidget(createTestWidget(tripId: 'Trip #BCC-84920'));
      await tester.pumpAndSettle();

      // QA Scenario Inspector
      expect(find.text('QA SCENARIO INSPECTOR'), findsOneWidget);
      expect(find.text('1 / 9 Active'), findsOneWidget);
      expect(find.text('1. Completed (Card)'), findsOneWidget);
      expect(find.text('2. Completed (Cash)'), findsOneWidget);

      // Map Card
      expect(find.text('Trip #BCC-84920'), findsOneWidget);
      expect(find.text('Oct 24, 2:45 PM · 18 min'), findsOneWidget);
      expect(find.text('Coalhurst'), findsOneWidget);
      expect(find.text('Pavan Park'), findsOneWidget);
      expect(find.text('Hardieville'), findsOneWidget);

      // Route
      expect(find.text('Park Place Mall, 501 1 Ave S'), findsOneWidget);
      expect(find.text('University of Lethbridge, Hall 3'), findsOneWidget);

      // Driver
      expect(find.text('Harpreet S.'), findsOneWidget);
      expect(find.text('4.96'), findsOneWidget);
      expect(find.textContaining('Toyota Camry Hybrid · Alta 93-R10'), findsOneWidget);

      // Payment
      expect(find.text('Amount Paid'), findsOneWidget);
      expect(find.text('\$22.10'), findsOneWidget);
      expect(find.text('Auto-charged & Settled'), findsOneWidget);

      // Bottom Return Bar
      expect(find.text('Get Receipt'), findsOneWidget);
      expect(find.text('Book Return'), findsOneWidget);
    });
  });
}
