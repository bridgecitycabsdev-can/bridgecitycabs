import 'package:driver_app/features/delete_account/delete_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverDeleteAccountPage Widget Tests', () {
    late FakeDriverDeleteAccountRepository repository;

    setUp(() {
      repository = FakeDriverDeleteAccountRepository();
    });

    Widget createWidget({
      DriverDeleteStatus initialStatus = DriverDeleteStatus.checklistReady,
    }) {
      return MaterialApp(
        home: DriverDeleteAccountPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders Screenshot 3: Delete Checklist view properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverDeleteStatus.checklistReady,
      ));
      await tester.pumpAndSettle();

      // App bar & QA bar
      expect(find.text('Delete Account'), findsOneWidget);
      expect(find.text('1. Checklist'), findsOneWidget);
      expect(find.text('2. Safeguards'), findsOneWidget);
      expect(find.text('3. Requested'), findsOneWidget);
      expect(find.text('4. Recovery'), findsOneWidget);
      expect(find.text('5. SOS Modal'), findsOneWidget);

      // Hero
      expect(find.text('Delete your driver account?'), findsOneWidget);
      expect(
        find.text(
          'You\'ll stop receiving ride requests and your driver profile will be removed after a short waiting period.',
        ),
        findsOneWidget,
      );

      // Checklist section
      expect(find.text('Before you go'), findsOneWidget);
      expect(find.text('Ready to proceed'), findsOneWidget);
      expect(find.text('No trip in progress'), findsOneWidget);
      expect(find.text('Unpaid earnings: \$0.00'), findsOneWidget);
      expect(find.text('Test Hold'), findsOneWidget);
      expect(find.text('All statements paid'), findsOneWidget);
      expect(find.text('No open support tickets about payments'), findsOneWidget);

      // What will be deleted
      expect(find.text('What will be deleted'), findsOneWidget);
      expect(find.text('Your driver profile and photo'), findsOneWidget);
      expect(
        find.text('Uploaded documents (licence, registration, insurance)'),
        findsOneWidget,
      );

      // What may be kept
      expect(find.text('What may be kept'), findsOneWidget);

      // 30-day reflection period
      expect(find.text('30-day reflection period'), findsOneWidget);

      // Actions
      expect(find.text('Keep my account'), findsOneWidget);
      expect(find.text('→ Continue to delete'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 2: Protocol Safeguards view properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverDeleteStatus.safeguardsBlocked,
      ));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('PROTOCOL SAFEGUARDS'), findsOneWidget);
      expect(find.text('5 Live States'), findsOneWidget);
      expect(
        find.text(
          'Review validation blocks that halt driver account termination in Lethbridge fleet service.',
        ),
        findsOneWidget,
      );

      // Filter chips
      expect(find.text('1. Trip active'), findsOneWidget);
      expect(find.text('2. Unpaid balance'), findsOneWidget);

      // Active Block Card
      expect(find.text('BLOCK CRITICAL'), findsOneWidget);
      expect(find.text('Cab #429'), findsOneWidget);
      expect(find.text('Active trip underway'), findsOneWidget);
      expect(
        find.text(
          'Finish your current trip before deleting your account. Safety telemetry is transmitting to Bridge City Dispatch.',
        ),
        findsOneWidget,
      );

      // Sub-card
      expect(find.text('Passenger: Sarah K.'), findsOneWidget);
      expect(find.text('METER RUNNING'), findsOneWidget);
      expect(find.text('Lethbridge Airport (YQL)'), findsOneWidget);
      expect(find.text('↓ Downtown Scenic Drive'), findsOneWidget);
      expect(find.text('\$28.40'), findsOneWidget);
      expect(find.text('11 min'), findsOneWidget);

      // Button
      expect(find.text('Go to trip'), findsOneWidget);

      // Bylaw notice
      expect(
        find.text(
          'Vehicle GPS and fare meters remain locked during ride fulfillment per City of Lethbridge Taxi Bylaw 5834.',
        ),
        findsOneWidget,
      );
      expect(find.text('LETHBRIDGE CITY FLEET PROTOCOL'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 4: Deletion Requested view properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverDeleteStatus.deletionRequested,
      ));
      await tester.pumpAndSettle();

      // Segmented Tabs
      expect(find.text('1. Confirmation Screen'), findsOneWidget);
      expect(find.text('2. In-App Recovery Banner'), findsOneWidget);

      // Hero
      expect(find.text('Deletion requested'), findsOneWidget);
      expect(
        find.text('BRIDGE CITY FLEET #408 • LETHBRIDGE, AB'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Your account will be deleted on 30 Nov 2026.'),
        findsOneWidget,
      );

      // Final payout card
      expect(find.text('Final payout scheduled'), findsOneWidget);
      expect(find.text('\$342.60 CAD'), findsOneWidget);
      expect(
        find.textContaining('RBC Royal Bank account (•••• 8219)'),
        findsOneWidget,
      );

      // 30-day grace card
      expect(find.text('30-day grace protocol'), findsOneWidget);
      expect(find.text('Hold active'), findsOneWidget);

      // Dispatcher card & Done button
      expect(find.text('Need dispatcher assistance?'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(
        find.text('Signs out driver and returns to phone verification screen'),
        findsOneWidget,
      );
    });

    testWidgets('Renders Screenshot 4 Tab 2: In-App Recovery Banner view properly',
        (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverDeleteStatus.recoveryBanner,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Account Deletion In Progress'), findsOneWidget);
      expect(find.text('24 days left'), findsOneWidget);
      expect(
        find.text('Cancel Deletion & Restore Profile'),
        findsOneWidget,
      );
      expect(find.text('Preserved Fleet Credentials'), findsOneWidget);
      expect(find.text('4.96★'), findsOneWidget);
    });

    testWidgets('Renders Screenshot 1: Emergency SOS Modal properly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverDeleteStatus.emergencyModal,
      ));
      await tester.pumpAndSettle();

      expect(find.text('CAB #142 • LETHBRIDGE FLEET'), findsOneWidget);
      expect(find.text('GPS Transmitting'), findsOneWidget);
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
      expect(find.text('Send SOS alert'), findsOneWidget);
      expect(find.text('Report a past issue'), findsOneWidget);
      expect(
        find.text('IF YOU ARE IN IMMEDIATE DANGER, ALSO CALL 911.'),
        findsOneWidget,
      );
      expect(find.text('Dismiss / Close'), findsOneWidget);
    });

    testWidgets('Tapping QA bar switches between views seamlessly', (tester) async {
      await tester.pumpWidget(createWidget(
        initialStatus: DriverDeleteStatus.checklistReady,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Delete your driver account?'), findsOneWidget);

      // Switch to 2. Safeguards
      await tester.tap(find.text('2. Safeguards'));
      await tester.pumpAndSettle();
      expect(find.text('PROTOCOL SAFEGUARDS'), findsOneWidget);

      // Switch to 3. Requested
      await tester.tap(find.text('3. Requested'));
      await tester.pumpAndSettle();
      expect(find.text('Deletion requested'), findsOneWidget);

      // Switch to 4. Recovery
      await tester.tap(find.text('4. Recovery'));
      await tester.pumpAndSettle();
      expect(find.text('Account Deletion In Progress'), findsOneWidget);

      // Switch to 5. SOS Modal
      await tester.tap(find.text('5. SOS Modal'));
      await tester.pumpAndSettle();
      expect(find.text('Are you in danger right now?'), findsOneWidget);
    });
  });
}
