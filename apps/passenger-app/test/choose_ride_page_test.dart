import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/choose_ride/choose_ride.dart';

class MockTestChooseRidePageRepo implements ChooseRideRepository {
  @override
  Future<List<RideOptionTier>> getRideTiers({bool simulateUnavailable = false}) async {
    if (simulateUnavailable) {
      return RideOptionTier.withLuxuryUnavailable();
    }
    return RideOptionTier.standardTiers;
  }

  @override
  Future<PromoCode> validatePromoCode(String code) async {
    return PromoCode.lethbridge3;
  }

  @override
  Future<bool> lockFare(String tierId) async => true;
}

void main() {
  group('ChooseRidePage Widget Tests', () {
    testWidgets('renders Screen 1 Loading state with shimmers accurately', (tester) async {
      final repo = MockTestChooseRidePageRepo();
      final bloc = ChooseRideBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChooseRideBloc>.value(
            value: bloc,
            child: const ChooseRidePage(),
          ),
        ),
      );

      bloc.emit(const ChooseRideState(
        status: ChooseRideStatus.loading,
        tiers: [],
      ));
      await tester.pump();

      expect(find.text('Choose a ride'), findsOneWidget);
      expect(find.text('Live Dispatch'), findsOneWidget);
      expect(find.text('Finding best fares...'), findsOneWidget);
      expect(find.byType(RideTierSkeleton), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 2 Loaded state with Sedan breakdown accurately', (tester) async {
      final repo = MockTestChooseRidePageRepo();
      final bloc = ChooseRideBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChooseRideBloc>.value(
            value: bloc,
            child: const ChooseRidePage(),
          ),
        ),
      );

      bloc.emit(const ChooseRideState(
        status: ChooseRideStatus.loaded,
        tiers: RideOptionTier.standardTiers,
        selectedTierId: 'sedan',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Choose a ride'), findsOneWidget);
      expect(find.textContaining('Local Fleet'), findsOneWidget);
      expect(find.text('Sedan'), findsOneWidget);
      expect(find.text('SUV'), findsOneWidget);
      expect(find.text('Minivan'), findsOneWidget);
      expect(find.text('Executive Camry'), findsOneWidget);
      expect(find.text('Base Fare & Distance (3.4 km)'), findsOneWidget);
      expect(find.text('GST (5%)'), findsOneWidget);
      expect(find.text('Total Guaranteed Fare'), findsOneWidget);
      expect(find.text('Continue • \$18.40 CAD'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 3 Promo Applied state accurately', (tester) async {
      final repo = MockTestChooseRidePageRepo();
      final bloc = ChooseRideBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChooseRideBloc>.value(
            value: bloc,
            child: const ChooseRidePage(),
          ),
        ),
      );

      bloc.emit(ChooseRideState(
        status: ChooseRideStatus.promoApplied,
        tiers: RideOptionTier.standardTiers.map((t) => t.applyDiscount(3.0)).toList(),
        appliedPromo: PromoCode.lethbridge3,
        preference: const RidePreference(ladyDriverOnly: true),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Promo applied: LETHBRIDGE3'), findsOneWidget);
      expect(find.text('-\$3.00 CAD'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
      expect(find.text('Preferred'), findsOneWidget);
      expect(find.text('Continue • \$15.40 CAD'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 5 Unavailable Tier state accurately', (tester) async {
      final repo = MockTestChooseRidePageRepo();
      final bloc = ChooseRideBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChooseRideBloc>.value(
            value: bloc,
            child: const ChooseRidePage(),
          ),
        ),
      );

      bloc.emit(ChooseRideState(
        status: ChooseRideStatus.loaded,
        tiers: RideOptionTier.withLuxuryUnavailable(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Executive Camry'), findsOneWidget);
      expect(find.text('Not available right now • No cabs near'), findsOneWidget);
      expect(find.text('No cabs near'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 6 Expiring Quote countdown alert accurately', (tester) async {
      final repo = MockTestChooseRidePageRepo();
      final bloc = ChooseRideBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChooseRideBloc>.value(
            value: bloc,
            child: const ChooseRidePage(),
          ),
        ),
      );

      bloc.emit(const ChooseRideState(
        status: ChooseRideStatus.expiringQuote,
        tiers: RideOptionTier.standardTiers,
        isExpiring: true,
        validitySeconds: 25,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Quote expiring in 0:25'), findsOneWidget);
      expect(find.text('Demand fluctuating • Fares may recalculate'), findsOneWidget);
      expect(find.text('LOCK FARE Continue • \$18.40 CAD'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 1 WELCOME5 verified and expanded in-tier breakdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChooseRidePage(
            initialPromo: PromoCode(
              code: 'WELCOME5',
              description: 'Promo applied · \$3.00 off total fare',
              discountAmountCad: 3.00,
              isValid: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('WELCOME5'), findsOneWidget);
      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('Promo applied · \$3.00 off total fare'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
      expect(find.text('RECOMMENDED'), findsOneWidget);
      expect(find.text('Continue • \$15.40 CAD'), findsOneWidget);
    });

    testWidgets('renders Screen 2 QA Promo Inspector with invalid coupon WINTER50', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChooseRidePage(
            isInspectorMode: true,
            initialQaScenario: QaPromoScenario.invalidCode,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('QA PROMO INSPECTOR'), findsOneWidget);
      expect(find.text('State 1 of 7'), findsOneWidget);
      expect(find.text('1. Invalid Code'), findsOneWidget);
      expect(find.text('WINTER50'), findsOneWidget);
      expect(find.text("This promo code isn't valid."), findsOneWidget);
      expect(
        find.text('Showing regular fares. Your booking is not blocked and ready to confirm.'),
        findsOneWidget,
      );
    });

    testWidgets('renders Screen 3 Promo Terms and Policies modal overlay', (tester) async {
      final bloc = ChooseRideBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChooseRideBloc>.value(
            value: bloc,
            child: const ChooseRidePage(),
          ),
        ),
      );

      bloc.emit(const ChooseRideState(
        status: ChooseRideStatus.promoApplied,
        showPromoTermsModal: true,
        tiers: RideOptionTier.standardTiers,
      ));
      await tester.pumpAndSettle();

      expect(find.text('PROMOTION TERMS & POLICIES'), findsOneWidget);
      expect(find.text('\$12.00 CAD'), findsOneWidget);
      expect(find.text('31 Oct 2026, 11:59 PM MST'), findsOneWidget);
      expect(find.text('Cannot be stacked with promotions'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Remove promo code'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 4 Demo State chips and promo teaser card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChooseRidePage(
            initialDemoState: ChooseRideDemoState.collapsed,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DEMO STATE:'), findsOneWidget);
      expect(find.text('1. Collapsed'), findsOneWidget);
      expect(find.text('2. Expanded'), findsOneWidget);
      expect(find.text('3. Applying'), findsOneWidget);
      expect(find.text('Have a promo code?'), findsOneWidget);
      expect(find.text('Bridge City discounts applied at checkout'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });
  });
}
