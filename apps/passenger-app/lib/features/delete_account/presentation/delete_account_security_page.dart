import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/delete_account_bloc.dart';
import 'bloc/delete_account_event.dart';
import 'bloc/delete_account_state.dart';
import 'widgets/delete_account_app_bar.dart';
import 'widgets/security_verification_card.dart';

class DeleteAccountSecurityPage extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSubmitted;

  const DeleteAccountSecurityPage({
    super.key,
    this.onBack,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF1F2937),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: DeleteAccountAppBar(
            title: 'Security Verification',
            onBack: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            onProfileTapped: () {},
          ),
          body: SecurityVerificationCard(
            selectedReason: state.selectedReason,
            feedbackText: state.feedbackText,
            isAcknowledged: state.isAcknowledged,
            otpCode: state.otpCode,
            formattedCountdown: state.formattedCountdown,
            onReasonSelected: (reason) {
              context.read<DeleteAccountBloc>().add(DeleteAccountReasonSelected(reason));
            },
            onFeedbackChanged: (text) {
              context.read<DeleteAccountBloc>().add(DeleteAccountFeedbackChanged(text));
            },
            onAcknowledgmentToggled: (val) {
              context.read<DeleteAccountBloc>().add(DeleteAccountAcknowledgmentToggled(val));
            },
            onOtpChanged: (otp) {
              context.read<DeleteAccountBloc>().add(DeleteAccountOtpDigitChanged(otp));
            },
            onResendOtp: () {
              context.read<DeleteAccountBloc>().add(const DeleteAccountResendOtpTapped());
            },
            onDeleteAccount: () {
              context.read<DeleteAccountBloc>().add(const DeleteAccountSubmitDeletionTapped());
              onSubmitted?.call();
            },
            onCancelAndKeep: () {
              context.read<DeleteAccountBloc>().add(const DeleteAccountKeepAccountTapped());
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
        );
      },
    );
  }
}
