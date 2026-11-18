import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/card_authentication/card_authentication.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: ExpiredCardPromptPage(),
    );
  }

  group('ExpiredCardPromptPage Widget Tests', () {
    testWidgets('renders expired card warning banner and disabled book ride button',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // App bar
      expect(find.text('Confirm Trip'), findsOneWidget);

      // QA Edge-Case simulator bar
      expect(find.text('1. Expired Card'), findsOneWidget);
      expect(find.text('2. Insufficient Funds'), findsOneWidget);
      expect(find.text('3. Payment Error'), findsOneWidget);

      // Ride summary
      expect(find.text('Standard Ride'), findsOneWidget);
      expect(find.text('Est. Pickup 3 mins'), findsOneWidget);
      expect(find.text('\$22.10 CAD'), findsOneWidget);

      // Expired card alert & badge
      expect(find.text('Card Expired'), findsOneWidget);
      expect(find.text('Expired (04/24)'), findsOneWidget);
      expect(find.text('Cannot process charge'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);

      // Quick switch buttons
      expect(find.text('Pay Cash'), findsOneWidget);
      expect(find.text('New Card'), findsOneWidget);

      // Disabled Book ride button
      final bookBtnFinder = find.widgetWithText(ElevatedButton, 'Book ride');
      expect(bookBtnFinder, findsOneWidget);
      final ElevatedButton bookBtn = tester.widget(bookBtnFinder);
      expect(bookBtn.onPressed, isNull); // Disabled because card is expired
    });
  });
}
