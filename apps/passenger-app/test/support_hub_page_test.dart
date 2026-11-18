import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/support/support.dart';

void main() {
  Widget createTestWidget({
    List<SupportTicket>? initialTickets,
    SupportHubTab initialTab = SupportHubTab.myTickets,
  }) {
    return MaterialApp(
      home: SupportHubPage(
        initialTickets: initialTickets,
        initialTab: initialTab,
      ),
    );
  }

  group('SupportHubPage Widget Tests', () {
    testWidgets('renders empty state when there are no tickets', (tester) async {
      await tester.pumpWidget(createTestWidget(initialTickets: []));
      await tester.pumpAndSettle();

      expect(find.text('Support Hub'), findsOneWidget);
      expect(find.text('No tickets yet'), findsOneWidget);
      expect(find.text('Create new ticket'), findsOneWidget);
      expect(find.textContaining('Average response under 5 mins'), findsOneWidget);

      // Tap create new ticket button -> switches to New report tab
      await tester.tap(find.text('Create new ticket'));
      await tester.pumpAndSettle();

      expect(find.text('Report an Issue'), findsOneWidget);
      expect(find.text('Subject'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('renders populated ticket list with cards and guarantee', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Support Hub'), findsOneWidget);
      expect(find.text('Recent Inquiries'), findsOneWidget);
      expect(find.text('Left black backpack in Toyota Camry'), findsOneWidget);
      expect(find.text('Double charged on trip to Park Place'), findsOneWidget);
      expect(find.text('Passenger Guarantee'), findsOneWidget);
      expect(find.textContaining('403-328-8888'), findsOneWidget);

      // Filter by Lost Item
      await tester.tap(find.text('🎒 Lost item'));
      await tester.pumpAndSettle();

      expect(find.text('Left black backpack in Toyota Camry'), findsOneWidget);
      expect(find.text('Double charged on trip to Park Place'), findsNothing);
    });

    testWidgets('switching to New report tab and submitting form works', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch tab to New report
      await tester.tap(find.text('New report'));
      await tester.pumpAndSettle();

      expect(find.text('Report an Issue'), findsOneWidget);

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g., Left black backpack in Toyota Camry'),
        'Lost Wallet',
      );
      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText?.contains('Please describe what happened') ?? false)),
        'Left my brown leather wallet on rear floor mat.',
      );
      await tester.pumpAndSettle();

      // Submit form
      final submitFinder = find.widgetWithText(ElevatedButton, 'Submit Report');
      expect(submitFinder, findsOneWidget);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      // Should switch back to My tickets and display new ticket
      expect(find.text('Lost Wallet'), findsOneWidget);
    });
  });
}
