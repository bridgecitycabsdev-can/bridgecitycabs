import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/call_driver_bloc.dart';
import 'bloc/call_driver_event.dart';
import 'bloc/call_driver_state.dart';
import '../data/models/call_driver_model.dart';
import 'widgets/active_call_dialing_view.dart';

class CallDriverActivePage extends StatelessWidget {
  final VoidCallback? onCallEnded;

  const CallDriverActivePage({
    super.key,
    this.onCallEnded,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallDriverBloc, CallDriverState>(
      listener: (context, state) {
        if (state.phase == CallPhase.ended) {
          onCallEnded?.call();
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
          backgroundColor: Colors.white,
          body: ActiveCallDialingView(
            driver: state.driverDetails,
            phase: state.phase,
            statusTitle: state.statusTitle,
            statusSubtitle: state.statusSubtitle,
            isMuted: state.isMuted,
            isKeypadOpen: state.isKeypadOpen,
            isSpeakerOn: state.isSpeakerOn,
            onPhaseChanged: (phase) {
              context.read<CallDriverBloc>().add(CallDriverPhaseChanged(phase));
            },
            onToggleMute: () {
              context.read<CallDriverBloc>().add(const CallDriverToggleMute());
            },
            onToggleKeypad: () {
              context.read<CallDriverBloc>().add(const CallDriverToggleKeypad());
            },
            onToggleSpeaker: () {
              context.read<CallDriverBloc>().add(const CallDriverToggleSpeaker());
            },
            onCancelCall: () {
              context.read<CallDriverBloc>().add(const CallDriverCancelCallTapped());
              onCallEnded?.call();
            },
          ),
        );
      },
    );
  }
}
