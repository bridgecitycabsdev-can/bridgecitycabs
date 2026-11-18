import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/trip_receipt/trip_receipt.dart';

void main() {
  group('TripReceiptBloc Tests', () {
    late MockTripReceiptRepository repository;
    late TripReceiptBloc bloc;

    setUp(() {
      repository = MockTripReceiptRepository(
        delay: const Duration(milliseconds: 10),
      );
      bloc = TripReceiptBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state defaults to cashPending with default details', () {
      expect(bloc.state.status, TripReceiptStatus.cashPending);
      expect(bloc.state.isCashPending, isTrue);
      expect(bloc.state.canRateDriver, isFalse);
      expect(bloc.state.totalLabel, 'TOTAL DUE');
      expect(bloc.state.formattedTotal, r'$22.10 CAD');
      expect(bloc.state.receipt.driver.name, 'Michael K.');
      expect(bloc.state.receipt.driver.licensePlate, 'BCC • 892');
      expect(bloc.state.receipt.pickupAddress, contains('515 5th Ave S'));
      expect(bloc.state.receipt.dropoffAddress, contains('Park Place Mall'));
    });

    test('TripReceiptStarted with simulateLoading emits loading then resolves status', () async {
      bloc.add(const TripReceiptStarted(simulateLoading: true));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<TripReceiptState>((s) => s.isLoading && s.status == TripReceiptStatus.loading),
          predicate<TripReceiptState>((s) => s.isCashPending && s.status == TripReceiptStatus.cashPending),
        ]),
      );
    });

    test('determines cardPaid when fare paymentType is card', () async {
      const cardReceipt = TripReceiptDetails(
        fare: ReceiptFareBreakdown(
          subtotalCad: 21.05,
          gstCad: 1.05,
          paymentType: ReceiptPaymentType.card,
          cardLast4: '4242',
          paymentStatusText: 'VISA •••• 4242 Pre-authorized',
        ),
      );

      bloc.add(const TripReceiptStarted(
        receipt: cardReceipt,
        simulateLoading: false,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<TripReceiptState>((s) {
          return s.isCardPaid &&
              s.canRateDriver &&
              s.totalLabel == 'TOTAL PAID' &&
              s.formattedTotal == r'$22.10 CAD';
        })),
      );
    });

    test('determines discountApplied when fare has promo discount', () async {
      const promoReceipt = TripReceiptDetails(
        fare: ReceiptFareBreakdown(
          subtotalCad: 21.05,
          gstCad: 1.05,
          discountCad: 5.0,
          promoCode: 'BRIDGE5',
          paymentType: ReceiptPaymentType.card,
          cardLast4: '4242',
          paymentStatusText: 'VISA •••• 4242 Approved',
        ),
      );

      bloc.add(const TripReceiptStarted(
        receipt: promoReceipt,
        simulateLoading: false,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<TripReceiptState>((s) {
          return s.isDiscountApplied &&
              s.canRateDriver &&
              s.totalLabel == 'TOTAL PAID' &&
              s.formattedTotal == r'$17.10 CAD' &&
              s.receipt.fare.savingsPillText == r'BRIDGE5 • $5.00 CAD saved';
        })),
      );
    });

    test('cash payment confirmed event unlocks rating and sets green banner state', () async {
      bloc.add(const TripReceiptStarted(simulateLoading: false));
      await pumpEventQueue();

      expect(bloc.state.canRateDriver, isFalse);

      bloc.add(const TripReceiptCashPaymentConfirmed());

      await expectLater(
        bloc.stream,
        emits(predicate<TripReceiptState>((s) {
          return s.isCashConfirmed &&
              s.canRateDriver &&
              s.totalLabel == 'TOTAL PAID' &&
              s.receipt.fare.paymentStatusText == 'Cash (Driver Confirmed)';
        })),
      );
    });

    test('tapping rate driver opens sheet only when canRateDriver is true', () async {
      bloc.add(const TripReceiptStarted(simulateLoading: false));
      await pumpEventQueue();

      // In cashPending, canRateDriver is false
      bloc.add(const TripReceiptRateDriverTapped());
      expect(bloc.state.showRatingSheet, isFalse);

      // Confirm cash payment
      bloc.add(const TripReceiptCashPaymentConfirmed());
      await pumpEventQueue();
      expect(bloc.state.canRateDriver, isTrue);

      bloc.add(const TripReceiptRateDriverTapped());
      expect(bloc.state.showRatingSheet, isTrue);
    });

    test('submitting driver rating calls repository and saves rating info', () async {
      bloc.add(const TripReceiptStarted(
        initialStatus: TripReceiptStatus.cardPaid,
        simulateLoading: false,
      ));
      await pumpEventQueue();

      bloc.add(const TripReceiptRatingSubmitted(
        rating: 5,
        feedback: 'Great, polite driver and very clean car!',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<TripReceiptState>((s) => s.isSubmittingRating && !s.showRatingSheet),
          predicate<TripReceiptState>((s) {
            return !s.isSubmittingRating &&
                s.isRatingSubmitted &&
                s.receipt.userRating == 5 &&
                s.receipt.ratingFeedback == 'Great, polite driver and very clean car!';
          }),
        ]),
      );
    });

    test('report problem tapped sets showProblemSheet', () async {
      bloc.add(const TripReceiptStarted(simulateLoading: false));
      await pumpEventQueue();

      bloc.add(const TripReceiptReportProblemTapped());
      expect(bloc.state.showProblemSheet, isTrue);
    });

    test('copy tracking id sets isCopiedToClipboard', () async {
      bloc.add(const TripReceiptStarted(simulateLoading: false));
      await pumpEventQueue();

      bloc.add(const TripReceiptCopyTrackingIdTapped());
      expect(bloc.state.isCopiedToClipboard, isTrue);
    });

    test('done tapped sets navigateToHome', () async {
      bloc.add(const TripReceiptStarted(simulateLoading: false));
      await pumpEventQueue();

      bloc.add(const TripReceiptDoneTapped());
      expect(bloc.state.navigateToHome, isTrue);
    });
  });
}
