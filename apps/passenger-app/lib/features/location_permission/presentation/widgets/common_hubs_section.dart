import 'package:flutter/material.dart';
import '../../data/models/location_hub.dart';
import '../../data/models/location_permission_config.dart';

/// Unavailable permission message and common hubs picker for Screen 1.
class CommonHubsSection extends StatelessWidget {
  final ValueChanged<LocationHub> onHubSelected;

  const CommonHubsSection({
    super.key,
    required this.onHubSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Permission Unavailable Warning Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFB71C1C),
                size: 14,
              ),
              SizedBox(width: 5),
              Text(
                LocationPermissionConfig.permissionUnavailableBadge,
                style: TextStyle(
                  color: Color(0xFF880E14),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Headline
        const Text(
          LocationPermissionConfig.unavailableHeadline,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Description
        const Text(
          LocationPermissionConfig.unavailableDescription,
          style: TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),

        // Common Hubs Title
        const Text(
          LocationPermissionConfig.commonHubsHeader,
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        // Hub Pills Row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LocationHub.lethbridgeHubs.map((hub) {
            return GestureDetector(
              onTap: () => onHubSelected(hub),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(hub.icon, color: const Color(0xFFB71C1C), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      hub.name,
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
