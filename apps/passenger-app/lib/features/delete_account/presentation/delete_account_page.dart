import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/delete_account_bloc.dart';
import 'bloc/delete_account_event.dart';
import 'bloc/delete_account_state.dart';
import '../data/models/delete_account_model.dart';
import '../data/repositories/delete_account_repository.dart';
import 'delete_account_warning_page.dart';
import 'delete_account_security_page.dart';
import 'delete_account_success_page.dart';
import 'delete_account_safeguards_page.dart';

class DeleteAccountPage extends StatelessWidget {
  final DeleteAccountStep initialStep;
  final DeleteAccountRepository? repository;
  final VoidCallback? onBack;

  const DeleteAccountPage({
    super.key,
    this.initialStep = DeleteAccountStep.warning,
    this.repository,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeleteAccountBloc(repository: repository)
        ..add(DeleteAccountStarted(initialStep: initialStep)),
      child: DeleteAccountCoordinatorView(onBack: onBack),
    );
  }
}

class DeleteAccountCoordinatorView extends StatelessWidget {
  final VoidCallback? onBack;

  const DeleteAccountCoordinatorView({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteAccountBloc, DeleteAccountState>(
      builder: (context, state) {
        switch (state.step) {
          case DeleteAccountStep.warning:
            return DeleteAccountWarningPage(
              onBack: onBack,
              onContinue: () {
                context.read<DeleteAccountBloc>().add(
                      const DeleteAccountStepChanged(DeleteAccountStep.verification),
                    );
              },
            );

          case DeleteAccountStep.verification:
            return DeleteAccountSecurityPage(
              onBack: () {
                context.read<DeleteAccountBloc>().add(
                      const DeleteAccountStepChanged(DeleteAccountStep.warning),
                    );
              },
              onSubmitted: () {
                context.read<DeleteAccountBloc>().add(
                      const DeleteAccountStepChanged(DeleteAccountStep.requestedResult),
                    );
              },
            );

          case DeleteAccountStep.requestedResult:
            return DeleteAccountSuccessPage(
              onDone: onBack,
            );

          case DeleteAccountStep.safeguardsMatrix:
            return DeleteAccountSafeguardsPage(
              onBack: onBack,
              onGoToTrip: onBack,
            );
        }
      },
    );
  }
}
