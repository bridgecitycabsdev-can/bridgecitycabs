import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/delete_account_model.dart';
import '../../data/repositories/delete_account_repository.dart';
import 'delete_account_event.dart';
import 'delete_account_state.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final DeleteAccountRepository repository;

  DeleteAccountBloc({DeleteAccountRepository? repository})
      : repository = repository ?? MockDeleteAccountRepository(),
        super(const DeleteAccountState()) {
    on<DeleteAccountStarted>(_onStarted);
    on<DeleteAccountContinueFromWarningTapped>(_onContinueFromWarningTapped);
    on<DeleteAccountKeepAccountTapped>(_onKeepAccountTapped);
    on<DeleteAccountReasonSelected>(_onReasonSelected);
    on<DeleteAccountFeedbackChanged>(_onFeedbackChanged);
    on<DeleteAccountAcknowledgmentToggled>(_onAcknowledgmentToggled);
    on<DeleteAccountOtpDigitChanged>(_onOtpDigitChanged);
    on<DeleteAccountResendOtpTapped>(_onResendOtpTapped);
    on<DeleteAccountSubmitDeletionTapped>(_onSubmitDeletionTapped);
    on<DeleteAccountSafeguardSelected>(_onSafeguardSelected);
    on<DeleteAccountStepChanged>(_onStepChanged);
    on<DeleteAccountSimulateReturnLoginTapped>(_onSimulateReturnLoginTapped);
    on<DeleteAccountDoneTapped>(_onDoneTapped);
  }

  void _onStarted(
    DeleteAccountStarted event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(step: event.initialStep));
  }

  void _onContinueFromWarningTapped(
    DeleteAccountContinueFromWarningTapped event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(step: DeleteAccountStep.verification));
  }

  void _onKeepAccountTapped(
    DeleteAccountKeepAccountTapped event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Account deletion cancelled. Your account remains active.',
    ));
  }

  void _onReasonSelected(
    DeleteAccountReasonSelected event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(selectedReason: event.reason));
  }

  void _onFeedbackChanged(
    DeleteAccountFeedbackChanged event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(feedbackText: event.feedback));
  }

  void _onAcknowledgmentToggled(
    DeleteAccountAcknowledgmentToggled event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(isAcknowledged: event.isAcknowledged));
  }

  void _onOtpDigitChanged(
    DeleteAccountOtpDigitChanged event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(otpCode: event.otp));
  }

  Future<void> _onResendOtpTapped(
    DeleteAccountResendOtpTapped event,
    Emitter<DeleteAccountState> emit,
  ) async {
    await repository.requestDeletionOtp('+14035550117');
    emit(state.copyWith(
      resendCountdownSeconds: 27,
      feedbackMessage: 'New 6-digit confirmation code sent via SMS.',
    ));
  }

  Future<void> _onSubmitDeletionTapped(
    DeleteAccountSubmitDeletionTapped event,
    Emitter<DeleteAccountState> emit,
  ) async {
    if (!state.isAcknowledged) {
      emit(state.copyWith(
        errorMessage: 'Please acknowledge the terms before proceeding.',
      ));
      return;
    }

    emit(state.copyWith(isSubmitting: true));
    try {
      final res = await repository.submitAccountDeletion(
        reason: state.selectedReason,
        feedback: state.feedbackText,
        otp: state.otpCode,
      );
      emit(state.copyWith(
        isSubmitting: false,
        result: res,
        step: DeleteAccountStep.requestedResult,
        feedbackMessage: 'Account scheduled for deletion. 30-day grace period started.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSafeguardSelected(
    DeleteAccountSafeguardSelected event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(selectedSafeguard: event.safeguard));
  }

  void _onStepChanged(
    DeleteAccountStepChanged event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(step: event.step));
  }

  Future<void> _onSimulateReturnLoginTapped(
    DeleteAccountSimulateReturnLoginTapped event,
    Emitter<DeleteAccountState> emit,
  ) async {
    final restored = await repository.restoreAccount();
    emit(state.copyWith(
      step: restored ? DeleteAccountStep.warning : state.step,
      feedbackMessage: restored
          ? 'Welcome back! Your account has been restored from deletion grace.'
          : 'This account is closed and cannot be restored from the app.',
    ));
  }

  void _onDoneTapped(
    DeleteAccountDoneTapped event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Signed out of Bridge City Cabs.',
    ));
  }
}
