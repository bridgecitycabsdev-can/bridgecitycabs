import 'package:flutter/material.dart';
import '../../data/models/home_config.dart';
import '../../data/models/home_mode.dart';

/// Top bar that either renders floating action circles (Where to / Ready to ride)
/// or a standard elevated app bar with back navigation and help icon (Book / Plan ride).
class HomeTopBar extends StatelessWidget {
  final HomeMode mode;
  final VoidCallback onMenuTapped;
  final VoidCallback onNotificationsTapped;
  final VoidCallback onBackTapped;
  final VoidCallback? onHelpTapped;

  const HomeTopBar({
    super.key,
    required this.mode,
    required this.onMenuTapped,
    required this.onNotificationsTapped,
    required this.onBackTapped,
    this.onHelpTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == HomeMode.bookRide) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFB71C1C), size: 24),
              onPressed: onBackTapped,
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB71C1C),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  HomeConfig.bookRideTitle,
                  style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF1E1E1E), size: 24),
              onPressed: onHelpTapped ?? () {},
            ),
          ],
        ),
      );
    }

    if (mode == HomeMode.planRide) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E1E), size: 24),
              onPressed: onBackTapped,
            ),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  HomeConfig.planRideTitle,
                  style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  HomeConfig.planRideSub,
                  style: TextStyle(
                    color: Color(0xFF880E14),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF1E1E1E), size: 24),
              onPressed: onHelpTapped ?? () {},
            ),
          ],
        ),
      );
    }

    // Floating actions for WhereTo and ReadyToRide modes
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hamburger Menu Button
            Material(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onMenuTapped,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.menu_rounded, color: Color(0xFF1E1E1E), size: 24),
                ),
              ),
            ),

            // Notifications Bell Button with Badge
            Material(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onNotificationsTapped,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E1E1E), size: 24),
                      Positioned(
                        top: 12,
                        right: 13,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB71C1C),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
