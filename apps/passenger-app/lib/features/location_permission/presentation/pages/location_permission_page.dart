import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/location_permission_bloc.dart';
import '../bloc/location_permission_event.dart';
import '../bloc/location_permission_state.dart';
import '../../data/models/location_permission_config.dart';
import '../../data/repositories/location_permission_repository.dart';
import '../widgets/common_hubs_section.dart';
import '../widgets/location_map_preview.dart';
import '../widgets/location_permission_header.dart';
import '../widgets/location_value_props.dart';

/// Entry page for the passenger location permission flow.
///
/// Accurately implements both Screen 1 (Permission Unavailable / Denied / GPS Off)
/// and Screen 2 (Precision Permission Prompt with Value Propositions).
class LocationPermissionPage extends StatelessWidget {
  final LocationPermissionRepository? repository;
  final LocationPermissionBloc? bloc;

  const LocationPermissionPage({
    super.key,
    this.repository,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: const _LocationPermissionView(),
      );
    }

    return BlocProvider(
      create: (context) => LocationPermissionBloc(
        repository: repository ?? LocationPermissionRepositoryImpl(),
      )..add(const LocationPermissionCheckRequested()),
      child: const _LocationPermissionView(),
    );
  }
}

class _LocationPermissionView extends StatelessWidget {
  const _LocationPermissionView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationPermissionBloc, LocationPermissionState>(
      listener: (context, state) {
        if (state is LocationPermissionGrantedState ||
            state is LocationPermissionManualSearchState) {
          final target = state.targetRoute ?? '/home';
          context.go(target);
        }
      },
      builder: (context, state) {
        final isPrompt = state.isPrompt;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top App Bar + Service Status Bar
                    LocationPermissionHeader(
                      status: state.status,
                      onClose: () => context
                          .read<LocationPermissionBloc>()
                          .add(const LocationPermissionSkipTapped()),
                      onSkip: () => context
                          .read<LocationPermissionBloc>()
                          .add(const LocationPermissionSkipTapped()),
                    ),
                    const SizedBox(height: 14),

                    // Map Preview Card (Accuracy Radar or Dimmed / Disabled View)
                    LocationMapPreview(status: state.status),
                    const SizedBox(height: 20),

                    // Content Section: Prompt Value Props OR Unavailable Warning + Hubs
                    if (isPrompt)
                      const LocationValueProps()
                    else
                      CommonHubsSection(
                        onHubSelected: (hub) => context
                            .read<LocationPermissionBloc>()
                            .add(LocationPermissionHubSelected(hub)),
                      ),
                    const SizedBox(height: 24),

                    // Bottom Action Buttons
                    if (isPrompt) ...[
                      // Allow Location Button
                      ElevatedButton(
                        onPressed: () => context
                            .read<LocationPermissionBloc>()
                            .add(const LocationPermissionAllowTapped()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF880E14),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: math.pi / 4,
                              child: const Icon(
                                Icons.navigation_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              LocationPermissionConfig.allowLocationButton,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Enter Pickup Manually Text Button
                      Center(
                        child: TextButton(
                          onPressed: () => context
                              .read<LocationPermissionBloc>()
                              .add(const LocationPermissionManualPickupTapped()),
                          child: const Text(
                            LocationPermissionConfig.enterPickupManually,
                            style: TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Search Address Primary Button
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<LocationPermissionBloc>()
                            .add(const LocationPermissionSearchAddressTapped()),
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          LocationPermissionConfig.searchAddressButton,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Open Settings Secondary Button
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<LocationPermissionBloc>()
                            .add(const LocationPermissionOpenSettingsTapped()),
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                        label: const Text(
                          LocationPermissionConfig.openSettingsButton,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF262626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Settings Footnote Notice
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 13,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              LocationPermissionConfig.settingsNotice,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
