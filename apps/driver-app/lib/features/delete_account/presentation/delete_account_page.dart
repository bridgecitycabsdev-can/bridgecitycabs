import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/driver_delete_account_bloc.dart';
import '../bloc/driver_delete_account_event.dart';
import '../bloc/driver_delete_account_state.dart';
import '../data/models/driver_delete_status.dart';
import '../data/repositories/driver_delete_account_repository.dart';
import 'widgets/driver_delete_checklist_view.dart';
import 'widgets/driver_delete_emergency_modal.dart';
import 'widgets/driver_delete_qa_bar.dart';
import 'widgets/driver_delete_recovery_banner_view.dart';
import 'widgets/driver_delete_requested_view.dart';
import 'widgets/driver_delete_safeguards_view.dart';

class DriverDeleteAccountPage extends StatelessWidget {
  final DriverDeleteAccountRepository? repository;
  final DriverDeleteStatus? initialStatus;

  const DriverDeleteAccountPage({
    super.key,
    this.repository,
    this.initialStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverDeleteAccountBloc(
        repository: repository ?? FakeDriverDeleteAccountRepository(),
        initialStatus: initialStatus ?? DriverDeleteStatus.checklistReady,
      )..add(const DriverDeleteStarted()),
      child: const _DriverDeleteAccountView(),
    );
  }
}

class _DriverDeleteAccountView extends StatelessWidget {
  const _DriverDeleteAccountView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverDeleteAccountBloc, DriverDeleteAccountState>(
      listener: (context, state) {
        if (state.navigateToTrip) {
          context.go('/trip');
        } else if (state.isSignedOut) {
          context.go('/phone');
        }

        if (state.toastMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.toastMessage!),
              duration: const Duration(seconds: 3),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<DriverDeleteAccountBloc>().add(const DriverDeleteClearToast());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/settings');
                }
              },
            ),
            title: const Text(
              'Delete Account',
              style: TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFF8B181B),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              DriverDeleteQaBar(currentStatus: state.status),
              Expanded(
                child: _buildBody(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(DriverDeleteAccountState state) {
    switch (state.status) {
      case DriverDeleteStatus.checklistReady:
        return DriverDeleteChecklistView(state: state);
      case DriverDeleteStatus.safeguardsBlocked:
        return DriverDeleteSafeguardsView(state: state);
      case DriverDeleteStatus.deletionRequested:
        return DriverDeleteRequestedView(state: state);
      case DriverDeleteStatus.recoveryBanner:
        return DriverDeleteRecoveryBannerView(state: state);
      case DriverDeleteStatus.emergencyModal:
        return Stack(
          children: [
            Container(color: Colors.black45),
            Align(
              alignment: Alignment.bottomCenter,
              child: DriverDeleteEmergencyModal(state: state),
            ),
          ],
        );
    }
  }
}
