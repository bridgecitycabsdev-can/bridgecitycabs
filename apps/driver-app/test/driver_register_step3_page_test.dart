import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/registration/registration.dart';

void main() {
  group('DriverRegisterStep3Page Widget Tests', () {
    testWidgets('renders State 1 (Initial / Empty) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep3Page(
            initialStatus: DriverRegisterStep3Status.initial,
          ),
        ),
      );
      await tester.pump();

      // App bar & Header
      expect(find.text(DriverRegisterConfig.step3AppBarTitle), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3BadgeApplication), findsOneWidget);
      expect(find.text('Step 3 of 4 · Documents'), findsOneWidget);

      // Instruction
      expect(find.text('Upload clear photos'), findsOneWidget);

      // 4 Documents listed as Not uploaded
      expect(find.text("Driver's licence"), findsOneWidget);
      expect(find.text('Vehicle registration'), findsOneWidget);
      expect(find.text('Vehicle insurance'), findsOneWidget);
      expect(find.text('Taxi or chauffeur permit'), findsOneWidget);
      expect(find.text('Not uploaded'), findsNWidgets(4));

      // Disabled Submit button
      expect(find.text('Submit for review'), findsOneWidget);

      // Footer
      expect(
          find.text('⚖ Lethbridge Taxi Commission Bylaw 5834 Compliant'),
          findsOneWidget);
    });

    testWidgets('renders State 2 (Uploading in Progress) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep3Page(
            initialStatus: DriverRegisterStep3Status.uploading,
          ),
        ),
      );
      await tester.pump();

      // Files present
      expect(find.text('alberta_dl_front_back.jpg'), findsOneWidget);
      expect(find.text('ab_registration_2024.pdf'), findsOneWidget);
      expect(find.text('pink_card_insurance.jpg'), findsOneWidget);

      // Uploading indicators
      expect(find.text('75%'), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3PleaseWaitForUploads),
          findsOneWidget);
    });

    testWidgets('renders State 3 (Upload Document Modal) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep3Page(
            initialStatus: DriverRegisterStep3Status.uploadModal,
          ),
        ),
      );
      await tester.pump();

      // Modal Elements
      expect(find.text("Upload Driver's licence"), findsOneWidget);
      expect(find.text('Take photo'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
      expect(find.text('Upload PDF'), findsOneWidget);
      expect(find.text('Good lighting'), findsOneWidget);
      expect(find.text('No glare'), findsOneWidget);
      expect(find.text('All 4 corners visible'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders State 4 (Action Required / Automated Check Failed) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep3Page(
            initialStatus: DriverRegisterStep3Status.actionRequired,
          ),
        ),
      );
      await tester.pump();

      // Action required indicators
      expect(find.text('1 ACTION REQUIRED'), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3LicenceNeedsReuploadTitle),
          findsOneWidget);
      expect(find.text('2/3 VERIFIED'), findsOneWidget);
      expect(find.text('AUTOMATED CHECK FAILED'), findsOneWidget);
      expect(find.text('Retake photo / Re-upload'), findsOneWidget);
      expect(find.text('Call Desk'), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3Fix1IssueWarning), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3DirectDepositFooter),
          findsOneWidget);
    });

    testWidgets('renders State 5 (Ready for Fleet Compliance) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep3Page(
            initialStatus: DriverRegisterStep3Status.ready,
          ),
        ),
      );
      await tester.pump();

      // Ready elements
      expect(find.text('All Required Docs Attached'), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3ReadyComplianceTitle),
          findsOneWidget);
      expect(find.text('VALID 3+ YRS'), findsOneWidget);
      expect(find.text('IN FLEET SPEC'), findsOneWidget);
      expect(find.text(r'$2M LIABILITY OK'), findsOneWidget);
      expect(find.text('FAST-TRACK BONUS'), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3EncryptedCompliantTitle),
          findsOneWidget);

      // Active Submit Button
      expect(find.text('Submit for review ➔'), findsOneWidget);
    });

    testWidgets('renders State 6 (Submitting / In-Flight Transmission) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep3Page(
            initialStatus: DriverRegisterStep3Status.submitting,
          ),
        ),
      );
      await tester.pump();

      // Submitting elements
      expect(find.text('Transmitting to Fleet...'), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3UploadingEncryptedServer),
          findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3SystemProtocolActive),
          findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3SslChannelTitle), findsOneWidget);
      expect(find.text('98%'), findsOneWidget);
      expect(find.text('Submitting for review...'), findsOneWidget);
      expect(
          find.text(DriverRegisterConfig.step3DoNotCloseWarning),
          findsOneWidget);
    });
  });
}
