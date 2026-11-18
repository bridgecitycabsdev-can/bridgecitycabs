import 'package:flutter/material.dart';
import '../bloc/location_permission_state.dart';
import '../../data/models/location_permission_config.dart';

/// Top bar with close button, title, profile avatar, and status bar.
class LocationPermissionHeader extends StatelessWidget {
  final LocationPermissionStatus status;
  final VoidCallback onClose;
  final VoidCallback onSkip;

  const LocationPermissionHeader({
    super.key,
    required this.status,
    required this.onClose,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isPrompt = status == LocationPermissionStatus.prompt;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Bar Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF1E1E1E), size: 24),
              onPressed: onClose,
            ),
            const Text(
              LocationPermissionConfig.screenTitle,
              style: TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF880E14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Sub-header Status Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isPrompt) ...[
                // Screen 2: Lethbridge Service Area pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.near_me_outlined,
                        color: Color(0xFFB71C1C),
                        size: 13,
                      ),
                      SizedBox(width: 5),
                      Text(
                        LocationPermissionConfig.serviceAreaBadge,
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onSkip,
                  child: const Text(
                    LocationPermissionConfig.skipForNow,
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                // Screen 1: Bridge City Fleet • Lethbridge & GPS Inactive
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Color(0xFFB71C1C), size: 6),
                      SizedBox(width: 6),
                      Text(
                        LocationPermissionConfig.fleetBadge,
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LocationPermissionConfig.gpsInactive,
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
