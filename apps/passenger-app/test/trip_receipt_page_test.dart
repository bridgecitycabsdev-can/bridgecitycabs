import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/trip_receipt/trip_receipt.dart';

void main() {
  group('TripReceiptPage Widget Tests', () {
    testWidgets('renders Screen 1 Cash Payment Pending State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TripReceiptPage(
            initialStatus: TripReceiptStatus.cashPending,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Trip completed'), findsOneWidget);
      expect(find.text('Thanks for riding with Bridge City Cabs.'), findsOneWidget);

      // Total Due and pending badge
      expect(find.text('TOTAL DUE'), findsOneWidget);
      expect(find.text(r'$22.10'), findsOneWidget);
      expect(find.text('CAD'), findsWidgets);
      expect(find.text('Payment pending'), findsOneWidget);

      // Cash advisory banner
      expect(find.text('Pay \$22.10 cash to your driver'), findsOneWidget);
      expect(
        find.text('No digital confirmation required from you'),
        findsOneWidget,
      );

      // Route and Driver
      expect(find.textContaining('515 5th Ave S'), findsWidgets);
      expect(find.textContaining('Park Place Mall'), findsWidgets);
      expect(find.text('Michael K.'), findsOneWidget);
      expect(find.text('BCC • 892'), findsOneWidget);

      // Breakdown and Rating Unlock Warning
      expect(find.text('Base subtotal'), findsOneWidget);
      expect(find.text(r'$21.05 CAD'), findsWidgets);
      expect(find.text('Cash Payment'), findsOneWidget);
      expect(find.text('Awaiting Driver'), findsOneWidget);
      expect(
        find.text('Driver rating unlocks once cash payment is registered'),
        findsOneWidget,
      );

      // Done CTA
      expect(find.text('Done'), findsWidgets);
    });

    testWidgets('renders Screen 2 Cash Payment Confirmed State accurately',
        (tester) async {
      final confirmedReceipt = const TripReceiptDetails().copyWith(
        fare: const ReceiptFareBreakdown(
          subtotalCad: 21.05,
          gstCad: 1.05,
          paymentType: ReceiptPaymentType.cash,
          paymentStatusText: 'Cash (Driver Confirmed)',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TripReceiptPage(
            receipt: confirmedReceipt,
            initialStatus: TripReceiptStatus.cashConfirmed,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Total Paid and completed badge
      expect(find.text('TOTAL PAID'), findsOneWidget);
      expect(find.text('Payment completed'), findsOneWidget);

      // Driver confirmed green banner
      expect(
        find.text('Driver confirmed cash received (\$22.10 CAD)'),
        findsOneWidget,
      );

      // Rate driver action is now visible and enabled
      expect(find.text('Rate your driver'), findsOneWidget);
      expect(find.text('Done'), findsWidgets);
    });

    testWidgets('renders Screen 3 Card Pre-Authorized / Completed State accurately',
        (tester) async {
      const cardReceipt = TripReceiptDetails(
        fare: ReceiptFareBreakdown(
          subtotalCad: 21.05,
          gstCad: 1.05,
          paymentType: ReceiptPaymentType.card,
          cardLast4: '4242',
          paymentStatusText: 'VISA •••• 4242 Pre-authorized',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: TripReceiptPage(
            receipt: cardReceipt,
            initialStatus: TripReceiptStatus.cardPaid,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Total Paid
      expect(find.text('TOTAL PAID'), findsOneWidget);
      expect(find.text(r'$22.10'), findsOneWidget);
      expect(find.text('Payment completed'), findsOneWidget);

      // Card itemized breakdown
      expect(find.text('Card Payment (•••• 4242)'), findsOneWidget);
      expect(find.text('VISA •••• 4242 Pre-authorized'), findsOneWidget);

      // CTAs
      expect(find.text('Rate your driver'), findsOneWidget);
      expect(find.text('Done'), findsWidgets);
    });

    testWidgets('renders Screen 4 Card with Promo Discount Applied accurately',
        (tester) async {
      const promoReceipt = TripReceiptDetails(
        fare: ReceiptFareBreakdown(
          subtotalCad: 21.05,
          gstCad: 1.05,
          discountCad: 5.00,
          promoCode: 'BRIDGE5',
          paymentType: ReceiptPaymentType.card,
          cardLast4: '4242',
          paymentStatusText: 'VISA •••• 4242 Approved',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: TripReceiptPage(
            receipt: promoReceipt,
            initialStatus: TripReceiptStatus.discountApplied,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Discounted Total
      expect(find.text(r'$17.10'), findsOneWidget);
      expect(find.text(r'BRIDGE5 • $5.00 CAD saved'), findsOneWidget);

      // Breakdown rows
      expect(find.text('Base subtotal'), findsOneWidget);
      expect(find.text(r'$21.05 CAD'), findsOneWidget);
      expect(find.text('Discount (BRIDGE5)'), findsOneWidget);
      expect(find.text(r'-$5.00 CAD'), findsOneWidget);
      expect(find.text('Federal GST (5%)'), findsOneWidget);
      expect(find.text(r'$1.05 CAD'), findsOneWidget);
      expect(find.text(r'$17.10 CAD'), findsOneWidget);
      expect(find.text('VISA •••• 4242 Approved'), findsOneWidget);

      expect(find.text('Rate your driver'), findsOneWidget);
    });

    testWidgets('renders Screen 5 Loading / Calculating Telemetry Skeleton accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TripReceiptPage(
            initialStatus: TripReceiptStatus.loading,
            simulateLoading: true,
          ),
        ),
      );
      // Pump initial frame before loading timer completes
      await tester.pump();

      expect(find.byType(ReceiptSkeletonView), findsOneWidget);
      expect(
        find.text('Calculating final fare & telemetry...'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
