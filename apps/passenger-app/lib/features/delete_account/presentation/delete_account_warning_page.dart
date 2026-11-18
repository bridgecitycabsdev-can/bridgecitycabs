import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/delete_account_bloc.dart';
import 'bloc/delete_account_event.dart';
import 'bloc/delete_account_state.dart';
import 'widgets/delete_account_app_bar.dart';
import 'widgets/deletion_warning_card.dart';

class DeleteAccountWarningPage extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const DeleteAccountWarningPage({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
      listener: (context, state) {
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
            title: 'Delete Account Warning',
            onBack: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            onProfileTapped: () {},
          ),
          body: DeletionWarningCard(
            onKeepAccount: () {
              context.read<DeleteAccountBloc>().add(const DeleteAccountKeepAccountTapped());
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            onContinueToDelete: () {
              context.read<DeleteAccountBloc>().add(const DeleteAccountContinueFromWarningTapped());
              onContinue?.call();
            },
            onPrivacyPolicyTapped: () {},
          ),
        );
      },
    );
  }
}
