import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_home_bloc.dart';
import '../bloc/driver_home_event.dart';
import '../bloc/driver_home_state.dart';
import '../data/models/driver_home_status.dart';
import 'widgets/driver_home_account_pending_panel.dart';
import 'widgets/driver_home_away_panel.dart';
import 'widgets/driver_home_connection_lost_panel.dart';
import 'widgets/driver_home_incoming_offer_panel.dart';
import 'widgets/driver_home_location_panel.dart';
import 'widgets/driver_home_map_overlay.dart';
import 'widgets/driver_home_offline_panel.dart';
import 'widgets/driver_home_qa_matrix_bar.dart';
import 'widgets/driver_home_searching_panel.dart';

class DriverHomePage extends StatelessWidget {
  final DriverHomeStatus initialStatus;

  const DriverHomePage({
    super.key,
    this.initialStatus = DriverHomeStatus.offline,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverHomeBloc()
        ..add(DriverHomeStarted(initialStatus: initialStatus)),
      child: const _DriverHomeView(),
    );
  }
}

class _DriverHomeView extends StatelessWidget {
  const _DriverHomeView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverHomeBloc, DriverHomeState>(
      listenWhen: (prev, curr) =>
          prev.feedbackMessage != curr.feedbackMessage ||
          prev.status != curr.status,
      listener: (context, state) {
        if (state.feedbackMessage != null && state.feedbackMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              backgroundColor: state.isOffline || state.isLocationOff
                  ? const Color(0xFFC62828)
                  : const Color(0xFF15803D),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<DriverHomeBloc>();

        return Scaffold(
          body: Stack(
            children: [
              // 1. Simulated Map Background & Visual Pins
              Positioned.fill(
                child: DriverHomeMapOverlay(
                  status: state.status,
                  metrics: state.metrics,
                  surgeZone: state.surgeZone,
                  isDarkMode: state.isDarkMode,
                  onMenuPressed: () {
                    context.push('/menu');
                  },
                  onEarningsPressed: () {
                    bloc.add(const DriverHomeEarningsRefreshRequested());
                  },
                  onThemePressed: () {
                    bloc.add(const DriverHomeThemeToggled());
                  },
                  onLocationTargetPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Centering on current GPS position in Lethbridge'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),

              // 2. QA Matrix Testing Bar (Top Floater below status bar)
              Positioned(
                top: 80,
                left: 12,
                right: 12,
                child: DriverHomeQaMatrixBar(
                  currentStatus: state.status,
                  onStatusSelected: (status) {
                    bloc.add(DriverHomeStateSwitched(status));
                  },
                ),
              ),

              // 3. Bottom Slide-up Sheet Panel
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sheet Drag Handle
                          Center(
                            child: Container(
                              width: 38,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1D5DB),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Dynamic State Panel
                          _buildStatePanel(context, bloc, state),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatePanel(
    BuildContext context,
    DriverHomeBloc bloc,
    DriverHomeState state,
  ) {
    switch (state.status) {
      case DriverHomeStatus.offline:
        return DriverHomeOfflinePanel(
          metrics: state.metrics,
          onGoOnline: () => bloc.add(const DriverHomeGoOnlineRequested()),
        );

      case DriverHomeStatus.onlineSearching:
        return DriverHomeSearchingPanel(
          metrics: state.metrics,
          shiftMode: state.shiftMode,
          surgeZone: state.surgeZone,
          onSetAway: () => bloc.add(const DriverHomeSetAwayRequested()),
          onViewSurge: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Displaying 1.3x Surge Map in Lethbridge Zone...'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        );

      case DriverHomeStatus.locationOff:
        return DriverHomeLocationPanel(
          metrics: state.metrics,
          onEnableLocation: () =>
              bloc.add(const DriverHomeEnableLocationRequested()),
        );

      case DriverHomeStatus.shiftAway:
        return DriverHomeAwayPanel(
          metrics: state.metrics,
          onResumeActive: () =>
              bloc.add(const DriverHomeResumeActiveRequested()),
        );

      case DriverHomeStatus.networkOffline:
        return DriverHomeConnectionLostPanel(
          metrics: state.metrics,
          onRetryConnection: () =>
              bloc.add(const DriverHomeRetryConnectionRequested()),
        );

      case DriverHomeStatus.incomingOffer:
        return DriverHomeIncomingOfferPanel(
          metrics: state.metrics,
          incomingOffer: state.incomingOffer,
          onViewOffer: () {
            bloc.add(const DriverHomeViewIncomingOfferRequested());
            if (context.mounted) {
              context.push('/offer');
            }
          },
        );

      case DriverHomeStatus.accountPending:
        return DriverHomeAccountPendingPanel(
          verificationItems: state.verificationItems,
          onViewDocuments: () {
            bloc.add(const DriverHomeViewDocumentsRequested());
            if (context.mounted) {
              context.push('/register-step-3');
            }
          },
          onCheckApplicationStatus: () {
            bloc.add(const DriverHomeCheckApplicationStatusRequested());
            if (context.mounted) {
              context.push('/pending-approval');
            }
          },
          onContactSupport: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connecting to City Dispatch Support: 403-328-8888'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
    }
  }
}
