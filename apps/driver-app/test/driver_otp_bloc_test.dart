import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/otp/otp.dart';

class TestDriverOtpRepository implements DriverOtpRepository {
  final bool shouldSucceed;

  TestDriverOtpRepository({this.shouldSucceed = true});

  @override
  Future<bool> verifyOtp({required String phone, required String code}) async {
    if (code == '519482') return false;
    if (code == '409153') return false;
    return shouldSucceed;
  }

  @override
  Future<DriverRoutingPathwayType> resolveDriverPathway({
    required String phone,
  }) async {
    return DriverRoutingPathwayType.approvedDriver;
  }

  @override
  Future<bool> resendOtp({required String phone}) async => true;
}

void main() {
  group('DriverOtpBloc Tests', () {
    test('initial state has empty code, initial status, and canSubmit false', () {
      final bloc = DriverOtpBloc(repository: TestDriverOtpRepository());
      expect(bloc.state.status, DriverOtpStatus.initial);
      expect(bloc.state.code, '');
      expect(bloc.state.canSubmit, isFalse);
    });

    test('typing digits updates code and transitions to ready upon 6th digit', () {
      final bloc = DriverOtpBloc(repository: TestDriverOtpRepository());

      for (var d in ['8', '4', '2', '9', '1']) {
        bloc.add(DriverOtpDigitPressed(d));
      }
      expect(bloc.state.code, '84291');
      expect(bloc.state.canSubmit, isFalse);

      bloc.add(const DriverOtpDigitPressed('7'));
      expect(bloc.state.code, '842917');
      expect(bloc.state.status, DriverOtpStatus.ready);
      expect(bloc.state.canSubmit, isTrue);
    });

    test('backspace drops digit and resets to initial', () {
      final bloc = DriverOtpBloc(repository: TestDriverOtpRepository());
      bloc.add(const DriverOtpStateSwitched(DriverOtpStatus.ready));
      expect(bloc.state.code, '842917');

      bloc.add(const DriverOtpBackspacePressed());
      expect(bloc.state.code, '84291');
      expect(bloc.state.status, DriverOtpStatus.initial);
      expect(bloc.state.canSubmit, isFalse);
    });

    test('clear resets code completely', () {
      final bloc = DriverOtpBloc(repository: TestDriverOtpRepository());
      bloc.add(const DriverOtpStateSwitched(DriverOtpStatus.ready));
      expect(bloc.state.code, '842917');

      bloc.add(const DriverOtpClearPressed());
      expect(bloc.state.code, '');
      expect(bloc.state.status, DriverOtpStatus.initial);
    });

    test('submitting valid code transitions to submitting then verified', () async {
      final bloc = DriverOtpBloc(
        repository: TestDriverOtpRepository(shouldSucceed: true),
      );

      bloc.add(const DriverOtpStateSwitched(DriverOtpStatus.ready));
      bloc.add(const DriverOtpSubmitted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverOtpState>((s) => s.status == DriverOtpStatus.submitting),
          predicate<DriverOtpState>((s) =>
              s.status == DriverOtpStatus.verified &&
              s.targetRoute == '/home'),
        ]),
      );
    });

    test('submitting incorrect code transitions to incorrect state with error', () async {
      final bloc = DriverOtpBloc(repository: TestDriverOtpRepository());

      bloc.add(const DriverOtpStateSwitched(DriverOtpStatus.ready));
      // Type 519482 to trigger incorrect simulation
      bloc.add(const DriverOtpClearPressed());
      for (var d in ['5', '1', '9', '4', '8', '2']) {
        bloc.add(DriverOtpDigitPressed(d));
      }

      bloc.add(const DriverOtpSubmitted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverOtpState>((s) => s.status == DriverOtpStatus.submitting),
          predicate<DriverOtpState>((s) =>
              s.status == DriverOtpStatus.incorrect &&
              s.errorMessage == DriverOtpConfig.incorrectCodeError),
        ]),
      );
    });

    test('resend code restarts cooldown timer and emits feedback', () async {
      final bloc = DriverOtpBloc(repository: TestDriverOtpRepository());

      bloc.add(const DriverOtpResendTapped());
      expect(bloc.state.resendCooldownSeconds, 30);
      expect(bloc.state.status, DriverOtpStatus.initial);

      bloc.add(const DriverOtpTimerTick());
      expect(bloc.state.resendCooldownSeconds, 29);
    });

    test('state switched handles all 5 statuses accurately', () {
      final bloc = DriverOtpBloc(repository: TestDriverOtpRepository());

      bloc.add(const DriverOtpStateSwitched(DriverOtpStatus.initial));
      expect(bloc.state.status, DriverOtpStatus.initial);
      expect(bloc.state.code, '');

      bloc.add(const DriverOtpStateSwitched(DriverOtpStatus.ready));
      expect(bloc.state.status, DriverOtpStatus.ready);
      expect(bloc.state.code, '842917');

      bloc.add(const DriverOtpStateSwitched(DriverOtpStatus.incorrect));
      expect(bloc.state.status, DriverOtpStatus.incorrect);
      expect(bloc.state.code, '519482');

      bloc.add(const DriverOtpStateSwitched(DriverOtpStatus.expired));
      expect(bloc.state.status, DriverOtpStatus.expired);
      expect(bloc.state.code, '409153');

      bloc.add(const DriverOtpStateSwitched(DriverOtpStatus.submitting));
      expect(bloc.state.status, DriverOtpStatus.submitting);
    });
  });
}
