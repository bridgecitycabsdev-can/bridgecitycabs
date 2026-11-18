import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/otp/otp.dart';

void main() {
  group('DriverOtpPage Widget Tests', () {
    testWidgets('renders State 1 (Fresh Entry / Timer Active) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOtpPage(
            initialStatus: DriverOtpStatus.initial,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      // Header & Titles
      expect(find.text(DriverOtpConfig.appTitle), findsOneWidget);
      expect(find.text(DriverOtpConfig.screenTitle), findsOneWidget);
      expect(find.text(DriverOtpConfig.heading), findsOneWidget);
      expect(find.text(DriverOtpConfig.defaultMaskedPhone), findsOneWidget);

      // Sent successfully badge
      expect(find.text(DriverOtpConfig.otpSentSuccess), findsOneWidget);

      // Keypad
      expect(find.byType(DriverOtpKeypad), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2)); // Keypad key 1 & other
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

      // Pathways Card
      expect(find.byType(DriverRoutingPathwayCard), findsOneWidget);
      expect(find.text('Approved Driver'), findsOneWidget);
      expect(find.text('Driver Home'), findsOneWidget);
    });

    testWidgets('renders State 2 (Ready / 842917) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOtpPage(
            initialStatus: DriverOtpStatus.ready,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('8'), findsNWidgets(2)); // Box 8 and Keypad 8
      expect(find.text('4'), findsNWidgets(2));
      expect(find.text('2'), findsNWidgets(2));
      expect(find.text('9'), findsNWidgets(2));
      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('7'), findsNWidgets(2));

      expect(find.text(DriverOtpConfig.resendAction), findsOneWidget);
      expect(find.text(DriverOtpConfig.verifyButtonText), findsOneWidget);
    });

    testWidgets('renders State 3 (Incorrect Code) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOtpPage(
            initialStatus: DriverOtpStatus.incorrect,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverIncorrectBanner), findsOneWidget);
      expect(find.text(DriverOtpConfig.incorrectCodeError), findsOneWidget);
    });

    testWidgets('renders State 4 (Expired Code) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOtpPage(
            initialStatus: DriverOtpStatus.expired,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverExpiredCard), findsOneWidget);
      expect(find.text(DriverOtpConfig.codeExpiredMessage), findsOneWidget);
      expect(find.text(DriverOtpConfig.requestNewCodeTitle), findsOneWidget);
      expect(find.text(DriverOtpConfig.requestNewCodeSubtitle), findsOneWidget);
      expect(find.text(DriverOtpConfig.lockedVerifyButtonText), findsOneWidget);
    });

    testWidgets('renders State 5 (Submitting / Verifying) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOtpPage(
            initialStatus: DriverOtpStatus.submitting,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(DriverOtpConfig.verifyingButtonText), findsOneWidget);
      expect(find.text(DriverOtpConfig.authenticatingDispatch), findsOneWidget);
      expect(find.text(DriverOtpConfig.driverPortalBadge), findsOneWidget);
    });

    testWidgets('tapping QA matrix bar switches between all states smoothly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOtpPage(
            initialStatus: DriverOtpStatus.initial,
            showQaToolbar: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverOtpQaMatrixBar), findsOneWidget);

      // Switch to 2. Ready (842917)
      await tester.tap(find.text('2. Ready (842917)'));
      await tester.pumpAndSettle();
      expect(find.text(DriverOtpConfig.resendAction), findsOneWidget);

      // Switch to 4. Expired Code
      await tester.tap(find.text('4. Expired Code'));
      await tester.pumpAndSettle();
      expect(find.byType(DriverExpiredCard), findsOneWidget);
      expect(find.text(DriverOtpConfig.codeExpiredMessage), findsOneWidget);
    });
  });
}
