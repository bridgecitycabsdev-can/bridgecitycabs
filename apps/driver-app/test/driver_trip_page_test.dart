import 'package:driver_app/features/trip/trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverTripPage Widget Tests', () {
    late FakeDriverTripRepository repository;

    setUp(() {
      repository = FakeDriverTripRepository();
    });

    Widget createWidget({
      DriverTripStatus initialStatus = DriverTripStatus.headingToPickup,
    }) {
      return MaterialApp(
        home: DriverTripPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders Screen 1 (Image 1): Heading to pickup state properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripStatus.headingToPickup,
      ));
      await tester.pumpAndSettle();

      // Top status pill
      expect(find.text('Heading to pickup • 4 min • 1.2 km'), findsOneWidget);

      // QA bar
      expect(find.text('1. Heading'), findsOneWidget);
      expect(find.text('2. Waiting (2:33)'), findsOneWidget);
      expect(find.text('3. Cancel Modal'), findsOneWidget);
      expect(find.text('4. Weak GPS'), findsOneWidget);

      // Map pills
      expect(find.text('Next: Turn right on 3rd Ave S'), findsOneWidget);
      expect(find.text('48 km/h'), findsOneWidget);

      // Passenger row
      expect(find.text('Alex M.'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('BC-123456'), findsOneWidget);
      expect(find.text('SEDAN • CASH'), findsOneWidget);

      // Pickup details
      expect(find.text('PICKUP ADDRESS'), findsOneWidget);
      expect(find.text('440 University Dr W, Lethbridge'), findsOneWidget);
      expect(find.text('Lethbridge West Campus Loop'), findsOneWidget);
      expect(
        find.text('Pickup note: Blue door, side entrance'),
        findsOneWidget,
      );

      // Badges
      expect(find.text('Scheduled • Fri 3:30 PM'), findsOneWidget);
      expect(find.text('Luggage assist requested'), findsOneWidget);

      // Action buttons
      expect(find.text('Navigate to pickup'), findsOneWidget);
      expect(find.text("I've arrived"), findsOneWidget);
      expect(
        find.text(
          'Get closer to the pickup point to continue (120m away)',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel trip'), findsOneWidget);
    });

    testWidgets('Renders Screen 2 (Image 2): Waiting for passenger (Arrived) state', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripStatus.waitingForPassenger,
      ));
      await tester.pumpAndSettle();

      // Top status pill
      expect(find.text('Waiting for passenger • Arrived'), findsOneWidget);

      // Passenger and service header
      expect(find.text('TRIP ID BC-123456'), findsOneWidget);
      expect(find.text('Lethbridge West'), findsOneWidget);
      expect(find.text('Alex M.'), findsOneWidget);
      expect(find.text('4.8 ★'), findsOneWidget);
      expect(find.text('42 completed rides'), findsOneWidget);
      expect(find.text('SERVICE: SUV • Cash'), findsOneWidget);

      // Timer card
      expect(find.text('2:33'), findsOneWidget);
      expect(find.text('ELAPSED'), findsOneWidget);
      expect(find.text('Free wait time: 5:00'), findsOneWidget);
      expect(
        find.text(
          'Amber ring after 5 mins • Extra wait time charged automatically (\$0.45/min)',
        ),
        findsOneWidget,
      );

      // Actions
      expect(find.text('START TRIP'), findsOneWidget);
      expect(find.text('Passenger not here'), findsOneWidget);
      expect(find.text('Cancel trip'), findsOneWidget);
    });

    testWidgets('Renders Screen 3 (Image 3): Cancel Trip Reason Modal sheet', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripStatus.cancelTripModal,
      ));
      await tester.pumpAndSettle();

      // Top preview indicator
      expect(
        find.text(
          'Confirm returns to Driver Home with toast: "Trip canceled"',
        ),
        findsOneWidget,
      );

      // Modal titles
      expect(find.text('Cancel this trip?'), findsOneWidget);
      expect(
        find.text(
          'Canceling often can lower your acceptance rate and affect priority dispatch across Lethbridge.',
        ),
        findsOneWidget,
      );

      // 5 Cancellation reasons
      expect(find.text('Passenger asked me to cancel'), findsOneWidget);
      expect(find.text('Passenger is not responding'), findsOneWidget);
      expect(
        find.text('Pickup location is unsafe or unreachable'),
        findsOneWidget,
      );
      expect(
        find.text('Vehicle problem / mechanical issue'),
        findsOneWidget,
      );
      expect(find.text('Other'), findsOneWidget);

      // Regulatory compliance text
      expect(
        find.text(
          'City of Lethbridge taxi commission requires dispatch log verification for cancellations.',
        ),
        findsOneWidget,
      );

      // Action buttons
      expect(find.text('Keep trip'), findsOneWidget);
      expect(find.text('Confirm cancel'), findsOneWidget);
    });

    testWidgets('Renders Screen 4 (Image 4): Fleet Telemetry & Weak GPS warning', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripStatus.telemetryAlert,
      ));
      await tester.pumpAndSettle();

      // Telemetry header & tabs
      expect(find.text('BRIDGE CITY FLEET TELEMETRY'), findsOneWidget);
      expect(find.text('Unit #42 • Lethbridge'), findsOneWidget);
      expect(find.text('1. Weak GPS'), findsWidgets);
      expect(find.text('2. Canceled'), findsOneWidget);
      expect(find.text('3. Connection'), findsOneWidget);

      // Dispatch route corridor
      expect(
        find.text('#14 EN ROUTE TO PICKUP • 432 Scenic Dr S, Lethbridge'),
        findsOneWidget,
      );
      expect(find.text('4 min • 1.8 km'), findsOneWidget);

      // Weak GPS alert card
      expect(find.text('Weak GPS Signal'), findsOneWidget);
      expect(
        find.text(
          'Your location may be inaccurate. Keep phone mounted near windshield on Scenic Drive.',
        ),
        findsOneWidget,
      );

      // Passenger bottom card
      expect(
        find.text('Alex M. • Lethbridge City Centre • Standard 4-Seat'),
        findsOneWidget,
      );
      expect(
        find.text('FARE VERIFIED • Trip #BC-123456'),
        findsOneWidget,
      );

      // Action button
      expect(find.text('Tap When Arrived'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 1: Active Trip Navigation (In Progress) properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripStatus.onTrip,
      ));
      await tester.pumpAndSettle();

      // Top app bar
      expect(find.text('Active Trip Navigation'), findsOneWidget);

      // Status pill & map corridor
      expect(find.text('Trip in progress • 9 min • 4.1 km'), findsOneWidget);
      expect(
        find.text('Coulee Crossing (West Lethbridge → Downtown)'),
        findsOneWidget,
      );

      // Navigation sheet
      expect(find.text('TRIP BC-123456'), findsOneWidget);
      expect(find.text('METER RUNNING'), findsOneWidget);
      expect(find.text('Distance: 2.4 km left'), findsOneWidget);
      expect(find.text('Elapsed: 6:32'), findsOneWidget);
      expect(find.text('Pickup: Heritage Heights'), findsOneWidget);
      expect(find.text('Destination: 501 1st Ave S'), findsOneWidget);

      // Dropoff card
      expect(
        find.text('DROPOFF • Stop 1 of 1 • Final destination'),
        findsOneWidget,
      );
      expect(find.text('501 1st Ave S'), findsOneWidget);
      expect(find.text('Lethbridge (Downtown Core)'), findsOneWidget);

      // Passenger & service
      expect(find.text('Alex M. • Cash'), findsOneWidget);
      expect(find.text('Sedan'), findsOneWidget);

      // Action buttons
      expect(find.text('Navigate to dropoff'), findsOneWidget);
      expect(find.text('END TRIP'), findsOneWidget);
      expect(
        find.text('Tap when passenger has exited safely'),
        findsOneWidget,
      );
    });

    testWidgets('Renders Screenshot 2: End This Trip? Early Warning Modal properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripStatus.endTripModal,
      ));
      await tester.pumpAndSettle();

      // Top chips
      expect(find.text('CAB #42 • LIVE GPS'), findsOneWidget);
      expect(find.text('0 km/h (Stopped)'), findsOneWidget);

      // Modal titles
      expect(find.text('End this trip?'), findsOneWidget);
      expect(
        find.text(
          "Make sure you've reached the drop-off location and the passenger has gathered all personal belongings.",
        ),
        findsOneWidget,
      );

      // Designated drop-off
      expect(find.text('DESIGNATED DROP-OFF'), findsOneWidget);
      expect(find.text('1.2 km away'), findsOneWidget);
      expect(find.text('Far (1.2 km Warning)'), findsOneWidget);
      expect(find.text('Within 50m (Normal)'), findsOneWidget);

      // Alert card
      expect(
        find.text("You're 1.2 km from the drop-off. End the trip anyway?"),
        findsOneWidget,
      );

      // Meter fare
      expect(find.text('Computed Meter Fare'), findsOneWidget);
      expect(find.text('\$16.85'), findsOneWidget);
      expect(find.text('Taxes included'), findsOneWidget);

      // Actions
      expect(find.text('End trip & Generate Receipt'), findsOneWidget);
      expect(find.text('Not yet'), findsOneWidget);
      expect(
        find.text(
          'City of Lethbridge Taxi Commission Bylaw 6138 Compliance: Fare finalized instantly via onboard digital meter algorithm upon trip termination.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders Screenshot 5 State 5: Critical Emergency SOS Sheet properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripStatus.emergencySosModal,
      ));
      await tester.pumpAndSettle();

      expect(find.text('EMERGENCY PROTOCOL'), findsOneWidget);
      expect(find.text('GPS Locked'), findsOneWidget);
      expect(find.text('Send emergency alert?'), findsOneWidget);
      expect(
        find.text(
          'If you are in immediate danger, call 911. Activating dispatch alert will transmit live audio and coordinate with Lethbridge Police Service.',
        ),
        findsOneWidget,
      );
      expect(find.text('SOS Send SOS'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('QA bar switches states interactively in runtime', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverTripStatus.headingToPickup,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Heading to pickup • 4 min • 1.2 km'), findsOneWidget);

      // Switch to Waiting (2:33) via QA Bar
      await tester.tap(find.text('2. Waiting (2:33)'));
      await tester.pumpAndSettle();
      expect(find.text('Waiting for passenger • Arrived'), findsOneWidget);
      expect(find.text('2:33'), findsOneWidget);

      // Switch to Cancel Modal via QA Bar
      await tester.tap(find.text('3. Cancel Modal'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel this trip?'), findsOneWidget);

      // Switch to Weak GPS via QA Bar (find in QA bar specifically)
      await tester.tap(find.text('4. Weak GPS'));
      await tester.pumpAndSettle();
      expect(find.text('Weak GPS Signal'), findsOneWidget);
    });
  });
}
