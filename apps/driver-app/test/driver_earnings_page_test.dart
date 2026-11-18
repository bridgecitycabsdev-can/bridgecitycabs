import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/earnings/earnings.dart';

void main() {
  group('DriverEarningsPage Widget Tests', () {
    late FakeDriverEarningsRepository repository;

    setUp(() {
      repository = FakeDriverEarningsRepository(latency: Duration.zero);
    });

    Widget createWidget({
      DriverEarningsStatus initialStatus = DriverEarningsStatus.overview,
    }) {
      return MaterialApp(
        home: DriverEarningsPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders State 1: Active Dispatch Run Overview properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverEarningsStatus.overview));
      await tester.pumpAndSettle();

      // AppBar & QA Bar
      expect(find.text('Active Dispatch Run'), findsOneWidget);
      expect(find.text('1. Overview'), findsOneWidget);
      expect(find.text('2. Banking Form'), findsOneWidget);
      expect(find.text('3. Statement Detail'), findsOneWidget);
      expect(find.text('4. Period Filter Sheet'), findsOneWidget);

      // Hero Card
      expect(find.text('Shajil'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('\$53.93'), findsOneWidget);
      expect(find.text('TIPS'), findsOneWidget);
      expect(find.text('RIDES'), findsOneWidget);
      expect(find.text('DISTANCE'), findsOneWidget);

      // Toggle & Payment Split
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Cash vs card'), findsOneWidget);
      expect(find.text('Payment Split'), findsOneWidget);
      expect(find.text('2 Trips'), findsOneWidget);
      expect(find.textContaining('Cash: \$29.43 (55%)'), findsOneWidget);
      expect(find.textContaining('Card: \$24.50 (45%)'), findsOneWidget);
      expect(find.textContaining('Cash is collected directly by you in cab'), findsOneWidget);

      // Daily Earnings Bar Chart
      expect(find.text('Daily earnings'), findsOneWidget);
      expect(find.text('Jun 24 - Jun 30'), findsOneWidget);
      expect(find.text('Lethbridge Zone'), findsOneWidget);
      expect(find.textContaining('Tue • \$24.30 • 1 ride'), findsOneWidget);

      // Bank Account Card
      expect(find.text('Bank account •••• 4821'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.textContaining('RBC Royal Bank'), findsOneWidget);

      // Statements Card
      expect(find.text('Statements'), findsOneWidget);
      expect(find.text('16 Jun – 30 Jun'), findsOneWidget);
      expect(find.text('PAID'), findsOneWidget);
      expect(find.text('01 Jun – 15 Jun'), findsOneWidget);
      expect(find.text('PROCESSING'), findsOneWidget);
    });

    testWidgets('Renders State 2: Direct Deposit Banking Form properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverEarningsStatus.bankingForm));
      await tester.pumpAndSettle();

      expect(find.text('Direct Deposit Banking'), findsOneWidget);
      expect(find.text('Secure Direct Deposit'), findsOneWidget);
      expect(find.text('256-bit Canadian banking encryption'), findsOneWidget);
      expect(find.text('Sample Canadian Cheque (MICR Guide)'), findsOneWidget);
      expect(find.text('Transit (5)'), findsOneWidget);
      expect(find.text('Institution (3)'), findsOneWidget);
      expect(find.text('Account #'), findsOneWidget);

      // Fields
      expect(find.text('Account holder name'), findsOneWidget);
      expect(find.text('Institution number (3 digits)'), findsOneWidget);
      expect(find.text('Transit number (5 digits)'), findsOneWidget);
      expect(find.text('Account number (7 to 12 digits)'), findsOneWidget);
      expect(find.text('RBC Royal Bank'), findsOneWidget);

      // Button & Notice
      expect(find.text('Save banking information'), findsOneWidget);
      expect(find.text('Payments are disbursed bi-weekly on Mondays.'), findsOneWidget);
    });

    testWidgets('Renders State 3: Statement Detail & Payout Breakdown properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverEarningsStatus.statementDetail));
      await tester.pumpAndSettle();

      expect(find.text('Statement Detail'), findsOneWidget);
      expect(find.text('Pay Period: 16 Jun – 30 Jun, 2024'), findsOneWidget);
      expect(find.text('\$341.49'), findsNWidgets(2)); // in hero and net payout
      expect(find.text('Paid on Jul 03, 2024'), findsOneWidget);
      expect(find.text('Deposited to RBC Royal Bank •••• 4821'), findsOneWidget);

      // Breakdown rows
      expect(find.text('Payout Breakdown'), findsOneWidget);
      expect(find.text('Gross fares'), findsOneWidget);
      expect(find.text('\$392.50'), findsOneWidget);
      expect(find.text('Tips (100% kept)'), findsOneWidget);
      expect(find.text('+\$18.00'), findsOneWidget);
      expect(find.text('Bridge City Cabs fee (15%)'), findsOneWidget);
      expect(find.text('-\$58.88'), findsOneWidget);
      expect(find.text('GST / Provincial Tax remitted'), findsOneWidget);
      expect(find.text('-\$10.13'), findsOneWidget);

      // Action & Footer
      expect(find.text('Download PDF Statement'), findsOneWidget);
      expect(find.textContaining('Official tax invoice issued by Bridge City Cabs Ltd.'), findsOneWidget);
    });

    testWidgets('Renders State 4: Earnings Period Filter Sheet properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverEarningsStatus.periodFilterSheet));
      await tester.pumpAndSettle();

      expect(find.text('Earnings period'), findsOneWidget);
      expect(find.text('Select statement view or custom dates'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('\$41.77'), findsOneWidget);
      expect(find.text('This week'), findsNWidgets(2)); // in sheet and behind hero card
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
      expect(find.text('\$1,248.50'), findsOneWidget);
      expect(find.text('Last month'), findsOneWidget);
      expect(find.text('\$2,840.10'), findsOneWidget);
      expect(find.text('Custom date range'), findsOneWidget);
      expect(find.text('14 days selected'), findsOneWidget);
      expect(find.text('Apply period filter'), findsOneWidget);
    });

    testWidgets('QA switcher switches states interactively in widget tree', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverEarningsStatus.overview));
      await tester.pumpAndSettle();

      expect(find.text('Active Dispatch Run'), findsOneWidget);

      // Tap QA chip "2. Banking Form"
      await tester.tap(find.text('2. Banking Form'));
      await tester.pumpAndSettle();
      expect(find.text('Direct Deposit Banking'), findsOneWidget);

      // Tap QA chip "3. Statement Detail"
      await tester.tap(find.text('3. Statement Detail'));
      await tester.pumpAndSettle();
      expect(find.text('Statement Detail'), findsOneWidget);
      expect(find.text('Payout Breakdown'), findsOneWidget);

      // Tap QA chip "4. Period Filter Sheet"
      await tester.tap(find.text('4. Period Filter Sheet'));
      await tester.pumpAndSettle();
      expect(find.text('Earnings period'), findsOneWidget);
      expect(find.text('Apply period filter'), findsOneWidget);
    });
  });
}
