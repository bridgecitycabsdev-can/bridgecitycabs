import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/auth/auth.dart';

class TestDriverAuthRepository implements DriverAuthRepository {
  final bool isRegistered;
  final bool shouldSucceed;

  TestDriverAuthRepository({
    this.isRegistered = true,
    this.shouldSucceed = true,
  });

  @override
  Future<bool> isRegisteredDriver(String digitsOnlyPhone) async => isRegistered;

  @override
  Future<bool> sendVerificationCode(String digitsOnlyPhone) async =>
      shouldSucceed;

  @override
  Future<int> getRemainingLockoutSeconds(String digitsOnlyPhone) async => 0;
}

void main() {
  group('DriverAuthBloc Tests', () {
    test('initial state has empty phone, status initial and canContinue false', () {
      final bloc = DriverAuthBloc(repository: TestDriverAuthRepository());
      expect(bloc.state.status, DriverAuthStatus.initial);
      expect(bloc.state.digitsOnly, '');
      expect(bloc.state.formattedPhone, '');
      expect(bloc.state.canContinue, isFalse);
    });

    test('entering incomplete digits sets status to invalid with error message', () {
      final bloc = DriverAuthBloc(repository: TestDriverAuthRepository());
      bloc.add(const DriverAuthPhoneChanged('40355501'));

      expectLater(
        bloc.stream,
        emits(predicate<DriverAuthState>(
          (s) =>
              s.status == DriverAuthStatus.invalid &&
              s.digitsOnly == '40355501' &&
              s.formattedPhone == '(403) 555-01' &&
              s.errorMessage != null &&
              s.canContinue == false,
        )),
      );
    });

    test('entering 10 digits sets status to valid and canContinue true', () {
      final bloc = DriverAuthBloc(repository: TestDriverAuthRepository());
      bloc.add(const DriverAuthPhoneChanged('(403) 555-0192'));

      expectLater(
        bloc.stream,
        emits(predicate<DriverAuthState>(
          (s) =>
              s.status == DriverAuthStatus.valid &&
              s.digitsOnly == '4035550192' &&
              s.formattedPhone == '(403) 555-0192' &&
              s.errorMessage == null &&
              s.canContinue == true,
        )),
      );
    });

    test('clearing phone resets to initial state', () {
      final bloc = DriverAuthBloc(repository: TestDriverAuthRepository());
      bloc.add(const DriverAuthPhoneCleared());

      expectLater(
        bloc.stream,
        emits(predicate<DriverAuthState>(
          (s) => s.status == DriverAuthStatus.initial && s.digitsOnly == '',
        )),
      );
    });

    test('submitting registered phone sends code and transitions to codeSent', () async {
      final bloc = DriverAuthBloc(
        repository: TestDriverAuthRepository(isRegistered: true, shouldSucceed: true),
      );

      bloc.add(const DriverAuthPhoneChanged('4035550192'));
      await expectLater(
        bloc.stream,
        emits(predicate<DriverAuthState>((s) => s.status == DriverAuthStatus.valid)),
      );

      bloc.add(const DriverAuthSubmitted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverAuthState>((s) => s.status == DriverAuthStatus.submitting),
          predicate<DriverAuthState>((s) => s.status == DriverAuthStatus.codeSent),
        ]),
      );
    });

    test('submitting unregistered phone sets status to unregistered', () async {
      final bloc = DriverAuthBloc(
        repository: TestDriverAuthRepository(isRegistered: false),
      );

      bloc.add(const DriverAuthPhoneChanged('4035559876'));
      await expectLater(
        bloc.stream,
        emits(predicate<DriverAuthState>(
            (s) => s.status == DriverAuthStatus.unregistered)),
      );

      bloc.add(const DriverAuthSubmitted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverAuthState>((s) => s.status == DriverAuthStatus.submitting),
          predicate<DriverAuthState>(
              (s) => s.status == DriverAuthStatus.unregistered),
        ]),
      );
    });

    test('lockout tick decrements remaining time and not your number resets', () {
      final bloc = DriverAuthBloc(repository: TestDriverAuthRepository());

      bloc.add(const DriverAuthStateSwitched(DriverAuthStatus.locked));
      expect(bloc.state.status, DriverAuthStatus.locked);
      expect(bloc.state.lockoutRemainingSeconds, 897);
      expect(bloc.state.formattedLockoutTime, '14:57');

      bloc.add(const DriverAuthLockoutTick());
      expect(bloc.state.lockoutRemainingSeconds, 896);

      bloc.add(const DriverAuthNotYourNumberTapped());
      expect(bloc.state.status, DriverAuthStatus.initial);
      expect(bloc.state.digitsOnly, '');
    });

    test('state switched handles all 6 statuses correctly', () {
      final bloc = DriverAuthBloc(repository: TestDriverAuthRepository());

      bloc.add(const DriverAuthStateSwitched(DriverAuthStatus.valid));
      expect(bloc.state.status, DriverAuthStatus.valid);
      expect(bloc.state.digitsOnly, '4035550192');

      bloc.add(const DriverAuthStateSwitched(DriverAuthStatus.invalid));
      expect(bloc.state.status, DriverAuthStatus.invalid);
      expect(bloc.state.errorMessage, isNotNull);

      bloc.add(const DriverAuthStateSwitched(DriverAuthStatus.unregistered));
      expect(bloc.state.status, DriverAuthStatus.unregistered);

      bloc.add(const DriverAuthStateSwitched(DriverAuthStatus.locked));
      expect(bloc.state.status, DriverAuthStatus.locked);

      bloc.add(const DriverAuthStateSwitched(DriverAuthStatus.submitting));
      expect(bloc.state.status, DriverAuthStatus.submitting);
    });
  });
}
