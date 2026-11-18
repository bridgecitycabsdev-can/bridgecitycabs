import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/delete_account_bloc.dart';
import 'bloc/delete_account_event.dart';
import 'bloc/delete_account_state.dart';
import 'widgets/delete_account_app_bar.dart';
import 'widgets/account_safeguards_matrix_view.dart';

class DeleteAccountSafeguardsPage extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onGoToTrip;

  const DeleteAccountSafeguardsPage({
    super.key,
    this.onBack,
    this.onGoToTrip,
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
            title: 'Feedback & Reason',
            onBack: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            onProfileTapped: () {},
          ),
          body: AccountSafeguardsMatrixView(
            selectedSafeguard: state.selectedSafeguard,
            activeTrip: state.activeTripBlocker,
            unpaidBalance: state.unpaidBalanceBlocker,
            onSafeguardSelected: (safeguard) {
              context.read<DeleteAccountBloc>().add(DeleteAccountSafeguardSelected(safeguard));
            },
            onGoToTrip: () {
              onGoToTrip?.call();
            },
            onViewReceiptAndPay: () {},
            onContactSupport: () {},
          ),
        );
      },
    );
  }
}
