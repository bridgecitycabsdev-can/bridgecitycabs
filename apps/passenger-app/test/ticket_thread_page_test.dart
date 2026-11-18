import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/support/support.dart';

void main() {
  Widget createTestWidget({required String ticketId}) {
    return MaterialApp(
      home: TicketThreadPage(
        ticketId: ticketId,
      ),
    );
  }

  group('TicketThreadPage Widget Tests', () {
    testWidgets('renders ticket context strip and message thread correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(ticketId: 'BC-9941'));
      await tester.pumpAndSettle();

      expect(find.text('Ticket #BC-9941'), findsWidgets);
      expect(find.text('Bridge City Dispatch • Lethbridge, AB'), findsOneWidget);
      expect(find.text('🎒 Lost item'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Left black backpack in Toyota Camry'), findsOneWidget);
      expect(find.text('Dispatcher Sarah'), findsOneWidget);
      expect(
        find.textContaining('North Face backpack'),
        findsOneWidget,
      );
      expect(
        find.textContaining('safe in his vehicle'),
        findsOneWidget,
      );
      expect(
        find.text('Messages in support tickets cannot be edited or deleted.'),
        findsOneWidget,
      );
    });

    testWidgets('typing message and tapping send appends message to thread', (tester) async {
      await tester.pumpWidget(createTestWidget(ticketId: 'BC-9941'));
      await tester.pumpAndSettle();

      final inputFinder = find.widgetWithText(TextField, 'Type your message...');
      expect(inputFinder, findsOneWidget);

      await tester.enterText(inputFinder, 'See you in 20 minutes!');
      await tester.pumpAndSettle();

      final sendFinder = find.byIcon(Icons.send);
      expect(sendFinder, findsOneWidget);

      await tester.tap(sendFinder);
      await tester.pumpAndSettle();

      expect(find.text('See you in 20 minutes!'), findsOneWidget);
    });
  });
}
