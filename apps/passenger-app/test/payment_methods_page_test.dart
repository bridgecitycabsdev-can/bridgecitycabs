import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/payment_methods/payment_methods.dart';

void main() {
  group('PaymentMethodsPage Widget Tests', () {
    testWidgets('renders Screen 1 Empty State (No Saved Cards) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentMethodsPage(
            initialCards: [],
            initialStatus: PaymentMethodsStatus.loaded,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('SAVED CARDS'), findsOneWidget);
      expect(find.text('0 on file'), findsOneWidget);
      expect(find.text('No card found'), findsOneWidget);
      expect(find.text('Add card'), findsOneWidget);
      expect(find.text('Southern Alberta Dispatch Guarantee'), findsOneWidget);
      expect(
        find.text(
          'Zero surge booking fees on scheduled medical, transit, and airport pickups.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(PaymentMethodsConfig.stripeSecurityNotice),
        findsOneWidget,
      );
    });

    testWidgets('renders Screen 2 Multi-Card Loaded State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentMethodsPage(
            initialCards: PaymentMethodsConfig.mockCards,
            initialStatus: PaymentMethodsStatus.loaded,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BRIDGE CITY TRANSIT'), findsOneWidget);
      expect(find.text('Payment Options'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('In-car'), findsOneWidget);
      expect(find.text('SAVED CARDS'), findsOneWidget);
      expect(find.text('2 cards available'), findsOneWidget);
      expect(find.text('•••• 4242'), findsOneWidget);
      expect(find.text('•••• 8821'), findsOneWidget);
      expect(find.text('Add new card'), findsOneWidget);
      expect(find.text('Instant Digital Receipts'), findsOneWidget);
      expect(
        find.text(PaymentMethodsConfig.stripeSecurityNoticeFull),
        findsOneWidget,
      );
    });

    testWidgets('renders Screen 3 Updating Default Card / Syncing State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentMethodsPage(
            initialCards: PaymentMethodsConfig.mockCards,
            initialStatus: PaymentMethodsStatus.updatingDefault,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Syncing...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('renders Screen 4 Remove Card Dialog accurately',
        (tester) async {
      const targetCard = PaymentCard(
        id: 'card_mc_8821',
        brand: CardBrand.mastercard,
        last4: '8821',
        expiry: '11/26',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RemoveCardDialog(
              card: targetCard,
              onConfirmRemove: () {},
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Remove this card?'), findsOneWidget);
      expect(
        find.text(
          'Mastercard ending in 8821 will be removed from your Bridge City Cabs account. You can re-add it anytime.',
        ),
        findsOneWidget,
      );
      expect(find.text('Remove Card'), findsOneWidget);
      expect(find.text('Keep Card'), findsOneWidget);
      expect(
        find.text('Bridge City Cabs • Secure Transit Ledger'),
        findsOneWidget,
      );
    });

    testWidgets('renders Screen 5 Error Banner with Retry accurately',
        (tester) async {
      final repo = MockPaymentMethodsRepository(
        shouldFail: true,
        delay: const Duration(milliseconds: 10),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PaymentMethodsPage(
            initialCards: PaymentMethodsConfig.mockCards,
            repository: repo,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger selection on the non-default card to trigger error
      await tester.tap(find.text('•••• 8821'));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentErrorBanner), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsWidgets);
    });

    testWidgets('renders Screen 6 Skeleton / Shimmer State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentMethodsPage(
            initialStatus: PaymentMethodsStatus.loading,
            simulateLoading: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PaymentSkeletonView), findsOneWidget);
      expect(
        find.text('Bridge City Cabs • Lethbridge Secure Pay'),
        findsOneWidget,
      );
    });
  });
}
