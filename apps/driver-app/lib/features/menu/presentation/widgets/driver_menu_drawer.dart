import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/driver_menu_bloc.dart';
import '../../bloc/driver_menu_event.dart';
import '../../bloc/driver_menu_state.dart';
import '../../data/models/driver_menu_config.dart';
import '../../data/models/driver_menu_status.dart';
import 'driver_menu_active_trip_banner.dart';
import 'driver_menu_grid.dart';
import 'driver_menu_header_card.dart';
import 'driver_menu_logout_button.dart';
import 'driver_menu_review_banner.dart';
import 'driver_menu_stats_strip.dart';
import 'driver_menu_support_card.dart';

class DriverMenuDrawer extends StatelessWidget {
  final VoidCallback? onClose;

  const DriverMenuDrawer({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverMenuBloc, DriverMenuState>(
      builder: (context, state) {
        final bloc = context.read<DriverMenuBloc>();

        return Drawer(
          width: MediaQuery.of(context).size.width * 0.85,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                // 1. Top Alerts for Active Trip or Under Review
                if (state.isActiveTrip) ...[
                  DriverMenuActiveTripBanner(tripInfo: state.activeTrip),
                  const SizedBox(height: 12),
                ] else if (state.isUnderReview) ...[
                  const DriverMenuReviewBanner(),
                  const SizedBox(height: 12),
                ],

                // 2. Driver Header Card
                DriverMenuHeaderCard(
                  profile: state.profile,
                  status: state.status,
                  onClose: onClose,
                  onProfileTap: () {
                    bloc.add(const DriverMenuItemSelected(DriverMenuItemId.profile));
                  },
                ),
                const SizedBox(height: 12),

                // 3. Daily Stats Strip
                DriverMenuStatsStrip(
                  stats: state.stats,
                  isOffline: state.isOffline,
                  isUppercase: state.isActiveTrip,
                ),
                const SizedBox(height: 14),

                // 4. 6-Card Menu Grid
                DriverMenuGrid(
                  items: state.menuItems,
                  onItemSelected: (itemId) {
                    bloc.add(DriverMenuItemSelected(itemId));
                  },
                ),
                const SizedBox(height: 12),

                // 5. Compliance lock notes if Under Review
                if (state.isUnderReview) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.black54),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Locked features will activate upon municipal compliance approval.',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const DriverMenuShiftLockedCard(),
                  const SizedBox(height: 12),
                ],

                // 6. Support Card
                DriverMenuSupportCard(
                  isActiveTrip: state.isActiveTrip,
                  hasArrow: state.isUnderReview,
                  onSupportTap: () {
                    bloc.add(const DriverMenuContactSupportPressed());
                  },
                  onCallHubTap: () {
                    bloc.add(const DriverMenuCallHubPressed());
                  },
                ),
                const SizedBox(height: 14),

                // 7. Version Label
                Center(
                  child: Text(
                    DriverMenuConfig.appVersion,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 8. Log out Button
                DriverMenuLogoutButton(
                  isLocked: state.isActiveTrip,
                  isOutlined: state.isUnderReview,
                  onLogoutPressed: () {
                    bloc.add(const DriverMenuLogoutPressed());
                  },
                ),
                const SizedBox(height: 14),

                // 9. Footer Text
                _buildFooter(state),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(DriverMenuState state) {
    if (state.isUnderReview) {
      return const Center(
        child: Text(
          'Bridge City Cabs • Lethbridge',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black45,
          ),
        ),
      );
    }

    if (state.isActiveTrip) {
      return const Center(
        child: Text(
          'Bridge City Taxi OS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black45,
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFFC62828)),
          const SizedBox(width: 5),
          Text(
            state.profile.fleetUnit,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFFB71C1C),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
