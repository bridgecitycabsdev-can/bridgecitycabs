import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/delete_account/delete_account.dart';

void main() {
  group('DeleteAccountBloc Tests', () {
    late DeleteAccountBloc bloc;

    setUp(() {
      bloc = DeleteAccountBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state contains default values', () {
      expect(bloc.state.step, DeleteAccountStep.warning);
      expect(bloc.state.selectedReason, LeavingReason.privacyConcerns);
      expect(bloc.state.isAcknowledged, isTrue);
      expect(bloc.state.otpCode, '482');
      expect(bloc.state.resendCountdownSeconds, 27);
      expect(bloc.state.formattedCountdown, '0:27');
    });

    test('DeleteAccountContinueFromWarningTapped transitions to verification', () async {
      bloc.add(const DeleteAccountContinueFromWarningTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<DeleteAccountState>((s) => s.step == DeleteAccountStep.verification)),
      );
    });

    test('DeleteAccountReasonSelected updates selected reason', () async {
      bloc.add(const DeleteAccountReasonSelected(LeavingReason.dontUseApp));
      await expectLater(
        bloc.stream,
        emits(predicate<DeleteAccountState>((s) => s.selectedReason == LeavingReason.dontUseApp)),
      );
    });

    test('DeleteAccountAcknowledgmentToggled updates acknowledgement', () async {
      bloc.add(const DeleteAccountAcknowledgmentToggled(false));
      await expectLater(
        bloc.stream,
        emits(predicate<DeleteAccountState>((s) => s.isAcknowledged == false)),
      );
    });

    test('DeleteAccountOtpDigitChanged updates OTP code', () async {
      bloc.add(const DeleteAccountOtpDigitChanged('482000'));
      await expectLater(
        bloc.stream,
        emits(predicate<DeleteAccountState>((s) => s.otpCode == '482000')),
      );
    });

    test('DeleteAccountSubmitDeletionTapped triggers deletion and reaches requestedResult', () async {
      bloc.add(const DeleteAccountSubmitDeletionTapped());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DeleteAccountState>((s) => s.isSubmitting == true),
          predicate<DeleteAccountState>((s) =>
              s.isSubmitting == false &&
              s.step == DeleteAccountStep.requestedResult &&
              s.result.targetDeletionDate == '30 Nov 2026'),
        ]),
      );
    });

    test('DeleteAccountSafeguardSelected switches safeguard in matrix', () async {
      bloc.add(const DeleteAccountSafeguardSelected(AccountSafeguardState.state1ActiveTrip));
      await expectLater(
        bloc.stream,
        emits(predicate<DeleteAccountState>((s) =>
            s.selectedSafeguard == AccountSafeguardState.state1ActiveTrip)),
      );
    });

    test('DeleteAccountSimulateReturnLoginTapped restores account to warning', () async {
      bloc.add(const DeleteAccountSimulateReturnLoginTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<DeleteAccountState>((s) =>
            s.step == DeleteAccountStep.warning &&
            s.feedbackMessage != null &&
            s.feedbackMessage!.contains('restored'))),
      );
    });
  });
}
