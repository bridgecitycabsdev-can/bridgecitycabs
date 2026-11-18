import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/delete_account_bloc.dart';
import 'bloc/delete_account_event.dart';
import 'bloc/delete_account_state.dart';
import 'widgets/proto_mode_rig_bar.dart';
import 'widgets/deletion_requested_view.dart';

class DeleteAccountSuccessPage extends StatefulWidget {
  final VoidCallback? onDone;

  const DeleteAccountSuccessPage({
    super.key,
    this.onDone,
  });

  @override
  State<DeleteAccountSuccessPage> createState() => _DeleteAccountSuccessPageState();
}

class _DeleteAccountSuccessPageState extends State<DeleteAccountSuccessPage> {
  int _protoIndex = 1;

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
          body: SafeArea(
            child: Column(
              children: [
                // Proto Mode Bar
                ProtoModeRigBar(
                  selectedIndex: _protoIndex,
                  onIndexChanged: (idx) {
                    setState(() {
                      _protoIndex = idx;
                    });
                  },
                ),
                Expanded(
                  child: DeletionRequestedView(
                    result: state.result,
                    onDone: () {
                      context.read<DeleteAccountBloc>().add(const DeleteAccountDoneTapped());
                      widget.onDone?.call();
                    },
                    onSimulateReturnLogin: () {
                      context.read<DeleteAccountBloc>().add(const DeleteAccountSimulateReturnLoginTapped());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
