import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/driver_splash_bloc.dart';
import '../bloc/driver_splash_event.dart';
import '../bloc/driver_splash_state.dart';
import '../data/models/driver_splash_config.dart';
import '../data/models/driver_splash_model.dart';
import 'widgets/driver_brand_logo.dart';
import 'widgets/driver_connection_status_indicator.dart';
import 'widgets/driver_offline_modal.dart';
import 'widgets/driver_splash_background.dart';
import 'widgets/driver_splash_qa_matrix_bar.dart';
import 'widgets/driver_update_modal.dart';

class DriverSplashPage extends StatelessWidget {
  final DriverSplashStatus? initialStatus;
  final bool showQaToolbar;

  const DriverSplashPage({
    super.key,
    this.initialStatus,
    this.showQaToolbar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverSplashBloc()
        ..add(DriverSplashStarted(
          initialStatus: initialStatus ?? DriverSplashStatus.initial,
        )),
      child: DriverSplashView(showQaToolbar: showQaToolbar),
    );
  }
}

class DriverSplashView extends StatelessWidget {
  final bool showQaToolbar;

  const DriverSplashView({
    super.key,
    this.showQaToolbar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverSplashBloc, DriverSplashState>(
      listenWhen: (previous, current) =>
          previous.feedbackMessage != current.feedbackMessage &&
          current.feedbackMessage != null,
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1F2937),
            ),
          );
        }
      },
      builder: (context, state) {
        final isUpdateState = state.status == DriverSplashStatus.updateRequired;
        final isErrorState =
            state.status == DriverSplashStatus.connectionError;

        return Scaffold(
          body: DriverSplashBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Optional QA Toolbar for quick state switching
                  if (showQaToolbar)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: DriverSplashQaMatrixBar(
                        currentStatus: state.status,
                        onSelectStatus: (status) {
                          context
                              .read<DriverSplashBloc>()
                              .add(DriverSplashStatusChanged(status));
                        },
                      ),
                    ),

                  // Top Bar: Visible in State 4 (Fleet Dispatch pill + Version)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isUpdateState)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '●',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFFFBBF24), // Amber dot
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Fleet Dispatch',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (isUpdateState)
                          const Text(
                            DriverSplashConfig.currentVersionText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Center Logo with Steering Wheel and Bridge Center
                  DriverBrandLogo(showGlow: isUpdateState),

                  const Spacer(flex: 3),

                  // Dynamic Bottom Section
                  if (state.status == DriverSplashStatus.initial)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: DriverConnectionStatusIndicator(
                        isRetrying: false,
                      ),
                    )
                  else if (state.status == DriverSplashStatus.connecting)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: DriverConnectionStatusIndicator(
                        isRetrying: true,
                      ),
                    )
                  else if (isErrorState)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DriverOfflineModal(
                          onTryAgain: () {
                            context
                                .read<DriverSplashBloc>()
                                .add(const DriverSplashRetryTapped());
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          DriverSplashConfig.locationTextUpper,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  else if (isUpdateState)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DriverUpdateModal(
                          onUpdateNow: () {
                            context
                                .read<DriverSplashBloc>()
                                .add(const DriverSplashUpdateNowTapped());
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          DriverSplashConfig.locationTextUpper,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  else // Ready state fallback
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        DriverSplashConfig.locationText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
