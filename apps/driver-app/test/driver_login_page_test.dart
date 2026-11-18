import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/auth/auth.dart';

void main() {
  group('DriverLoginPage Widget Tests', () {
    testWidgets('renders State 1 (Initial / Empty) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverLoginPage(
            initialStatus: DriverAuthStatus.initial,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(DriverAuthConfig.appTitle), findsOneWidget);
      expect(find.text(DriverAuthConfig.welcomeTitle), findsOneWidget);
      expect(find.text(DriverAuthConfig.continueButtonText), findsOneWidget);
      expect(find.text(DriverAuthConfig.phonePlaceholder), findsOneWidget);
      expect(find.text(DriverAuthConfig.defaultSubtext), findsOneWidget);
    });

    testWidgets('renders State 2 (Valid / Surge Active) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverLoginPage(
            initialStatus: DriverAuthStatus.valid,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('(403) 555-0192'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Lethbridge Fleet Zone'), findsOneWidget);
      expect(find.text('● Surge Active'), findsOneWidget);
      expect(find.text('High demand near Downtown & West Lethbridge'), findsOneWidget);
      expect(find.text(DriverAuthConfig.continueButtonText), findsOneWidget);
    });

    testWidgets('renders State 3 (Incomplete / Validation Error) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverLoginPage(
            initialStatus: DriverAuthStatus.invalid,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(DriverAuthConfig.incompleteNumberWarning), findsOneWidget);
      expect(find.text(DriverAuthConfig.invalidPhoneMessage), findsOneWidget);
      expect(find.text('Registered Fleet Drivers'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });

    testWidgets('renders State 4 (Unregistered / Account Not Found) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverLoginPage(
            initialStatus: DriverAuthStatus.unregistered,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverUnregisteredBanner), findsOneWidget);
      expect(find.text(DriverAuthConfig.unregisteredAccountTitle), findsOneWidget);
      expect(find.text(DriverAuthConfig.registerDriverLink), findsOneWidget);
      expect(find.text('Lethbridge City Fleet'), findsOneWidget);
      expect(find.text('Fleet 24/7'), findsOneWidget);
    });

    testWidgets('renders State 5 (Rate Limit / Locked) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverLoginPage(
            initialStatus: DriverAuthStatus.locked,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverLockoutBanner), findsOneWidget);
      expect(find.text(DriverAuthConfig.lockoutTitle), findsOneWidget);
      expect(find.text('14:57'), findsOneWidget);
      expect(find.text(DriverAuthConfig.attemptsExceededText), findsOneWidget);
      expect(find.text(DriverAuthConfig.notYourNumberLink), findsOneWidget);
      expect(find.byType(DriverDispatchHelpCard), findsOneWidget);
      expect(find.text(DriverAuthConfig.lockedButtonText), findsOneWidget);
    });

    testWidgets('renders State 6 (Submitting / Sending Code) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverLoginPage(
            initialStatus: DriverAuthStatus.submitting,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(DriverAuthConfig.sendingCodeButtonText), findsOneWidget);
    });

    testWidgets('tapping QA matrix bar switches between all login states',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverLoginPage(
            initialStatus: DriverAuthStatus.initial,
            showQaToolbar: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverAuthQaMatrixBar), findsOneWidget);

      // Switch to 2. Valid (Surge)
      await tester.tap(find.text('2. Valid (Surge)'));
      await tester.pumpAndSettle();
      expect(find.text('(403) 555-0192'), findsOneWidget);
      expect(find.text('● Surge Active'), findsOneWidget);

      // Switch to 5. Locked (15m)
      await tester.tap(find.text('5. Locked (15m)'));
      await tester.pumpAndSettle();
      expect(find.byType(DriverLockoutBanner), findsOneWidget);
      expect(find.text('14:57'), findsOneWidget);
    });
  });
}
