import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/call_driver_bloc.dart';
import 'bloc/call_driver_event.dart';
import 'bloc/call_driver_state.dart';
import '../data/models/call_driver_model.dart';
import 'call_driver_prompt_page.dart';
import 'call_driver_active_page.dart';
import 'call_driver_outcome_page.dart';

class CallDriverPage extends StatelessWidget {
  final CallPhase initialPhase;
  final VoidCallback? onBack;

  const CallDriverPage({
    super.key,
    this.initialPhase = CallPhase.preCallPrompt,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CallDriverBloc()
        ..add(CallDriverStarted(initialPhase: initialPhase)),
      child: CallDriverCoordinatorView(onBack: onBack),
    );
  }
}

class CallDriverCoordinatorView extends StatelessWidget {
  final VoidCallback? onBack;

  const CallDriverCoordinatorView({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallDriverBloc, CallDriverState>(
      builder: (context, state) {
        switch (state.phase) {
          case CallPhase.preCallPrompt:
            return CallDriverPromptPage(
              onCallInitiated: () {
                context.read<CallDriverBloc>().add(const CallDriverInitiateTapped());
              },
              onCancel: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            );

          case CallPhase.connecting:
          case CallPhase.ringing:
          case CallPhase.connected:
          case CallPhase.ended:
            return CallDriverActivePage(
              onCallEnded: () {
                context.read<CallDriverBloc>().add(
                      const CallDriverOutcomeScenarioChanged(CallOutcomeScenario.didntAnswer),
                    );
              },
            );

          case CallPhase.outcomeFallback:
            return CallDriverOutcomePage(
              onBack: () {
                context.read<CallDriverBloc>().add(
                      const CallDriverPhaseChanged(CallPhase.preCallPrompt),
                    );
              },
              onTryAgain: () {
                context.read<CallDriverBloc>().add(const CallDriverRetryTapped());
              },
              onClose: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            );
        }
      },
    );
  }
}
