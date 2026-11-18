import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/confirm_trip/confirm_trip.dart';

class MockTestConfirmTripPageRepo implements ConfirmTripRepository {
  @override
  Future<bool> bookTrip({
    required PaymentMethodInfo payment,
    required double totalAmount,
  }) async => true;

  @override
  Future<FareBreakdown?> checkForFareUpdate() async => null;

  @override
  Future<PaymentMethodInfo> linkNewCard() async => PaymentMethodInfo.linkedVisa;
}

void main() {
  group('ConfirmTripPage Widget Tests', () {
    testWidgets('renders Screen 1 Standard Cash state accurately', (tester) async {
      final repo = MockTestConfirmTripPageRepo();
      final bloc = ConfirmTripBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConfirmTripBloc>.value(
            value: bloc,
            child: const ConfirmTripPage(initialPayment: PaymentType.cash),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirm Trip'), findsOneWidget);
      expect(find.text('515 5th Ave S, Downtown Lethbridge'), findsOneWidget);
      expect(find.text('Park Place Mall, Main Entrance (North Bay)'), findsOneWidget);
      expect(find.text('SUV • Big'), findsOneWidget);
      expect(find.text('Pay driver at destination'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('GST (5%)'), findsOneWidget);
      expect(find.text('Book ride • \$22.10 CAD'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 2 Card Required state accurately', (tester) async {
      final repo = MockTestConfirmTripPageRepo();
      final bloc = ConfirmTripBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConfirmTripBloc>.value(
            value: bloc,
            child: const ConfirmTripPage(
              initialPayment: PaymentType.card,
              hasLinkedCard: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+ Add a card'), findsOneWidget);
      expect(find.text('+ Link Visa / Mastercard'), findsOneWidget);
      expect(find.text('⚠️ Add card or switch to cash'), findsOneWidget);

      // Book ride button should be disabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      bloc.close();
    });

    testWidgets('renders Screen 3 Linked Card state accurately', (tester) async {
      final repo = MockTestConfirmTripPageRepo();
      final bloc = ConfirmTripBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConfirmTripBloc>.value(
            value: bloc,
            child: const ConfirmTripPage(
              initialPayment: PaymentType.card,
              hasLinkedCard: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('•••• 4242'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Expires 08/26'), findsOneWidget);
      expect(find.text('Book ride • \$22.10 CAD'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 5 Card Declined state accurately', (tester) async {
      final repo = MockTestConfirmTripPageRepo();
      final bloc = ConfirmTripBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConfirmTripBloc>.value(
            value: bloc,
            child: const ConfirmTripPage(simulateDecline: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your card was declined. No booking was made.'), findsOneWidget);
      expect(find.text('Try another card'), findsOneWidget);
      expect(find.text('Pay with cash'), findsOneWidget);
      expect(find.text('Declined by bank'), findsOneWidget);
      expect(find.text('Update payment method • \$22.10 CAD'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 6 Fare Changed Modal accurately', (tester) async {
      final repo = MockTestConfirmTripPageRepo();
      final bloc = ConfirmTripBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConfirmTripBloc>.value(
            value: bloc,
            child: const ConfirmTripPage(simulateFareChange: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your fare has changed'), findsOneWidget);
      expect(find.text('PREVIOUS FARE'), findsOneWidget);
      expect(find.text('Confirm new total • \$24.60 CAD'), findsOneWidget);
      expect(find.text('Back to vehicles'), findsOneWidget);

      bloc.close();
    });
  });
}
