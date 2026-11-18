import 'package:driver_app/features/support/support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverSupportPage Widget Tests', () {
    late FakeDriverSupportRepository repository;

    setUp(() {
      repository = FakeDriverSupportRepository();
    });

    Widget createWidget({
      DriverSupportViewStatus initialStatus = DriverSupportViewStatus.center,
    }) {
      return MaterialApp(
        home: DriverSupportPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders Screenshot 1: Support Center properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverSupportViewStatus.center,
      ));
      await tester.pumpAndSettle();

      // App bar & QA Bar
      expect(find.text('Support Center'), findsOneWidget);
      expect(find.text('1. Center'), findsOneWidget);
      expect(find.text('2. New Ticket'), findsOneWidget);
      expect(find.text('3. My Tickets'), findsOneWidget);
      expect(find.text('4. Chat Detail'), findsOneWidget);
      expect(find.text('5. SOS Modal'), findsOneWidget);

      // Subheader
      expect(find.text('LETHBRIDGE FLEET SUPPORT'), findsOneWidget);
      expect(find.text('Unit #42'), findsOneWidget);

      // Top toggle buttons
      expect(find.text('New report'), findsOneWidget);
      expect(find.text('My tickets'), findsOneWidget);

      // Contact channels
      expect(find.text('Email us'), findsOneWidget);
      expect(find.text('<2h reply'), findsOneWidget);
      expect(find.text('Call support'), findsOneWidget);
      expect(find.text('24/7 Live'), findsOneWidget);
      expect(find.text('403-328-8888'), findsOneWidget);
      expect(
        find.text('Support is available 24/7 for all Lethbridge fleet drivers.'),
        findsOneWidget,
      );

      // Search & Dispatch Hub
      expect(find.text('Search help topics'), findsOneWidget);
      expect(find.text('SHIFT DISPATCH HUB'), findsOneWidget);
      expect(
        find.text('Bridge City Dispatch Desk • 4th Ave S • Downtown'),
        findsOneWidget,
      );

      // Popular help topics
      expect(find.text('Popular help topics'), findsOneWidget);
      expect(find.text('Statements and payouts'), findsOneWidget);
      expect(find.text('Documents and approval'), findsOneWidget);
      expect(find.text('Passenger no-show'), findsOneWidget);
      expect(find.text('Report a safety issue'), findsOneWidget);

      // Advisory & CTA
      expect(find.text('Whoop-Up Drive Winter Road Advisory'), findsOneWidget);
      expect(find.text('New ticket'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 2: New Ticket Form properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverSupportViewStatus.newTicket,
      ));
      await tester.pumpAndSettle();

      // App bar
      expect(find.text('New Ticket'), findsOneWidget);

      // UI State Inspector
      expect(find.text('UI STATE INSPECTOR'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Empty'), findsOneWidget);
      expect(find.text('Sending'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);

      // Topic chips
      expect(find.text('What is this about? '), findsOneWidget);
      expect(find.text('Ride issue'), findsOneWidget);
      expect(find.text('Payment or statement'), findsOneWidget);
      expect(find.text('Document or approval'), findsOneWidget);

      // Subject & Linked Trip
      expect(find.text('SUBJECT'), findsOneWidget);
      expect(find.text('Incorrect toll adjustment on Whoop-U'), findsOneWidget);
      expect(find.text('LINKED TRIP'), findsOneWidget);
      expect(find.text('Trip #BC-123456'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('\$22.10'), findsOneWidget);

      // Description & Attachment
      expect(find.text('DESCRIBE YOUR ISSUE'), findsOneWidget);
      expect(find.text('meter_receipt_whoopup.png'), findsOneWidget);
      expect(find.text('1.8 MB • Attached from dash camera'), findsOneWidget);

      // Actions
      expect(find.text('Submit Ticket'), findsOneWidget);
      expect(find.text('Urgent Safety Emergency?'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 3: My Tickets list properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverSupportViewStatus.myTickets,
      ));
      await tester.pumpAndSettle();

      // App bar & Header
      expect(find.text('My Tickets'), findsOneWidget);
      expect(find.text('Driver Resolution Desk'), findsOneWidget);
      expect(find.text('Lethbridge Fleet Dispatch #402'), findsOneWidget);

      // Filter chips
      expect(find.text('All tickets 3'), findsOneWidget);
      expect(find.text('Open 1'), findsOneWidget);
      expect(find.text('In progress 1'), findsOneWidget);

      // Ticket cards
      expect(find.text('#TK-9042'), findsOneWidget);
      expect(find.text('Fare audit for disputed cash trip #BC-123456'), findsOneWidget);
      expect(find.text('New reply'), findsOneWidget);

      expect(find.text('#TK-8819'), findsOneWidget);
      expect(find.text('CVIP annual vehicle inspection renewal approval'), findsOneWidget);

      expect(find.text('#TK-7602'), findsOneWidget);
      expect(find.text('In-cab terminal tap-to-pay firmware sync error'), findsOneWidget);

      // Dispatch states & Guarantee
      expect(find.text('SIMULATED DISPATCH STATES'), findsOneWidget);
      expect(find.text('Priority Cab Guarantee'), findsOneWidget);
      expect(find.text('All urgent safety tickets answered < 5m'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 4: Ticket Detail chat properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverSupportViewStatus.ticketDetail,
      ));
      await tester.pumpAndSettle();

      // App bar & subheader
      expect(find.text('Ticket Detail'), findsOneWidget);
      expect(find.text('OPEN #TK-9042'), findsOneWidget);

      // Linked trip card & map
      expect(find.text('LINKED TRIP #BC-123456'), findsOneWidget);
      expect(find.text('View receipt'), findsOneWidget);
      expect(find.text('Whoop-Up Dr Viaduct • Tariff Corridor 04'), findsOneWidget);

      // Chat messages
      expect(
        find.textContaining('automatic bridge surcharge deduction'),
        findsOneWidget,
      );
      expect(
        find.textContaining('adjust your shift ledger within 2 hours'),
        findsOneWidget,
      );
      expect(find.text('Failed to send. Tap to retry.'), findsOneWidget);

      // Typing indicator & reopen banner
      expect(
        find.text('Agent Sarah is typing dispatch notes...'),
        findsOneWidget,
      );
      expect(
        find.text('This ticket is resolved. Replying will reopen...'),
        findsOneWidget,
      );

      // Quick action chips & composer
      expect(find.text('🧾 Add receipt photo'), findsOneWidget);
      expect(find.text('✓ Confirm cash total'), findsOneWidget);
      expect(find.text('Type your reply...'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 5: Emergency SOS modal properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverSupportViewStatus.emergencySos,
      ));
      await tester.pumpAndSettle();

      // Header telemetry pill
      expect(find.text('CAB #142 • LETHBRIDGE FLEET'), findsOneWidget);
      expect(find.text('GPS Transmitting'), findsOneWidget);

      // Main SOS prompt
      expect(find.text('Are you in danger right now?'), findsOneWidget);
      expect(
        find.text(
          'Immediate safety threats and active roadside incidents receive priority dispatch escalation.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Distress signals instantly alert Lethbridge Police Services (LPS) and lock vehicle telemetry.',
        ),
        findsOneWidget,
      );

      // Buttons
      expect(find.text('Send SOS alert'), findsOneWidget);
      expect(find.text('Report a past issue'), findsOneWidget);
      expect(
        find.text('IF YOU ARE IN IMMEDIATE DANGER, ALSO CALL 911.'),
        findsOneWidget,
      );
      expect(find.text('Dismiss / Close'), findsOneWidget);
    });

    testWidgets('QA bar toggles across all 5 visual screens seamlessly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverSupportViewStatus.center,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Popular help topics'), findsOneWidget);

      // Switch to 2. New Ticket
      await tester.tap(find.text('2. New Ticket'));
      await tester.pumpAndSettle();
      expect(find.text('Submit Ticket'), findsOneWidget);

      // Switch to 3. My Tickets
      await tester.tap(find.text('3. My Tickets'));
      await tester.pumpAndSettle();
      expect(find.text('Driver Resolution Desk'), findsOneWidget);

      // Switch to 4. Chat Detail
      await tester.tap(find.text('4. Chat Detail'));
      await tester.pumpAndSettle();
      expect(find.text('Type your reply...'), findsOneWidget);

      // Switch to 5. SOS Modal
      await tester.tap(find.text('5. SOS Modal'));
      await tester.pumpAndSettle();
      expect(find.text('Are you in danger right now?'), findsOneWidget);
    });
  });
}
