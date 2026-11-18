import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/card_authentication/card_authentication.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: PaymentErrorFallbackPage(),
    );
  }

  group('PaymentErrorFallbackPage Widget Tests', () {
    testWidgets('renders declined error banner, route locked card, and payment methods',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // App bar
      expect(find.text('Authentication Failed Alert'), findsOneWidget);

      // QA bar
      expect(find.text('1. Waiting'), findsOneWidget);
      expect(find.text('3. Failed'), findsOneWidget);

      // Error banner
      expect(find.text('Booking Not Completed'), findsOneWidget);
      expect(find.text('ERR_DECLINED_GENERIC'), findsOneWidget);
      expect(
        find.textContaining('Your card was declined by your financial institution'),
        findsOneWidget,
      );

      // Route locked card
      expect(find.text('Route locked'), findsOneWidget);
      expect(find.text('\$22.10 CAD'), findsWidgets);
      expect(find.textContaining('Park Place Mall'), findsWidgets);
      expect(find.textContaining('University Hall'), findsWidgets);

      // Payment options
      expect(find.text('Choose another way to pay'), findsOneWidget);
      expect(find.text('Visa •••• 4242'), findsOneWidget);
      expect(find.text('Declined'), findsOneWidget);
      expect(find.text('Mastercard •••• 1984'), findsOneWidget);
      expect(find.text('Backup'), findsOneWidget);
      expect(find.text('+ Add a new card'), findsOneWidget);

      // Buttons
      expect(
        find.text('Book with selected method \$22.10 CAD'),
        findsOneWidget,
      );
      expect(
        find.text('Cancel and return to ride options'),
        findsOneWidget,
      );
    });

    testWidgets('selecting another method updates selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select Cash option
      final cashFinder = find.text('Cash');
      expect(cashFinder, findsOneWidget);

      await tester.tap(cashFinder);
      await tester.pumpAndSettle();

      expect(find.text('Book with selected method \$22.10 CAD'), findsOneWidget);
    });
  });
}
