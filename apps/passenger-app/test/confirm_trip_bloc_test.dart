import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/confirm_trip/confirm_trip.dart';

class MockTestConfirmTripRepository implements ConfirmTripRepository {
  bool simulateDecline = false;
  bool simulateFareChange = false;
  bool booked = false;

  @override
  Future<bool> bookTrip({
    required PaymentMethodInfo payment,
    required double totalAmount,
  }) async {
    if (simulateDecline && payment.isCard) {
      throw Exception('Card declined');
    }
    booked = true;
    return true;
  }

  @override
  Future<FareBreakdown?> checkForFareUpdate() async {
    if (simulateFareChange) {
      return FareBreakdown.fareChanged;
    }
    return null;
  }

  @override
  Future<PaymentMethodInfo> linkNewCard() async {
    return PaymentMethodInfo.linkedVisa;
  }
}

void main() {
  group('ConfirmTripBloc Tests', () {
    late MockTestConfirmTripRepository repository;
    late ConfirmTripBloc bloc;

    setUp(() {
      repository = MockTestConfirmTripRepository();
      bloc = ConfirmTripBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state defaults to Cash and ready status', () {
      expect(bloc.state.status, ConfirmTripStatus.ready);
      expect(bloc.state.payment.isCash, isTrue);
      expect(bloc.state.canBook, isTrue);
      expect(bloc.state.fare.totalCad, 22.10);
    });

    test('switching to Card without linked card emits cardRequired', () async {
      bloc.add(const ConfirmTripStarted(
        initialPayment: PaymentType.card,
        hasLinkedCard: false,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<ConfirmTripState>((s) {
          return s.status == ConfirmTripStatus.cardRequired &&
              s.payment.isCard &&
              !s.payment.isLinked &&
              s.canBook == false;
        })),
      );
    });

    test('linking card transitions from cardRequired to ready', () async {
      bloc.add(const ConfirmTripStarted(
        initialPayment: PaymentType.card,
        hasLinkedCard: false,
      ));
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const ConfirmTripAddCardTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<ConfirmTripState>((s) {
          return s.status == ConfirmTripStatus.ready &&
              s.payment.isCard &&
              s.payment.isLinked &&
              s.canBook == true;
        })),
      );
    });

    test('driver notes update persists in state', () async {
      bloc.add(const ConfirmTripDriverNotesUpdated('Gate code #4412'));

      await expectLater(
        bloc.stream,
        emits(predicate<ConfirmTripState>((s) {
          return s.details.driverNotes == 'Gate code #4412';
        })),
      );
    });

    test('successful booking emits booking then success and routes to /searching', () async {
      bloc.add(const ConfirmTripBookTapped());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ConfirmTripState>((s) => s.status == ConfirmTripStatus.booking),
          predicate<ConfirmTripState>((s) {
            return s.status == ConfirmTripStatus.success &&
                s.targetRoute == '/searching';
          }),
        ]),
      );
      expect(repository.booked, isTrue);
    });

    test('card declined emits declined state', () async {
      repository.simulateDecline = true;
      bloc.add(const ConfirmTripPaymentTypeChanged(PaymentType.card));
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const ConfirmTripBookTapped());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ConfirmTripState>((s) => s.status == ConfirmTripStatus.booking),
          predicate<ConfirmTripState>((s) {
            return s.status == ConfirmTripStatus.declined &&
                s.payment.isDeclined;
          }),
        ]),
      );
    });

    test('dismissing decline banner switches back to Cash', () async {
      bloc.add(const ConfirmTripStarted(simulateDecline: true));
      await Future.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.isDeclined, isTrue);

      bloc.add(const ConfirmTripDismissDeclineBanner());

      await expectLater(
        bloc.stream,
        emits(predicate<ConfirmTripState>((s) {
          return s.status == ConfirmTripStatus.ready &&
              s.payment.isCash &&
              s.canBook == true;
        })),
      );
    });

    test('fare recalculation triggers fareChanged state with \$24.60', () async {
      repository.simulateFareChange = true;
      bloc.add(const ConfirmTripBookTapped());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ConfirmTripState>((s) => s.status == ConfirmTripStatus.booking),
          predicate<ConfirmTripState>((s) {
            return s.status == ConfirmTripStatus.fareChanged &&
                s.fare.newFareCad == 24.60 &&
                s.fare.previousFareCad == 22.10;
          }),
        ]),
      );
    });

    test('accepting fare change routes to /searching', () async {
      bloc.add(const ConfirmTripStarted(simulateFareChange: true));
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const ConfirmTripFareChangeAccepted());

      await expectLater(
        bloc.stream,
        emits(predicate<ConfirmTripState>((s) {
          return s.status == ConfirmTripStatus.success &&
              s.targetRoute == '/searching';
        })),
      );
    });

    test('declining fare change routes back to /options', () async {
      bloc.add(const ConfirmTripStarted(simulateFareChange: true));
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const ConfirmTripFareChangeDeclined());

      await expectLater(
        bloc.stream,
        emits(predicate<ConfirmTripState>((s) => s.targetRoute == '/options')),
      );
    });
  });
}
