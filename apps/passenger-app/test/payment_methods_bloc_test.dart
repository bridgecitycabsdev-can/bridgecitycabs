import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/payment_methods/payment_methods.dart';

void main() {
  group('PaymentMethodsBloc Tests', () {
    late MockPaymentMethodsRepository repository;
    late PaymentMethodsBloc bloc;

    setUp(() {
      repository = MockPaymentMethodsRepository(
        delay: const Duration(milliseconds: 10),
      );
      bloc = PaymentMethodsBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state with mock cards defaults to loaded with 2 cards and Visa default', () async {
      bloc.add(const PaymentMethodsStarted(simulateLoading: false));
      await pumpEventQueue();

      expect(bloc.state.status, PaymentMethodsStatus.loaded);
      expect(bloc.state.cards.length, 2);
      expect(bloc.state.hasCards, isTrue);
      expect(bloc.state.cardsCountSubtitle, '2 cards available');
      expect(bloc.state.defaultCard?.brand, CardBrand.visa);
      expect(bloc.state.defaultCard?.last4, '4242');
      expect(bloc.state.isCashDefault, isFalse);
    });

    test('initial state with empty cards defaults to cash default and 0 on file', () async {
      bloc.add(const PaymentMethodsStarted(
        initialCards: [],
        simulateLoading: false,
      ));
      await pumpEventQueue();

      expect(bloc.state.status, PaymentMethodsStatus.loaded);
      expect(bloc.state.cards.isEmpty, isTrue);
      expect(bloc.state.hasCards, isFalse);
      expect(bloc.state.cardsCountSubtitle, '0 on file');
      expect(bloc.state.isCashDefault, isTrue);
    });

    test('selecting Cash sets selectedPaymentType to cash', () async {
      bloc.add(const PaymentMethodsStarted(simulateLoading: false));
      await pumpEventQueue();

      bloc.add(const PaymentMethodsCashSelected());

      await expectLater(
        bloc.stream,
        emits(predicate<PaymentMethodsState>((s) {
          return s.selectedPaymentType == SelectedPaymentType.cash &&
              s.isCashDefault == true;
        })),
      );
    });

    test('selecting another card transitions through updatingDefault with spinner', () async {
      bloc.add(const PaymentMethodsStarted(simulateLoading: false));
      await pumpEventQueue();

      const targetCardId = 'card_mc_8821';
      bloc.add(const PaymentMethodsCardSelected(targetCardId));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PaymentMethodsState>((s) {
            return s.status == PaymentMethodsStatus.updatingDefault &&
                s.isUpdatingDefault &&
                s.updatingCardId == targetCardId;
          }),
          predicate<PaymentMethodsState>((s) {
            return s.status == PaymentMethodsStatus.loaded &&
                !s.isUpdatingDefault &&
                s.updatingCardId == null &&
                s.defaultCard?.id == targetCardId &&
                s.defaultCard?.brand == CardBrand.mastercard;
          }),
        ]),
      );
    });

    test('removing a card updates list and preserves valid default', () async {
      bloc.add(const PaymentMethodsStarted(simulateLoading: false));
      await pumpEventQueue();

      final cardToRemove = bloc.state.cards.first;
      bloc.add(PaymentMethodsRemoveCardInitiated(cardToRemove));
      expect(bloc.state.cardPendingRemoval, cardToRemove);

      bloc.add(PaymentMethodsRemoveCardConfirmed(cardToRemove.id));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PaymentMethodsState>((s) => s.status == PaymentMethodsStatus.removingCard),
          predicate<PaymentMethodsState>((s) {
            return s.status == PaymentMethodsStatus.loaded &&
                s.cards.length == 1 &&
                s.cards.first.id == 'card_mc_8821' &&
                s.cards.first.isDefault == true;
          }),
        ]),
      );
    });

    test('add card event saves new card and updates card list', () async {
      bloc.add(const PaymentMethodsStarted(simulateLoading: false));
      await pumpEventQueue();

      bloc.add(const PaymentMethodsCardAdded(
        brand: CardBrand.amex,
        last4: '1005',
        expiry: '09/29',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PaymentMethodsState>((s) => s.status == PaymentMethodsStatus.loading),
          predicate<PaymentMethodsState>((s) {
            return s.status == PaymentMethodsStatus.loaded &&
                s.cards.length == 3 &&
                s.cards.any((c) => c.last4 == '1005');
          }),
        ]),
      );
    });

    test('error dismissal clears errorMessage and restores loaded state', () async {
      final failingRepo = MockPaymentMethodsRepository(
        delay: const Duration(milliseconds: 10),
        shouldFail: true,
      );
      final failBloc = PaymentMethodsBloc(repository: failingRepo);

      failBloc.add(const PaymentMethodsStarted(
        initialCards: PaymentMethodsConfig.mockCards,
        simulateLoading: false,
      ));
      await pumpEventQueue();

      failBloc.add(const PaymentMethodsCardSelected('card_mc_8821'));
      await pumpEventQueue();

      expect(failBloc.state.status, PaymentMethodsStatus.error);
      expect(failBloc.state.errorMessage, isNotNull);

      failBloc.add(const PaymentMethodsErrorDismissed());
      await pumpEventQueue();

      expect(failBloc.state.status, PaymentMethodsStatus.loaded);
      expect(failBloc.state.errorMessage, isNull);

      failBloc.close();
    });
  });
}
