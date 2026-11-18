import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/delete_account/delete_account.dart';

void main() {
  Widget buildTestApp({DeleteAccountStep initialStep = DeleteAccountStep.warning}) {
    return MaterialApp(
      home: DeleteAccountPage(initialStep: initialStep),
    );
  }

  group('DeleteAccountPage Widget Tests', () {
    testWidgets('renders Screen 1 (Delete Account Warning)', (tester) async {
      await tester.pumpWidget(buildTestApp(initialStep: DeleteAccountStep.warning));
      await tester.pumpAndSettle();

      // Verify header & title
      expect(find.text('Delete Account Warning'), findsOneWidget);
      expect(find.text('Delete your account?'), findsOneWidget);
      expect(find.textContaining('This will permanently remove your Bridge City Cabs account'), findsOneWidget);

      // Verify deletion details
      expect(find.text('What will be deleted'), findsOneWidget);
      expect(find.text('Your profile and phone number'), findsOneWidget);
      expect(find.text('What may be kept'), findsOneWidget);
      expect(find.textContaining('30 days to change your mind'), findsOneWidget);
      expect(find.text('Read our Privacy Policy (Alberta PIPA)'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Keep my account'), findsOneWidget);
      expect(find.text('Continue to delete'), findsOneWidget);
      expect(find.text(DeleteAccountConfig.complianceFooter), findsOneWidget);
    });

    testWidgets('renders Screen 2 (Security Verification)', (tester) async {
      await tester.pumpWidget(buildTestApp(initialStep: DeleteAccountStep.verification));
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Security Verification'), findsOneWidget);
      expect(find.text('STEP 2 OF 2 • FINAL AUTHORIZATION'), findsOneWidget);
      expect(find.text('Confirm deletion'), findsOneWidget);

      // Verify reason chips & feedback
      expect(find.text('Why are you leaving? (optional)'), findsOneWidget);
      expect(find.text('Privacy concerns'), findsOneWidget);
      expect(find.text("I don't use the app"), findsOneWidget);

      // Verify acknowledgment & OTP card
      expect(find.textContaining('I understand that my account will be permanently scheduled'), findsOneWidget);
      expect(find.text('Security Authorization'), findsOneWidget);
      expect(find.textContaining('Resend code in 0:27'), findsOneWidget);
      expect(find.text('Use email instead'), findsOneWidget);

      // Verify buttons
      expect(find.text('Delete my account'), findsOneWidget);
      expect(find.text('Cancel and keep account'), findsOneWidget);
    });

    testWidgets('renders Screen 3 (Deletion Requested Result)', (tester) async {
      await tester.pumpWidget(buildTestApp(initialStep: DeleteAccountStep.requestedResult));
      await tester.pumpAndSettle();

      // Verify brand & title
      expect(find.text('Bridge City Cabs'), findsOneWidget);
      expect(find.text('PROTO MODE'), findsOneWidget);
      expect(find.text('Deletion requested'), findsOneWidget);
      expect(find.textContaining('30 Nov 2026'), findsOneWidget);

      // Verify status cards
      expect(find.text('SMS receipt sent'), findsOneWidget);
      expect(find.text('30-day grace protection'), findsOneWidget);

      // Verify button & link
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Simulate rider return login'), findsOneWidget);
    });

    testWidgets('renders Screen 4 (Account Safeguards Matrix)', (tester) async {
      await tester.pumpWidget(buildTestApp(initialStep: DeleteAccountStep.safeguardsMatrix));
      await tester.pumpAndSettle();

      // Verify app bar & title
      expect(find.text('Feedback & Reason'), findsOneWidget);
      expect(find.text('ACCOUNT SAFEGUARDS MATRIX • Interactive Preview'), findsOneWidget);

      // Verify safeguard chips
      expect(find.text('Show All (7)'), findsOneWidget);
      expect(find.text('1. Live Trip'), findsOneWidget);
      expect(find.text('2. Unpaid Trip'), findsOneWidget);

      // Verify safeguard states
      expect(find.text("You're offline"), findsOneWidget);
      expect(find.text('Active trip in progress'), findsOneWidget);
      expect(find.text('Go to my trip'), findsOneWidget);
      expect(find.text('Outstanding balance pending'), findsOneWidget);
      expect(find.text('View receipt & pay'), findsOneWidget);
      expect(find.text('Enter confirmation PIN'), findsOneWidget);
      expect(find.text('Incorrect code. Please try again.'), findsOneWidget);
      expect(find.text('Verification code expired'), findsOneWidget);
      expect(find.text('Request could not be completed'), findsOneWidget);
      expect(find.text('Final Verification'), findsOneWidget);
      expect(find.text('Verifying & deleting...'), findsOneWidget);
    });
  });
}
