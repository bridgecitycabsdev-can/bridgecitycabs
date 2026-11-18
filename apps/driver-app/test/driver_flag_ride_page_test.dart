import 'package:driver_app/features/flag_ride/flag_ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverFlagRidePage Widget Tests', () {
    late FakeDriverFlagRideRepository repository;

    setUp(() {
      repository = FakeDriverFlagRideRepository();
    });

    Widget createWidget({
      DriverFlagRideStatus initialStatus = DriverFlagRideStatus.startFlagRide,
    }) {
      return MaterialApp(
        home: DriverFlagRidePage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders Screenshot 1: Start A Flag Ride properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverFlagRideStatus.startFlagRide,
      ));
      await tester.pumpAndSettle();

      // App bar & QA bar
      expect(find.text('Start A Flag Ride'), findsOneWidget);
      expect(find.text('1. Start Ride'), findsOneWidget);
      expect(find.text('2. In Progress'), findsOneWidget);
      expect(find.text('3. Complete'), findsOneWidget);
      expect(find.text('4. Edge States'), findsOneWidget);

      // Top map telemetry
      expect(find.text('GPS SIGNAL: HIGH'), findsOneWidget);
      expect(find.text('Downtown Zone 1'), findsOneWidget);
      expect(find.text('FLAGGED HERE'), findsOneWidget);

      // Sheet content
      expect(
        find.text('Use this when a passenger waves you down on the street.'),
        findsOneWidget,
      );
      expect(find.text('PICKUP (DETECTED)'), findsOneWidget);
      expect(find.text('Current Location'), findsOneWidget);
      expect(find.text('524 4th Ave S, Downtown Lethbridge'), findsOneWidget);
      expect(find.text('DROP-OFF (OPTIONAL)'), findsOneWidget);
      expect(
        find.text('Tap to search destination or leave unmetered...'),
        findsOneWidget,
      );

      // Vehicle class and payment
      expect(find.text('VEHICLE CLASS'), findsOneWidget);
      expect(find.text('Medium (Camry Hybrid)'), findsOneWidget);
      expect(find.text('Car #104 Assigned'), findsOneWidget);
      expect(find.text('PAYMENT METHOD'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Flag rides cash only'), findsOneWidget);

      // Passenger stepper
      expect(find.text('Passenger count'), findsOneWidget);
      expect(find.text('Standard in-cab seating (1-4)'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Metered mode estimated fare
      expect(find.text('ESTIMATED FARE'), findsOneWidget);
      expect(find.text('METERED MODE'), findsOneWidget);
      expect(find.text('\$15.00 CAD'), findsOneWidget);

      // Action button
      expect(find.text('Start flag ride →'), findsOneWidget);
    });

    testWidgets('Passenger stepper increments and decrements count', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverFlagRideStatus.startFlagRide,
      ));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);

      // Tap + button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      // Tap + button again
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);

      // Tap - button
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 2: Flag Ride In Progress properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverFlagRideStatus.flagInProgress,
      ));
      await tester.pumpAndSettle();

      // Top bar & badge
      expect(find.text('Flag Ride In Progress'), findsOneWidget);
      expect(find.text('Flag • 2.4 km • 06:35'), findsOneWidget);
      expect(find.text('CAB #42'), findsOneWidget);
      expect(find.text('48 KM/H'), findsOneWidget);

      // Progress bar & drop off
      expect(find.text('Trip Progress (57%)'), findsOneWidget);
      expect(find.text('Est. Remaining: 1.8 km'), findsOneWidget);
      expect(find.text('Lethbridge Downtown'), findsOneWidget);
      expect(find.text('~4 mins to West Side'), findsOneWidget);
      expect(
        find.text('440 University Dr W, West Lethbridge, AB T1K 3M4'),
        findsOneWidget,
      );

      // Meter & computed fare
      expect(find.text('Meter Running'), findsOneWidget);
      expect(
        find.text('Standard Rate: \$3.80 base + \$1.85/km'),
        findsOneWidget,
      );
      expect(find.text('\$12.40'), findsOneWidget);

      // Actions & bylaw notice
      expect(find.text('↗ Navigate Turn-by-Turn ↗'), findsOneWidget);
      expect(find.text('⚐ END TRIP →'), findsOneWidget);
      expect(
        find.text('City of Lethbridge Bylaw 6138 • Street hail meter telemetry active'),
        findsOneWidget,
      );
    });

    testWidgets('Renders Screenshot 3: Flag Ride Complete properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverFlagRideStatus.flagComplete,
      ));
      await tester.pumpAndSettle();

      // Top bar
      expect(find.text('Flag Ride Complete'), findsOneWidget);
      expect(find.text('Trip Completed'), findsOneWidget);
      expect(find.text('FLAG #FL-88214'), findsOneWidget);
      expect(
        find.text('Street Hail / Flag Ride • Unit #42 (Lethbridge)'),
        findsOneWidget,
      );

      // Collect Card
      expect(find.text('COLLECT FROM PASSENGER'), findsOneWidget);
      expect(find.text('\$18.60 CAD'), findsOneWidget);

      // Quick change
      expect(find.text('QUICK CHANGE GUIDE'), findsOneWidget);
      expect(
        find.text('If passenger gives \$20.00 -> Return \$1.40'),
        findsOneWidget,
      );
      expect(
        find.text('If passenger gives \$25.00 -> Return \$6.40'),
        findsOneWidget,
      );

      // Route details
      expect(find.text('524 4th Ave S (Downtown)'), findsOneWidget);
      expect(find.text('440 University Dr W (West Campus)'), findsOneWidget);
      expect(find.text('4.2 km'), findsOneWidget);
      expect(find.text('12 mins'), findsOneWidget);
      expect(find.text('2 Pax'), findsOneWidget);

      // Fare Breakdown
      expect(find.text('Subtotal Meter Fare'), findsOneWidget);
      expect(find.text('\$17.71 CAD'), findsOneWidget);
      expect(find.text('GST (5% Alberta Base)'), findsOneWidget);
      expect(find.text('\$0.89 CAD'), findsOneWidget);
      expect(find.text('\$15.81 CAD'), findsOneWidget);

      // Actions
      expect(find.text('✓ Cash Collected (\$18.60)'), findsOneWidget);
      expect(find.text('Problem collecting payment?'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 4: Flag Ride Edge States and toggles categories',
        (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverFlagRideStatus.edgeStates,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Flag Ride Edge States'), findsOneWidget);
      expect(
        find.text('CITY OF LETHBRIDGE BYLAW 6141 COMPLIANT • Fleet Unit #42'),
        findsOneWidget,
      );

      // Initial edge category: 1. GPS Lost (Telemetry fault)
      expect(find.text('1. GPS Lost'), findsOneWidget);
      expect(find.text('2. Active Route'), findsOneWidget);
      expect(find.text('3. Offline Lock'), findsOneWidget);
      expect(find.text("Can't find your location"), findsOneWidget);
      expect(find.text('Open device settings →'), findsOneWidget);

      // Switch to 2. Active Route
      await tester.tap(find.text('2. Active Route'));
      await tester.pumpAndSettle();

      expect(find.text('Finish current trip before flagging'), findsOneWidget);
      expect(find.text('Return to active navigation'), findsOneWidget);

      // Switch to 3. Offline Lock
      await tester.tap(find.text('3. Offline Lock'));
      await tester.pumpAndSettle();

      expect(find.text("You're offline - Ledger Secured"), findsOneWidget);
      expect(find.text('Hold Meter'), findsOneWidget);
      expect(find.text('End Offline Ride'), findsOneWidget);
    });

    testWidgets('QA bar switches between views seamlessly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverFlagRideStatus.startFlagRide,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Start flag ride →'), findsOneWidget);

      // Switch to 2. In Progress
      await tester.tap(find.text('2. In Progress'));
      await tester.pumpAndSettle();
      expect(find.text('⚐ END TRIP →'), findsOneWidget);

      // Switch to 3. Complete
      await tester.tap(find.text('3. Complete'));
      await tester.pumpAndSettle();
      expect(find.text('✓ Cash Collected (\$18.60)'), findsOneWidget);

      // Switch to 4. Edge States
      await tester.tap(find.text('4. Edge States'));
      await tester.pumpAndSettle();
      expect(
        find.text('CITY OF LETHBRIDGE BYLAW 6141 COMPLIANT • Fleet Unit #42'),
        findsOneWidget,
      );
    });
  });
}
