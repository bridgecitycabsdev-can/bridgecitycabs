import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/card_authentication/card_authentication.dart';

void main() {
  Widget createTestWidget({CardAuthStage stage = CardAuthStage.prompt3ds}) {
    return MaterialApp(
      home: CardAuthenticationPage(initialStage: stage),
    );
  }

  group('CardAuthenticationPage Widget Tests', () {
    testWidgets('renders 3DS prompt sheet with card info and action buttons',
        (tester) async {
      await tester.pumpWidget(createTestWidget(stage: CardAuthStage.prompt3ds));
      await tester.pumpAndSettle();

      // Check QA Bar
      expect(find.text('1. Waiting'), findsOneWidget);
      expect(find.text('2. Verified'), findsOneWidget);
      expect(find.text('3. Failed'), findsOneWidget);
      expect(find.text('4. Canceled'), findsOneWidget);

      // Check 3DS prompt copy
      expect(find.text('Verify your card'), findsOneWidget);
      expect(
        find.textContaining('Your bank needs to confirm this payment'),
        findsOneWidget,
      );
      expect(find.text('Visa •••• 4242'), findsOneWidget);
      expect(find.text('\$22.10 CAD'), findsWidgets);

      // Check buttons
      expect(find.text('Continue to verify ➔'), findsOneWidget);
      expect(find.text('Pay with cash instead'), findsOneWidget);
    });

    testWidgets('tapping Continue to verify shows bank waiting challenge sheet',
        (tester) async {
      await tester.pumpWidget(createTestWidget(stage: CardAuthStage.prompt3ds));
      await tester.pumpAndSettle();

      final continueBtn = find.text('Continue to verify ➔');
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Check Bank Waiting Sheet
      expect(find.text('Waiting for your bank...'), findsOneWidget);
      expect(
        find.text('Authorizing \$22.10 CAD with Visa •••• 4242'),
        findsOneWidget,
      );
      expect(find.text('Verified by Visa'), findsOneWidget);
      expect(find.text('Authentication Challenge'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(
        find.text('Approve the challenge in your banking app if prompted'),
        findsOneWidget,
      );
    });

    testWidgets('directly loading waiting stage renders BankWaitingChallengeSheet',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(stage: CardAuthStage.waitingForBank),
      );
      await tester.pumpAndSettle();

      expect(find.text('Waiting for your bank...'), findsOneWidget);
      expect(find.text('Secured by Stripe'), findsOneWidget);
    });
  });
}
