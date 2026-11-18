import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/add_card/add_card.dart';

void main() {
  group('AddCardPage Widget Tests', () {
    testWidgets('renders Screen 1 Initial Form State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddCardPage(
            initialStatus: AddCardStatus.initial,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Card'), findsOneWidget);
      expect(find.text('Add a new card'), findsOneWidget);
      expect(find.text(AddCardConfig.stripeElementsSecured), findsOneWidget);
      expect(find.text('Card number'), findsOneWidget);
      expect(find.text('Expiry'), findsOneWidget);
      expect(find.text('CVC / CVV'), findsOneWidget);
      expect(find.text('Postal code'), findsOneWidget);
      expect(find.text('Accepted cards'), findsOneWidget);
      expect(find.text('Set as my default card'), findsOneWidget);
      expect(find.text('Save card'), findsOneWidget);
      expect(find.text(AddCardConfig.sslNotice), findsOneWidget);

      // Save card button is disabled initially
      final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Save card'));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders Screen 2 Tokenizing State accurately',
        (tester) async {
      const form = CardFormData(
        cardNumber: '•••• •••• •••• 4242',
        expiry: '11 / 28',
        cvc: '•••',
        postalCode: 'T1J 0V4',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AddCardPage(
            initialForm: form,
            initialStatus: AddCardStatus.tokenizing,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PCI-DSS Tier 1'), findsOneWidget);
      expect(find.text('Validating'), findsOneWidget);
      expect(find.text('Tokenizing card...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders Screen 3 Bank Confirmation Dialog accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BankConfirmationDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AddCardConfig.bankConfirmingTitle), findsOneWidget);
      expect(find.text(AddCardConfig.bankConfirmingSubtitle), findsOneWidget);
      expect(
        find.text('Bridge City Cabs • Stripe Tokenization'),
        findsOneWidget,
      );
    });

    testWidgets('renders Screen 4 Card Added Success State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddCardPage(
            initialStatus: AddCardStatus.success,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddCardSuccessView), findsOneWidget);
      expect(find.text('Card added'), findsOneWidget);
      expect(find.text('Visa ending in 4242'), findsOneWidget);
      expect(find.text('Ready for immediate pickup'), findsOneWidget);
      expect(find.text('Auto-receipts enabled'), findsOneWidget);
      expect(find.text('PDF sent to email'), findsOneWidget);
      expect(find.text('Return to Payment Methods'), findsOneWidget);
    });

    testWidgets('renders Screen 5 3D Secure Verification Dialog accurately',
        (tester) async {
      const threeD = ThreeDSecureData(
        cardLast4: '4242',
        code: '641',
        maskedPhone: '(•••) •••-8921',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreeDSecureDialog(
              threeD: threeD,
              onCodeChanged: (_) {},
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ONE-TIME PASSCODE'), findsOneWidget);
      expect(find.text('Sent to (•••) •••-8921'), findsOneWidget);
      expect(find.text('Resend'), findsOneWidget);
      expect(find.text('Security Code'), findsOneWidget);
      expect(find.text('Expires in 04:57'), findsOneWidget);
      expect(find.text('Use Face ID / Passkey'), findsOneWidget);
      expect(find.text('Confirm authentication'), findsOneWidget);
      expect(find.text('Cancel verification'), findsOneWidget);
      expect(
        find.text('Powered by Stripe 3D Secure • Verified by Visa'),
        findsOneWidget,
      );
    });

    testWidgets('renders Screen 6 Card Declined Error Recovery State accurately',
        (tester) async {
      const form = CardFormData(
        cardNumber: '•••• •••• •••• 4242',
        expiry: '08/27',
        cvc: '•••',
        postalCode: 'T1J 1P4',
        nameOnCard: 'R. Vance',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AddCardPage(
            initialForm: form,
            initialStatus: AddCardStatus.declined,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddCardDeclinedBanner), findsOneWidget);
      expect(find.text(AddCardConfig.cardDeclinedTitle), findsOneWidget);
      expect(find.text(AddCardConfig.inFormFieldDeclinedError), findsOneWidget);
      expect(find.text('NAME ON CARD'), findsOneWidget);
      expect(find.text('R. Vance'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Use a different card'), findsOneWidget);
    });

    testWidgets('renders Screen 7 Verification In Progress State accurately',
        (tester) async {
      const form = CardFormData(
        cardNumber: '•••• •••• •••• 4242',
        expiry: '08 / 28',
        cvc: '•••',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AddCardPage(
            initialForm: form,
            initialStatus: AddCardStatus.verificationPending,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddCardVerificationPendingBanner), findsOneWidget);
      expect(find.text(AddCardConfig.verificationInProgressTitle), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Verification pending with issuer...'), findsOneWidget);
      expect(find.text('3DSecure'), findsOneWidget);
      expect(find.text('Return to Payment Methods'), findsOneWidget);
      expect(find.text('Cancel & re-enter details'), findsOneWidget);
    });
  });
}
