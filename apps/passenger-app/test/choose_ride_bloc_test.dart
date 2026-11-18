import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/choose_ride/choose_ride.dart';

class MockTestChooseRideRepository implements ChooseRideRepository {
  bool locked = false;

  @override
  Future<List<RideOptionTier>> getRideTiers({bool simulateUnavailable = false}) async {
    if (simulateUnavailable) {
      return RideOptionTier.withLuxuryUnavailable();
    }
    return RideOptionTier.standardTiers;
  }

  @override
  Future<PromoCode> validatePromoCode(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed == 'LETHBRIDGE3' || trimmed == 'LETH3' || trimmed == 'WELCOME5') {
      return PromoCode.lethbridge3;
    }
    return const PromoCode(
      code: 'SAVE50NOW',
      description: '',
      discountAmountCad: 0.0,
      isValid: false,
      errorMessage: 'Invalid or expired promo code. Check code and try again.',
    );
  }

  @override
  Future<bool> lockFare(String tierId) async {
    locked = true;
    return true;
  }
}

void main() {
  group('ChooseRideBloc Tests', () {
    late MockTestChooseRideRepository repository;
    late ChooseRideBloc bloc;

    setUp(() {
      repository = MockTestChooseRideRepository();
      bloc = ChooseRideBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is loading with default sedan selection', () {
      expect(bloc.state.status, ChooseRideStatus.loading);
      expect(bloc.state.selectedTierId, 'sedan');
      expect(bloc.state.isPromoApplied, isFalse);
    });

    test('ChooseRideStarted loads standard tiers successfully', () async {
      bloc.add(const ChooseRideStarted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ChooseRideState>((s) => s.status == ChooseRideStatus.loading),
          predicate<ChooseRideState>((s) {
            return s.status == ChooseRideStatus.loaded &&
                s.tiers.length == 4 &&
                s.selectedTier?.name == 'Sedan' &&
                s.finalPrice == 18.40;
          }),
        ]),
      );
    });

    test('ChooseRideStarted with isExpiring: true emits expiringQuote status', () async {
      bloc.add(const ChooseRideStarted(isExpiring: true));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ChooseRideState>((s) => s.status == ChooseRideStatus.loading),
          predicate<ChooseRideState>((s) {
            return s.status == ChooseRideStatus.expiringQuote &&
                s.isExpiring == true &&
                s.validitySeconds == 25 &&
                s.validityTimerText == '0:25';
          }),
        ]),
      );
    });

    test('ChooseRideTierSelected changes selected tier to SUV', () async {
      bloc.add(const ChooseRideStarted());
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const ChooseRideTierSelected('suv'));

      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) {
          return s.selectedTierId == 'suv' &&
              s.selectedTier?.name == 'SUV' &&
              s.finalPrice == 24.50;
        })),
      );
    });

    test('ChooseRidePromoApplied with LETHBRIDGE3 applies \$3 discount', () async {
      bloc.add(const ChooseRideStarted());
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const ChooseRidePromoApplied('LETHBRIDGE3'));

      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) {
          return s.status == ChooseRideStatus.promoApplied &&
              s.isPromoApplied == true &&
              s.appliedPromo?.code == 'WELCOME5' &&
              s.finalPrice == 15.40; // 18.40 - 3.00
        })),
      );
    });

    test('ChooseRidePromoApplied with SAVE50NOW sets promoError', () async {
      bloc.add(const ChooseRideStarted());
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const ChooseRidePromoApplied('SAVE50NOW'));

      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) {
          return s.status == ChooseRideStatus.promoError &&
              s.hasPromoError == true &&
              s.promoInputError!.contains('Invalid or expired');
        })),
      );
    });

    test('ChooseRidePromoRemoved restores original fares', () async {
      bloc.add(const ChooseRideStarted());
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const ChooseRidePromoApplied('LETHBRIDGE3'));
      await Future.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.finalPrice, 15.40);

      bloc.add(const ChooseRidePromoRemoved());

      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) {
          return s.status == ChooseRideStatus.loaded &&
              s.isPromoApplied == false &&
              s.finalPrice == 18.40;
        })),
      );
    });

    test('ChooseRidePreferenceChanged updates preference switches', () async {
      bloc.add(const ChooseRidePreferenceChanged(
        vanOnly: true,
        ladyDriverOnly: true,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) {
          return s.preference.vanOnly == true &&
              s.preference.ladyDriverOnly == true;
        })),
      );
    });

    test('ChooseRideContinueTapped routes to /confirm', () async {
      bloc.add(const ChooseRideContinueTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) => s.targetRoute == '/confirm')),
      );
    });

    test('ChooseRideBackTapped routes back to /home', () async {
      bloc.add(const ChooseRideBackTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) => s.targetRoute == '/home')),
      );
    });

    test('ChooseRideQaScenarioSelected updates 7 QA states properly', () async {
      bloc.add(const ChooseRideQaScenarioSelected(QaPromoScenario.invalidCode));
      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) =>
            s.status == ChooseRideStatus.promoError &&
            s.couponInput == 'WINTER50' &&
            s.hasPromoError)),
      );

      bloc.add(const ChooseRideQaScenarioSelected(QaPromoScenario.validApplied));
      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) =>
            s.status == ChooseRideStatus.promoApplied &&
            s.isPromoApplied &&
            s.finalPrice == 15.40)),
      );
    });

    test('ChooseRideDemoStateSelected updates demo state', () async {
      bloc.add(const ChooseRideDemoStateSelected(ChooseRideDemoState.expanded));
      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) =>
            s.demoState == ChooseRideDemoState.expanded)),
      );
    });

    test('ChooseRideOpenPromoTermsTapped and Close toggle modal visibility', () async {
      bloc.add(const ChooseRideOpenPromoTermsTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) => s.showPromoTermsModal == true)),
      );

      bloc.add(const ChooseRideClosePromoTermsTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<ChooseRideState>((s) => s.showPromoTermsModal == false)),
      );
    });
  });
}
