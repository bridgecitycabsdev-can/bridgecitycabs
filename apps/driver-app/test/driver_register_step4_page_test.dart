import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/registration/registration.dart';

void main() {
  group('DriverRegisterStep4Page Widget Tests', () {
    testWidgets('renders State 1 (Approved / Complete) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep4Page(
            initialStatus: DriverRegisterStep4Status.approved,
          ),
        ),
      );
      await tester.pump();

      // Header
      expect(find.text(DriverRegisterConfig.step4TopFleetTitle), findsOneWidget);
      expect(find.text(DriverRegisterConfig.step4LogOutAction), findsOneWidget);

      // Progress & Title
      expect(find.text('STEP 4 OF 4 · APPROVED'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
      expect(find.text("You're approved!"), findsOneWidget);
      expect(
          find.text(
              'You can now go online and start receiving rides in Lethbridge.'),
          findsOneWidget);

      // Milestones
      expect(find.text('Application Journey'), findsOneWidget);
      expect(find.text('3 of 3 Passed'), findsOneWidget);
      expect(find.text('Application submitted'), findsOneWidget);
      expect(find.text('Documents reviewed & verified'), findsOneWidget);

      // Profile & Credentials
      expect(find.text('Active Partner'), findsOneWidget);
      expect(find.text('Marcus Vance'), findsOneWidget);
      expect(find.text('Hybrid Class 1-A'), findsOneWidget);
      expect(find.text('Bylaw 5834 Permit'), findsOneWidget);

      // Button
      expect(find.text('Go to home ➔'), findsOneWidget);
    });

    testWidgets('renders State 2 (Reviewing / Pending) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep4Page(
            initialStatus: DriverRegisterStep4Status.reviewing,
          ),
        ),
      );
      await tester.pump();

      // Progress & Header
      expect(find.text('STEP 4 OF 4 · REVIEW'), findsOneWidget);
      expect(find.text('Final Verification'), findsOneWidget);
      expect(find.text("We're reviewing your documents"), findsOneWidget);

      // Milestones
      expect(find.text('APPLICATION MILESTONES'), findsOneWidget);
      expect(find.text('Priority Queue'), findsOneWidget);
      expect(find.text('Documents under review'), findsOneWidget);
      expect(find.text('● IN PROGRESS'), findsOneWidget);
      expect(find.text('Class 4 License'), findsOneWidget);
      expect(find.text('Vulnerable Sector'), findsOneWidget);
      expect(find.text('City Inspection'), findsOneWidget);

      // Refresh Button
      expect(find.text('Refresh status'), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step4AutoCheckNotice), findsOneWidget);
    });

    testWidgets('renders State 3 (Action Required / On Hold) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep4Page(
            initialStatus: DriverRegisterStep4Status.actionRequired,
          ),
        ),
      );
      await tester.pump();

      // Header & Alert
      expect(find.text('STEP 4 OF 4 · ACTION REQUIRED'), findsOneWidget);
      expect(find.text('90% Completed'), findsOneWidget);
      expect(find.text('Action needed on your application'), findsOneWidget);
      expect(find.text("Driver's Licence"), findsOneWidget);
      expect(find.text('RE-UPLOAD'), findsOneWidget);

      // Application temporarily on hold
      expect(find.text('Application temporarily on hold'), findsOneWidget);
      expect(find.text('VERIFICATION MILESTONES'), findsOneWidget);

      // Fix documents button
      expect(find.text('Fix documents ➔'), findsOneWidget);
    });

    testWidgets('renders State 4 (Rejected / Bylaw 5834 Ineligible) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep4Page(
            initialStatus: DriverRegisterStep4Status.rejected,
          ),
        ),
      );
      await tester.pump();

      // Header & Rejection Banner
      expect(find.text('STEP 4 OF 4 · APPLICATION STATUS'), findsOneWidget);
      expect(find.text('Action Needed'), findsOneWidget);
      expect(find.text('Application could not be approved'), findsOneWidget);
      expect(
          find.text(
              'Your vehicle model year (2008) does not meet Lethbridge Taxi Commission Bylaw 5834 requirement (must be 2014 or newer).'),
          findsOneWidget);

      // Next steps
      expect(
          find.text('Next steps for your application'), findsOneWidget);
      expect(find.text('Review Lifecycle'), findsOneWidget);

      // Ineligible Vehicle file
      expect(find.text('Toyota Echo · 2008'), findsOneWidget);
      expect(find.text('INELIGIBLE VEHICLE'), findsOneWidget);

      // Buttons
      expect(find.text('Re-upload documents / Update vehicle'), findsOneWidget);
      expect(find.text('Contact support'), findsOneWidget);
    });

    testWidgets('renders State 5 (Offline / Reconnecting) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep4Page(
            initialStatus: DriverRegisterStep4Status.offline,
          ),
        ),
      );
      await tester.pump();

      // Offline banner
      expect(find.text("You're offline. Reconnecting..."), findsOneWidget);
      expect(find.text('Checking Lethbridge dispatch server connection...'),
          findsOneWidget);

      // Telemetry & Details
      expect(find.text('APPLICATION TELEMETRY'), findsOneWidget);
      expect(find.text('Registered Details'), findsOneWidget);
      expect(find.text('✕ Edit (Locked)'), findsOneWidget);
      expect(find.text('Lethbridge Downtown & Airport'), findsOneWidget);

      // Phone
      expect(find.textContaining('403-328-8888'), findsOneWidget);
    });
  });
}
