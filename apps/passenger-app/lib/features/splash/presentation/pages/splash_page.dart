import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import '../../data/models/splash_config.dart';
import '../../data/repositories/splash_repository.dart';
import '../widgets/bridge_silhouette.dart';
import '../widgets/connection_interrupted_card.dart';
import '../widgets/road_taxi_animation.dart';
import '../widgets/splash_header.dart';
import '../widgets/status_capsules.dart';

/// Entry widget that injects [SplashBloc] and provides the splash screen experience.
class SplashPage extends StatelessWidget {
  final SplashRepository? repository;

  const SplashPage({
    super.key,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc(
        repository: repository ?? SplashRepositoryImpl(),
      )..add(const SplashStarted()),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashSuccess) {
          // Navigate to destination route determined by auth session
          context.go(state.destinationRoute);
        }
      },
      builder: (context, state) {
        final isOffline = state is SplashConnectionInterrupted;
        final isSlow = state is SplashSlowConnection;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFF6B0E14),
            body: Stack(
              children: [
                // 1. Rich Crimson Background Gradient
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF99141D),
                        Color(0xFF7A0D15),
                        Color(0xFF52060C),
                        Color(0xFF350307),
                      ],
                      stops: [0.0, 0.35, 0.75, 1.0],
                    ),
                  ),
                ),

                // 2. Lethbridge Viaduct Bridge Silhouette at Screen Bottom
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BridgeSilhouette(height: 75),
                ),

                // 3. Main Screen Contents inside SafeArea
                SafeArea(
                  child: Column(
                    children: [
                      // Top Status Bar Indicator Bar
                      _buildTopStatusBar(isOffline: isOffline, isSlow: isSlow),

                      // Content based on state
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: isOffline
                              ? _buildInterruptedLayout(context, state)
                              : isSlow
                                  ? _buildSlowConnectionLayout(state)
                                  : _buildNormalLoadingLayout(
                                      state is SplashLoading ? state : null,
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Top status bar indicators corresponding to Screen 2 and Screen 3
  Widget _buildTopStatusBar({
    required bool isOffline,
    required bool isSlow,
  }) {
    if (isOffline) {
      return const OfflineTopBar();
    }
    if (isSlow) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Align(
          alignment: Alignment.topRight,
          child: LowSignalCapsule(),
        ),
      );
    }
    return const SizedBox(height: 24);
  }

  /// Screen 1 Layout: Initial Loading with Trust Badge and Smooth Spinner
  Widget _buildNormalLoadingLayout(SplashLoading? state) {
    return Column(
      key: const ValueKey('normal_loading_layout'),
      children: [
        const SizedBox(height: 20),
        const SplashHeader(),
        const SizedBox(height: 14),

        // "Southern Alberta's Trusted Choice" pill
        const TrustedChoiceBadge(),

        const Spacer(),

        // Animated Dotted Road with Driving Cab
        const RoadTaxiAnimation(height: 120),

        const Spacer(),

        // Circular Spinner
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.8,
          ),
        ),
        const SizedBox(height: 18),

        // Location text
        Text(
          '• ${state?.region ?? SplashConfig.cityRegion}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  /// Screen 2 Layout: Low Signal / Reconnecting with Amber Badge
  Widget _buildSlowConnectionLayout(SplashSlowConnection state) {
    return Column(
      key: const ValueKey('slow_connection_layout'),
      children: [
        const SizedBox(height: 20),
        const SplashHeader(),

        const Spacer(),

        // Animated Dotted Road with Driving Cab
        const RoadTaxiAnimation(height: 120),

        const Spacer(),

        // Circular Spinner
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.8,
          ),
        ),
        const SizedBox(height: 16),

        // "● Still connecting..." amber badge
        const StillConnectingBadge(),
        const SizedBox(height: 16),

        // Location text
        Text(
          state.region,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),

        // "Reconnecting to fleet dispatch" subtext
        Text(
          state.dispatchNotice,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  /// Screen 3 Layout: Connection Interrupted Modal Card Overlay
  Widget _buildInterruptedLayout(
    BuildContext context,
    SplashConnectionInterrupted state,
  ) {
    return Column(
      key: const ValueKey('interrupted_layout'),
      children: [
        const SizedBox(height: 12),
        const SplashHeader(),

        const Spacer(),

        // White floating modal card
        ConnectionInterruptedCard(
          title: state.title,
          message: state.message,
          onRetry: () {
            context.read<SplashBloc>().add(const SplashRetryRequested());
          },
          onCallHotline: () {
            context.read<SplashBloc>().add(const SplashHotlineCallRequested());
          },
        ),

        const Spacer(),

        // Location marker under the card
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.white70,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              SplashConfig.cityRegion,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
