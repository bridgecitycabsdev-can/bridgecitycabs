import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/request/request.dart';

void main() {
  group('DriverRequestPage Widget Tests', () {
    late FakeDriverRequestRepository repository;

    setUp(() {
      repository = FakeDriverRequestRepository(
        networkLatency: Duration.zero,
      );
    });

    Widget createWidget({
      DriverRequestStatus initialStatus = DriverRequestStatus.incomingInstant,
    }) {
      return MaterialApp(
        home: DriverRequestPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders State 1: Instant Request elements properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverRequestStatus.incomingInstant));
      await tester.pumpAndSettle();

      expect(find.text('New ride request'), findsOneWidget);
      expect(find.text('440 University Dr W'), findsOneWidget);
      expect(find.text('501 1st Ave S'), findsOneWidget);
      expect(find.text('\$15.00'), findsOneWidget);
      expect(find.text('ACCEPT RIDE'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
    });

    testWidgets('Renders State 2: Securing Dispatch elements properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverRequestStatus.securingDispatch));
      await tester.pumpAndSettle();

      expect(find.text('HANDSHAKE PROTOCOL'), findsOneWidget);
      expect(find.text('Securing Dispatch...'), findsOneWidget);
      expect(find.text('ACTIVE SYNC'), findsOneWidget);
      expect(find.text('Accepting...'), findsOneWidget);
      expect(find.text('Please keep app open while securing route guidance.'), findsOneWidget);
    });

    testWidgets('Renders State 3: Urgent Expiring elements properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverRequestStatus.expiringUrgent));
      await tester.pumpAndSettle();

      expect(find.text('BRIDGE CITY PRIORITY'), findsOneWidget);
      expect(find.text('HURRY! OFFER EXPIRING IN 4S'), findsOneWidget);
      expect(find.text('Accept ride • EXPIRING RAPIDLY'), findsOneWidget);
    });

    testWidgets('Renders State 4: Expired Dialog properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverRequestStatus.expired));
      await tester.pumpAndSettle();

      expect(find.text('This request expired'), findsOneWidget);
      expect(find.text('Acceptance rate adjusted: -1%'), findsOneWidget);
      expect(find.text('Return to map now'), findsOneWidget);
    });

    testWidgets('Renders State 5: Taken by Another Driver dialog properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverRequestStatus.takenByAnother));
      await tester.pumpAndSettle();

      expect(find.textContaining('This ride was taken'), findsOneWidget);
      expect(find.text('DISPATCHED SIMULTANEOUSLY'), findsOneWidget);
      expect(find.text('Back to map'), findsOneWidget);
    });

    testWidgets('Renders State 6: Scheduled Booking properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverRequestStatus.scheduled));
      await tester.pumpAndSettle();

      expect(find.text('SCHEDULED BOOKING'), findsOneWidget);
      expect(find.text('Scheduled ride request'), findsOneWidget);
      expect(find.text('Lethbridge Airport (YQL)'), findsOneWidget);
      expect(find.text('\$34.50'), findsOneWidget);
      expect(find.text('Pickup at Fri, 3:30 PM (Scheduled)'), findsOneWidget);
    });

    testWidgets('Renders State 7: Decline Alert Sheet properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverRequestStatus.declineConfirmation));
      await tester.pumpAndSettle();

      expect(find.text('Decline this ride?'), findsOneWidget);
      expect(find.text('ACCEPTANCE ALERT'), findsOneWidget);
      expect(find.text('CURRENT'), findsOneWidget);
      expect(find.text('IF DECLINED'), findsOneWidget);
      expect(find.text('Keep & Accept Ride'), findsOneWidget);
      expect(find.text('Decline anyway'), findsOneWidget);
      expect(find.text('Too far away'), findsOneWidget);
      expect(find.text('Break time'), findsOneWidget);
    });

    testWidgets('QA Matrix bar triggers state changes when tapped', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverRequestStatus.incomingInstant));
      await tester.pumpAndSettle();

      expect(find.text('New ride request'), findsOneWidget);

      // Tap QA chip for Scheduled
      final scheduledChip = find.text('6: Scheduled Airport');
      expect(scheduledChip, findsOneWidget);
      await tester.tap(scheduledChip);
      await tester.pumpAndSettle();

      expect(find.text('Scheduled ride request'), findsOneWidget);
      expect(find.text('Lethbridge Airport (YQL)'), findsOneWidget);
    });
  });
}
