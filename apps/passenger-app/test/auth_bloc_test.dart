import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/auth/auth.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldThrowRateLimit = false;
  int cooldownSeconds = 300;
  int helpCalls = 0;

  @override
  Future<String> requestOtp(String rawPhone) async {
    if (shouldThrowRateLimit) {
      throw RateLimitException(
        cooldownSeconds: cooldownSeconds,
        message: 'Too many attempts',
      );
    }
    return '+15873295577';
  }

  @override
  Future<bool> callDispatchSupport() async {
    helpCalls++;
    return true;
  }
}

void main() {
  group('AuthBloc Tests', () {
    late MockAuthRepository repository;
    late AuthBloc bloc;

    setUp(() {
      repository = MockAuthRepository();
      bloc = AuthBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AuthPhoneEmpty', () {
      expect(bloc.state, isA<AuthPhoneEmpty>());
      expect(bloc.state.isEmpty, isTrue);
    });

    test('valid Canadian number emits AuthPhoneValid', () async {
      bloc.add(const AuthPhoneChanged('5873295577'));

      await expectLater(
        bloc.stream,
        emits(predicate<AuthState>((state) {
          return state is AuthPhoneValid &&
              state.formattedPhone == '(587) 329-5577' &&
              state.rawPhone == '5873295577';
        })),
      );
    });

    test('incomplete number emits AuthPhoneInvalid', () async {
      bloc.add(const AuthPhoneChanged('58732'));

      await expectLater(
        bloc.stream,
        emits(predicate<AuthState>((state) {
          return state is AuthPhoneInvalid &&
              state.formattedPhone == '(587) 32' &&
              state.errorMessage == 'Enter a valid phone number';
        })),
      );
    });

    test('clearing phone emits AuthPhoneEmpty', () async {
      bloc.add(const AuthPhoneChanged('5873295577'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const AuthPhoneChanged(''));
      await expectLater(
        bloc.stream,
        emits(isA<AuthPhoneEmpty>()),
      );
    });

    test('submitting valid phone emits AuthSubmitting then AuthCodeSentSuccess', () async {
      bloc.add(const AuthPhoneChanged('5873295577'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const AuthSubmitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthSubmitting>(),
          predicate<AuthState>((state) {
            return state is AuthCodeSentSuccess &&
                state.targetRoute == '/code?phone=%2B15873295577';
          }),
        ]),
      );
    });

    test('rate limited error emits AuthRateLimited with cooldown timer', () async {
      repository.shouldThrowRateLimit = true;
      repository.cooldownSeconds = 296;

      bloc.add(const AuthPhoneChanged('5873295577'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const AuthSubmitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthSubmitting>(),
          predicate<AuthState>((state) {
            return state is AuthRateLimited &&
                state.cooldown?.formattedTime == '04:56' &&
                state.isRateLimited;
          }),
        ]),
      );
    });

    test('edit wrong number resets submitting back to valid', () async {
      bloc.add(const AuthPhoneChanged('5873295577'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Force submitting state
      bloc.emit(const AuthSubmitting(
        rawPhone: '5873295577',
        formattedPhone: '(587) 329-5577',
      ));

      bloc.add(const AuthEditPhoneTapped());

      await expectLater(
        bloc.stream,
        emits(isA<AuthPhoneValid>()),
      );
    });

    test('help tapped calls dispatch support', () async {
      bloc.add(const AuthHelpTapped());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(repository.helpCalls, 1);
    });
  });
}
