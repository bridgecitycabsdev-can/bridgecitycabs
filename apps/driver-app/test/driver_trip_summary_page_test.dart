import 'package:driver_app/features/trip_summary/trip_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverTripSummaryPage Widget Tests', () {
    late FakeDriverTripSummaryRepository repository;

    setUp(() {
      repository = FakeDriverTripSummaryRepository();
    });

    Widget createWidget({
      DriverTripSummaryStatus initialStatus =
          DriverTripSummaryStatus.cardSettled,
    }) {
      return MaterialApp(
        home: DriverTripSummaryPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders Screenshot 3: Card Auto-Settled Summary properly',
        (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripSummaryStatus.cardSettled,
      ));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('BRIDGE CITY CABS'), findsOneWidget);
      expect(find.text('Trip Summary & Fare Breakdown'), findsOneWidget);
      expect(find.text('Trip completed'), findsOneWidget);
      expect(
        find.text('Payment processed via Stripe Fleet Sync'),
        findsOneWidget,
      );
      expect(find.text('TRIP ID BC-123456'), findsOneWidget);

      // QA bar
      expect(find.text('1. Card Summary'), findsOneWidget);
      expect(find.text('2. Cash Payment Due'), findsOneWidget);
      expect(find.text('3. Rate Passenger'), findsOneWidget);
      expect(find.text('4. 6 Edge States'), findsOneWidget);

      // Card Auto-Settled Card
      expect(find.text('AUTO-SETTLED'), findsOneWidget);
      expect(find.text('Paid by card \$22.10'), findsOneWidget);
      expect(
        find.text('VISA ending in •••• 8842 • Contactless In-App'),
        findsOneWidget,
      );
      expect(
        find.text(
          'No payment needed from passenger. Your net earnings of \$18.78 CAD will appear in your bi-weekly direct deposit.',
        ),
        findsOneWidget,
      );

      // Trip Log
      expect(find.text('TRIP LOG'), findsOneWidget);
      expect(find.text('Lethbridge Central Zone'), findsOneWidget);
      expect(find.text('440 University Dr W'), findsOneWidget);
      expect(find.text('501 1st Ave S'), findsOneWidget);
      expect(find.text('4.52 km'), findsOneWidget);
      expect(find.text('14 mins'), findsOneWidget);
      expect(find.text('Alex M.'), findsOneWidget);

      // Fare Breakdown
      expect(find.text('Fare breakdown'), findsOneWidget);
      expect(find.text('Gross metered fare'), findsOneWidget);
      expect(find.text('\$22.10'), findsOneWidget);
      expect(find.text('Bridge City Fleet fee (15%)'), findsOneWidget);
      expect(find.text('-\$3.32'), findsOneWidget);
      expect(find.text('\$18.78 CAD'), findsOneWidget);

      // Actions
      expect(find.text('Done • Return to Dispatch'), findsOneWidget);
      expect(find.text('View receipt'), findsOneWidget);
      expect(find.text('Trip issue'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 4: Cash Payment Due Summary properly',
        (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripSummaryStatus.cashDue,
      ));
      await tester.pumpAndSettle();

      // Top info
      expect(find.text('Trip completed'), findsOneWidget);
      expect(
        find.text('Lethbridge West Campus → Downtown Core'),
        findsOneWidget,
      );

      // Cash Payment Due Card
      expect(find.text('CASH PAYMENT DUE'), findsOneWidget);
      expect(find.text('COLLECT FROM PASSENGER'), findsOneWidget);
      expect(find.text('\$22.10 CAD'), findsOneWidget);
      expect(find.text('Meter lock'), findsOneWidget);

      // Fast Change Calculator
      expect(find.text('FAST CHANGE CALCULATOR'), findsOneWidget);
      expect(find.text('If passenger gives \$25'), findsOneWidget);
      expect(find.text('Return \$2.90 change'), findsOneWidget);
      expect(find.text('If passenger gives \$30'), findsOneWidget);
      expect(find.text('Return \$7.90 change'), findsOneWidget);

      // Route Details
      expect(find.text('ROUTE DETAILS'), findsOneWidget);
      expect(find.text('Lethbridge Transit Zone'), findsOneWidget);
      expect(find.text('38 km/h'), findsOneWidget);

      // Official Receipt Itemization
      expect(find.text('OFFICIAL RECEIPT ITEMIZATION'), findsOneWidget);
      expect(find.text('Subtotal meter fare'), findsOneWidget);
      expect(find.text('\$21.05'), findsOneWidget);
      expect(find.text('GST (5% Alberta Base)'), findsOneWidget);
      expect(find.text('\$1.05'), findsOneWidget);
      expect(find.text('Total passenger fare'), findsOneWidget);

      // Action button
      expect(find.text('Cash collected'), findsOneWidget);
      expect(find.text('Problem collecting payment?'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 5 Top: Rate Passenger Modal properly',
        (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripSummaryStatus.ratePassenger,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Rate passenger'), findsOneWidget);
      expect(
        find.text('Trip #BC-9942 • 4th Ave S to Scenic Dr'),
        findsOneWidget,
      );
      expect(find.text('Alex M.'), findsOneWidget);
      expect(
        find.text('Lethbridge Rider • 42 rides completed'),
        findsOneWidget,
      );
      expect(find.text('\$18.78 Cash Trip'), findsOneWidget);

      // Experience & stars
      expect(find.text('TAP TO RATE EXPERIENCE'), findsOneWidget);
      expect(find.text('4.5 - Great passenger'), findsOneWidget);

      // Driver Quick Tags
      expect(find.text('DRIVER QUICK TAGS'), findsOneWidget);
      expect(find.text('Polite'), findsOneWidget);
      expect(find.text('On time'), findsOneWidget);
      expect(find.text('Clean'), findsOneWidget);
      expect(find.text('Respectful'), findsOneWidget);

      // Dispatcher Notes
      expect(find.text('DISPATCHER NOTES'), findsOneWidget);
      expect(find.text('Submit rating'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 5 Bottom: 6 Active Trip Edge States Gallery',
        (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripSummaryStatus.edgeStatesGallery,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Active Trip Edge States'), findsOneWidget);
      expect(find.text('6 States'), findsOneWidget);

      // State 1
      expect(find.text('STATE 1 • PENDING VERIFICATION'), findsOneWidget);
      expect(find.text('Confirming cash on server...'), findsOneWidget);

      // State 2
      expect(find.text('STATE 2 • SUCCESS TOAST'), findsOneWidget);
      expect(find.text('Payment confirmed'), findsOneWidget);

      // State 3
      expect(find.text('STATE 3 • NETWORK ERROR'), findsOneWidget);
      expect(find.text("Couldn't confirm payment"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // State 4
      expect(find.text('STATE 4 • AMBER CAUTION'), findsOneWidget);
      expect(find.text("Card payment didn't go through"), findsOneWidget);

      // State 5
      expect(find.text('STATE 5 • CRITICAL IN-RIDE SHEET'), findsOneWidget);
      expect(find.text('Send emergency alert?'), findsOneWidget);
      expect(find.text('SOS Send SOS'), findsOneWidget);

      // State 6
      expect(find.text('STATE 6 • OFFLINE QUEUE'), findsOneWidget);
      expect(find.text("You're offline"), findsOneWidget);

      // Footer
      expect(
        find.text('Bridge City Dispatch • Lethbridge, AB'),
        findsOneWidget,
      );
    });

    testWidgets('QA Bar interactively toggles between all 4 summary screens',
        (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripSummaryStatus.cardSettled,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Paid by card \$22.10'), findsOneWidget);

      // Tap Cash Payment Due
      await tester.tap(find.text('2. Cash Payment Due'));
      await tester.pumpAndSettle();
      expect(find.text('CASH PAYMENT DUE'), findsOneWidget);
      expect(find.text('FAST CHANGE CALCULATOR'), findsOneWidget);

      // Tap Rate Passenger
      await tester.tap(find.text('3. Rate Passenger'));
      await tester.pumpAndSettle();
      expect(find.text('Rate passenger'), findsOneWidget);
      expect(find.text('TAP TO RATE EXPERIENCE'), findsOneWidget);

      // Tap 6 Edge States
      await tester.tap(find.text('4. 6 Edge States'));
      await tester.pumpAndSettle();
      expect(find.text('Active Trip Edge States'), findsOneWidget);
      expect(find.text('STATE 1 • PENDING VERIFICATION'), findsOneWidget);
    });
  });
}
