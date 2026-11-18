import 'package:equatable/equatable.dart';
import '../../data/models/delete_account_model.dart';

class DeleteAccountState extends Equatable {
  final DeleteAccountStep step;
  final LeavingReason selectedReason;
  final String feedbackText;
  final bool isAcknowledged;
  final String otpCode;
  final int resendCountdownSeconds;
  final AccountSafeguardState selectedSafeguard;
  final bool isSubmitting;
  final DeletionRequestResult result;
  final ActiveTripBlockerInfo activeTripBlocker;
  final UnpaidBalanceBlockerInfo unpaidBalanceBlocker;
  final String? feedbackMessage;
  final String? errorMessage;

  const DeleteAccountState({
    this.step = DeleteAccountStep.warning,
    this.selectedReason = LeavingReason.privacyConcerns,
    this.feedbackText = '',
    this.isAcknowledged = true,
    this.otpCode = '482',
    this.resendCountdownSeconds = 27,
    this.selectedSafeguard = AccountSafeguardState.none,
    this.isSubmitting = false,
    this.result = const DeletionRequestResult(),
    this.activeTripBlocker = const ActiveTripBlockerInfo(),
    this.unpaidBalanceBlocker = const UnpaidBalanceBlockerInfo(),
    this.feedbackMessage,
    this.errorMessage,
  });

  String get formattedCountdown {
    final mins = resendCountdownSeconds ~/ 60;
    final secs = resendCountdownSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  bool get canSubmit => isAcknowledged && !isSubmitting;

  DeleteAccountState copyWith({
    DeleteAccountStep? step,
    LeavingReason? selectedReason,
    String? feedbackText,
    bool? isAcknowledged,
    String? otpCode,
    int? resendCountdownSeconds,
    AccountSafeguardState? selectedSafeguard,
    bool? isSubmitting,
    DeletionRequestResult? result,
    ActiveTripBlockerInfo? activeTripBlocker,
    UnpaidBalanceBlockerInfo? unpaidBalanceBlocker,
    String? feedbackMessage,
    String? errorMessage,
  }) {
    return DeleteAccountState(
      step: step ?? this.step,
      selectedReason: selectedReason ?? this.selectedReason,
      feedbackText: feedbackText ?? this.feedbackText,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      otpCode: otpCode ?? this.otpCode,
      resendCountdownSeconds: resendCountdownSeconds ?? this.resendCountdownSeconds,
      selectedSafeguard: selectedSafeguard ?? this.selectedSafeguard,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result ?? this.result,
      activeTripBlocker: activeTripBlocker ?? this.activeTripBlocker,
      unpaidBalanceBlocker: unpaidBalanceBlocker ?? this.unpaidBalanceBlocker,
      feedbackMessage: feedbackMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        step,
        selectedReason,
        feedbackText,
        isAcknowledged,
        otpCode,
        resendCountdownSeconds,
        selectedSafeguard,
        isSubmitting,
        result,
        activeTripBlocker,
        unpaidBalanceBlocker,
        feedbackMessage,
        errorMessage,
      ];
}
