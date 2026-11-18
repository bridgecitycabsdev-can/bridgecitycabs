import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/otp/otp.dart';

class MockTestOtpRepository implements OtpRepository {
  bool shouldFail = false;
  int resendCalls = 0;

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    if (shouldFail) {
      throw const FormatException('Incorrect code. Please try again.');
    }
    return true;
  }

  @override
  Future<void> resendOtp(String phone) async {
    resendCalls++;
  }
}

void main() {
  group('OtpBloc Tests', () {
    late MockTestOtpRepository repository;
    late OtpBloc bloc;

    setUp(() {
      repository = MockTestOtpRepository();
      bloc = OtpBloc(
        repository: repository,
        initialPhone: '+15873295577',
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is OtpInitialState with masked phone', () {
      expect(bloc.state, isA<OtpInitialState>());
      expect(bloc.state.phone, '+15873295577');
      expect(bloc.state.maskedPhone, '+1 (587) ••• ••77');
      expect(bloc.state.code, isEmpty);
    });

    test('entering digits transitions through typing and completes at 6 digits', () async {
      bloc.add(const OtpDigitEntered('4'));
      bloc.add(const OtpDigitEntered('8'));
      bloc.add(const OtpDigitEntered('2'));
      bloc.add(const OtpDigitEntered('9'));
      bloc.add(const OtpDigitEntered('1'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<OtpState>((state) {
          return state is OtpTypingState && state.code == '48291';
        })),
      );

      bloc.add(const OtpDigitEntered('5'));
      await expectLater(
        bloc.stream,
        emits(predicate<OtpState>((state) {
          return state is OtpAutofilledState &&
              state.code == '482915' &&
              state.isCodeComplete;
        })),
      );
    });

    test('deleting digit removes character', () async {
      bloc.add(const OtpDigitEntered('4'));
      bloc.add(const OtpDigitEntered('8'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const OtpDigitDeleted());
      await expectLater(
        bloc.stream,
        emits(predicate<OtpState>((state) => state.code == '4')),
      );
    });

    test('autofill sets complete code', () async {
      bloc.add(const OtpCodeAutofilled('482915'));

      await expectLater(
        bloc.stream,
        emits(predicate<OtpState>((state) {
          return state is OtpAutofilledState &&
              state.code == '482915' &&
              state.canSubmit;
        })),
      );
    });

    test('submitting valid code emits OtpVerifyingState then OtpSuccessState', () async {
      bloc.add(const OtpCodeAutofilled('482915'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const OtpSubmitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<OtpVerifyingState>(),
          predicate<OtpState>((state) {
            return state is OtpSuccessState && state.targetRoute == '/home';
          }),
        ]),
      );
    });

    test('submitting incorrect code emits OtpErrorState with decremented attempts', () async {
      repository.shouldFail = true;
      bloc.add(const OtpCodeAutofilled('730942'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const OtpSubmitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<OtpVerifyingState>(),
          predicate<OtpState>((state) {
            return state is OtpErrorState &&
                state.attemptsRemaining == 2 &&
                state.errorMessage!.contains('2 attempts remaining');
          }),
        ]),
      );
    });

    test('resend requests new code and resets state', () async {
      bloc.add(const OtpResendRequested());

      await expectLater(
        bloc.stream,
        emits(predicate<OtpState>((state) {
          return state is OtpInitialState &&
              state.code.isEmpty &&
              state.resendTimer.remainingSeconds == 30;
        })),
      );

      expect(repository.resendCalls, 1);
    });

    test('edit phone tapped emits OtpNavigateToPhoneState', () async {
      bloc.add(const OtpEditPhoneTapped());

      await expectLater(
        bloc.stream,
        emits(isA<OtpNavigateToPhoneState>()),
      );
    });
  });
}
