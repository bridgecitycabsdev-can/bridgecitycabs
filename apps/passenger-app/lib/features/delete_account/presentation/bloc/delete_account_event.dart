import 'package:equatable/equatable.dart';
import '../../data/models/delete_account_model.dart';

abstract class DeleteAccountEvent extends Equatable {
  const DeleteAccountEvent();

  @override
  List<Object?> get props => [];
}

class DeleteAccountStarted extends DeleteAccountEvent {
  final DeleteAccountStep initialStep;

  const DeleteAccountStarted({
    this.initialStep = DeleteAccountStep.warning,
  });

  @override
  List<Object?> get props => [initialStep];
}

class DeleteAccountContinueFromWarningTapped extends DeleteAccountEvent {
  const DeleteAccountContinueFromWarningTapped();
}

class DeleteAccountKeepAccountTapped extends DeleteAccountEvent {
  const DeleteAccountKeepAccountTapped();
}

class DeleteAccountReasonSelected extends DeleteAccountEvent {
  final LeavingReason reason;

  const DeleteAccountReasonSelected(this.reason);

  @override
  List<Object?> get props => [reason];
}

class DeleteAccountFeedbackChanged extends DeleteAccountEvent {
  final String feedback;

  const DeleteAccountFeedbackChanged(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

class DeleteAccountAcknowledgmentToggled extends DeleteAccountEvent {
  final bool isAcknowledged;

  const DeleteAccountAcknowledgmentToggled(this.isAcknowledged);

  @override
  List<Object?> get props => [isAcknowledged];
}

class DeleteAccountOtpDigitChanged extends DeleteAccountEvent {
  final String otp;

  const DeleteAccountOtpDigitChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

class DeleteAccountResendOtpTapped extends DeleteAccountEvent {
  const DeleteAccountResendOtpTapped();
}

class DeleteAccountSubmitDeletionTapped extends DeleteAccountEvent {
  const DeleteAccountSubmitDeletionTapped();
}

class DeleteAccountSafeguardSelected extends DeleteAccountEvent {
  final AccountSafeguardState safeguard;

  const DeleteAccountSafeguardSelected(this.safeguard);

  @override
  List<Object?> get props => [safeguard];
}

class DeleteAccountStepChanged extends DeleteAccountEvent {
  final DeleteAccountStep step;

  const DeleteAccountStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class DeleteAccountSimulateReturnLoginTapped extends DeleteAccountEvent {
  const DeleteAccountSimulateReturnLoginTapped();
}

class DeleteAccountDoneTapped extends DeleteAccountEvent {
  const DeleteAccountDoneTapped();
}
