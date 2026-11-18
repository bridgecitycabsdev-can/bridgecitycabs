import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/side_menu_bloc.dart';
import 'bloc/side_menu_event.dart';
import 'bloc/side_menu_state.dart';
import '../data/models/side_menu_model.dart';
import '../data/repositories/side_menu_repository.dart';
import 'widgets/qa_state_preview_rig_bar.dart';
import 'widgets/live_trip_banner.dart';
import 'widgets/side_menu_profile_card.dart';
import 'widgets/side_menu_grid_view.dart';
import 'widgets/side_menu_list_view.dart';
import 'widgets/follow_us_community_card.dart';
import 'widgets/contact_support_and_logout_card.dart';

class SideMenuPage extends StatelessWidget {
  final VoidCallback? onDismiss;
  final ValueChanged<String>? onNavigate;

  const SideMenuPage({
    super.key,
    this.onDismiss,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SideMenuBloc(
        repository: SideMenuRepositoryImpl(),
      )..add(const SideMenuStarted()),
      child: SideMenuView(
        onDismiss: onDismiss,
        onNavigate: onNavigate,
      ),
    );
  }
}

class SideMenuView extends StatelessWidget {
  final VoidCallback? onDismiss;
  final ValueChanged<String>? onNavigate;

  const SideMenuView({
    super.key,
    this.onDismiss,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SideMenuBloc, SideMenuState>(
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
          body: Stack(
            children: [
              // Main content area
              SafeArea(
                child: Column(
                  children: [
                    // QA Rig Bar (for QA & interactive screen switching)
                    QaStatePreviewRigBar(
                      currentState: state.qaState,
                      onStateChanged: (qaState) {
                        context.read<SideMenuBloc>().add(SideMenuQaStateSelected(qaState));
                      },
                    ),

                    // Live Trip Active Banner
                    if (state.activeTrip != null)
                      LiveTripBanner(
                        tripData: state.activeTrip!,
                        onTap: () {
                          context.read<SideMenuBloc>().add(const SideMenuLiveTripTapped());
                          onNavigate?.call('live_tracking');
                        },
                      ),

                    // Scrollable Drawer content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drawer Header & Layout Switcher
                            _buildDrawerHeader(context, state),
                            const SizedBox(height: 16),

                            // Profile Card
                            SideMenuProfileCard(
                              profile: state.profile,
                              onTap: () {
                                context.read<SideMenuBloc>().add(const SideMenuNavigationTapped('profile'));
                                onNavigate?.call('profile');
                              },
                            ),
                            const SizedBox(height: 16),

                            // Dynamic Layout: Grid or List
                            if (state.layout == SideMenuLayout.grid) ...[
                              SideMenuGridView(
                                unreadNotificationsCount: state.unreadCount,
                                isTripActive: state.activeTrip != null,
                                onMenuTapped: (id) {
                                  context.read<SideMenuBloc>().add(SideMenuNavigationTapped(id));
                                  onNavigate?.call(id);
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildSettingsListTile(context),
                              const SizedBox(height: 16),
                              const FollowUsCommunityCard(),
                            ] else ...[
                              SideMenuListView(
                                activeTrip: state.activeTrip,
                                unreadNotificationsCount: state.unreadCount,
                                onMenuTapped: (id) {
                                  context.read<SideMenuBloc>().add(SideMenuNavigationTapped(id));
                                  onNavigate?.call(id);
                                },
                                onLiveTripTapped: () {
                                  context.read<SideMenuBloc>().add(const SideMenuLiveTripTapped());
                                  onNavigate?.call('live_tracking');
                                },
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Logout and Footer
                            ContactSupportAndLogoutCard(
                              isLogoutLocked: state.isLogoutLocked,
                              onContactSupport: () {
                                context.read<SideMenuBloc>().add(const SideMenuNavigationTapped('support'));
                                onNavigate?.call('support');
                              },
                              onLogout: () {
                                context.read<SideMenuBloc>().add(const SideMenuLogoutTapped());
                              },
                              versionText: state.layout == SideMenuLayout.grid
                                  ? 'Version 1.0.19 · Lethbridge, AB'
                                  : 'Bridge City Cabs v4.12.0 · Southern Alberta',
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Dismiss Button (as seen in Screen 1 on the map overlay)
              Positioned(
                right: 16,
                bottom: 80,
                child: InkWell(
                  onTap: () {
                    context.read<SideMenuBloc>().add(const SideMenuDismissTapped());
                    onDismiss?.call();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'DISMISS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
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

  Widget _buildDrawerHeader(BuildContext context, SideMenuState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF991B1B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_taxi,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bridge City Cabs',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Lethbridge Transit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Passenger',
                style: TextStyle(
                  color: Color(0xFF991B1B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Quick layout toggle button
            IconButton(
              tooltip: 'Toggle Grid / List Layout',
              icon: Icon(
                state.layout == SideMenuLayout.grid
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
              onPressed: () {
                context.read<SideMenuBloc>().add(const SideMenuLayoutToggled());
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsListTile(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<SideMenuBloc>().add(const SideMenuNavigationTapped('settings'));
        onNavigate?.call('settings');
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.settings_outlined,
              color: Color(0xFF374151),
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
