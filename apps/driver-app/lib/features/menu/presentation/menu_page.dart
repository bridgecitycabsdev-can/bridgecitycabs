import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_menu_bloc.dart';
import '../bloc/driver_menu_event.dart';
import '../bloc/driver_menu_state.dart';
import '../data/models/driver_menu_status.dart';
import '../data/repositories/driver_menu_repository.dart';
import 'widgets/driver_menu_drawer.dart';
import 'widgets/driver_menu_logout_dialog.dart';
import 'widgets/driver_menu_qa_bar.dart';

class DriverMenuPage extends StatelessWidget {
  final DriverMenuRepository? repository;
  final DriverMenuStatus initialStatus;

  const DriverMenuPage({
    super.key,
    this.repository,
    this.initialStatus = DriverMenuStatus.online,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverMenuBloc(
        repository: repository ?? FakeDriverMenuRepository(),
      )..add(DriverMenuStarted(initialStatus: initialStatus)),
      child: const _DriverMenuPageContent(),
    );
  }
}

class _DriverMenuPageContent extends StatelessWidget {
  const _DriverMenuPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverMenuBloc, DriverMenuState>(
      listenWhen: (previous, current) =>
          previous.shouldNavigateToLogin != current.shouldNavigateToLogin ||
          previous.feedbackMessage != current.feedbackMessage ||
          previous.selectedRouteTarget != current.selectedRouteTarget,
      listener: (context, state) {
        if (state.shouldNavigateToLogin) {
          if (context.mounted) {
            context.go('/phone');
          }
        } else if (state.selectedRouteTarget != null) {
          // If destination route is known, navigate
          if (state.selectedRouteTarget == '/earnings') {
            context.go('/earnings');
          } else if (state.selectedRouteTarget == '/profile') {
            context.go('/profile');
          } else if (state.selectedRouteTarget == '/history') {
            context.go('/history');
          } else if (state.selectedRouteTarget == '/reviews') {
            context.go('/reviews');
          } else if (state.selectedRouteTarget == '/settings') {
            context.go('/settings');
          }
        }

        if (state.feedbackMessage != null && state.feedbackMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: state.isUnderReview
                  ? const Color(0xFFE65100)
                  : const Color(0xFFC62828),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF424242),
          body: Stack(
            children: [
              // Simulated map / blurred background
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                ),
              ),

              // The Drawer anchored to the left or full view
              Align(
                alignment: Alignment.centerLeft,
                child: DriverMenuDrawer(
                  onClose: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ),

              // Logout Confirmation Modal
              if (state.isLogoutDialogVisible)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: DriverMenuLogoutDialog(
                      isLoading: state.isActionLoading,
                      onConfirmLogout: () {
                        context
                            .read<DriverMenuBloc>()
                            .add(const DriverMenuLogoutConfirmed());
                      },
                      onCancel: () {
                        context
                            .read<DriverMenuBloc>()
                            .add(const DriverMenuLogoutCancelled());
                      },
                    ),
                  ),
                ),

              // Floating QA Matrix Switcher Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: DriverMenuQaBar(activeStatus: state.status),
              ),
            ],
          ),
        );
      },
    );
  }
}
