import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/add_card/add_card.dart';

void main() {
  group('AddCardBloc Tests', () {
    late MockAddCardRepository repository;
    late AddCardBloc bloc;

    setUp(() {
      repository = MockAddCardRepository(
        delay: const Duration(milliseconds: 10),
      );
      bloc = AddCardBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state defaults to initial status with empty card and default Lethbridge postal code', () {
      expect(bloc.state.status, AddCardStatus.initial);
      expect(bloc.state.isInitial, isTrue);
      expect(bloc.state.form.cardNumber, isEmpty);
      expect(bloc.state.form.postalCode, 'T1K 4A8');
      expect(bloc.state.form.isDefault, isTrue);
      expect(bloc.state.canSave, isFalse);
    });

    test('entering valid card inputs enables canSave and detects brand', () async {
      bloc.add(const AddCardStarted());
      await pumpEventQueue();

      bloc.add(const AddCardNumberChanged('4242 4242 4242 4242'));
      bloc.add(const AddCardExpiryChanged('11/28'));
      bloc.add(const AddCardCvcChanged('123'));
      bloc.add(const AddCardPostalCodeChanged('T1J 0V4'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<AddCardState>((s) {
          return s.form.isFormValid &&
              s.canSave &&
              s.form.detectedBrand == CardBrand.visa &&
              s.form.last4 == '4242';
        })),
      );
    });

    test('save tapped triggers tokenizing and finishes with success', () async {
      const validForm = CardFormData(
        cardNumber: '4242 4242 4242 4242',
        expiry: '11/28',
        cvc: '123',
        postalCode: 'T1J 0V4',
      );

      bloc.add(const AddCardStarted(initialForm: validForm));
      await pumpEventQueue();

      bloc.add(const AddCardSaveTapped());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AddCardState>((s) => s.status == AddCardStatus.tokenizing && s.isTokenizing),
          predicate<AddCardState>((s) => s.status == AddCardStatus.success && s.isSuccess),
        ]),
      );
    });

    test('3DS flow transitions through confirmingBank to threeDSecureOtp dialog and success on submit', () async {
      final threeDRepo = MockAddCardRepository(
        delay: const Duration(milliseconds: 10),
        require3DSecure: true,
      );
      final threeDBloc = AddCardBloc(repository: threeDRepo);

      const validForm = CardFormData(
        cardNumber: '4242 4242 4242 4242',
        expiry: '11/28',
        cvc: '123',
        postalCode: 'T1J 0V4',
      );

      threeDBloc.add(const AddCardStarted(initialForm: validForm));
      await pumpEventQueue();

      threeDBloc.add(const AddCardSaveTapped());

      await expectLater(
        threeDBloc.stream,
        emitsThrough(predicate<AddCardState>((s) {
          return s.status == AddCardStatus.threeDSecureOtp &&
              s.showThreeDDialog == true;
        })),
      );

      // Submit OTP
      threeDBloc.add(const AddCardOtpChanged('641892'));
      threeDBloc.add(const AddCardOtpSubmitted());

      await expectLater(
        threeDBloc.stream,
        emitsThrough(predicate<AddCardState>((s) {
          return s.status == AddCardStatus.success && !s.showThreeDDialog;
        })),
      );

      threeDBloc.close();
    });

    test('declined card transitions to declined state with error message', () async {
      final failRepo = MockAddCardRepository(
        delay: const Duration(milliseconds: 10),
        shouldDecline: true,
      );
      final failBloc = AddCardBloc(repository: failRepo);

      const validForm = CardFormData(
        cardNumber: '4242 4242 4242 4242',
        expiry: '08/27',
        cvc: '123',
        postalCode: 'T1J 1P4',
      );

      failBloc.add(const AddCardStarted(initialForm: validForm));
      await pumpEventQueue();

      failBloc.add(const AddCardSaveTapped());

      await expectLater(
        failBloc.stream,
        emitsThrough(predicate<AddCardState>((s) {
          return s.status == AddCardStatus.declined &&
              s.isDeclined &&
              s.errorMessage != null;
        })),
      );

      failBloc.close();
    });

    test('use different card resets state and clear errors', () async {
      bloc.add(const AddCardStarted(initialStatus: AddCardStatus.declined));
      await pumpEventQueue();

      bloc.add(const AddCardUseDifferentCardTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<AddCardState>((s) {
          return s.status == AddCardStatus.initial &&
              s.form.cardNumber.isEmpty &&
              s.errorMessage == null;
        })),
      );
    });

    test('return to payment methods sets navigateToPaymentMethods flag', () async {
      bloc.add(const AddCardStarted());
      await pumpEventQueue();

      bloc.add(const AddCardReturnToPaymentMethodsTapped());
      expect(bloc.state.navigateToPaymentMethods, isTrue);
    });
  });
}
