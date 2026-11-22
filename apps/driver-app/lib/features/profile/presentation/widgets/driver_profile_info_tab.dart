import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/driver_profile_data.dart';
import 'driver_profile_vehicle_card.dart';

class DriverProfileInfoTab extends StatelessWidget {
  final DriverProfileData profileData;
  final VoidCallback onContactSupport;

  const DriverProfileInfoTab({
    super.key,
    required this.profileData,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final hasRating = profileData.rating != null;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        // 1. Driver Rating Strip
        _buildRatingSection(context, hasRating),
        const SizedBox(height: 14),

        // 2. Driver Credentials Form
        _buildCredentialsSection(),
        const SizedBox(height: 14),

        // 3. Assigned Vehicle Section
        DriverProfileVehicleCard(
          vehicle: profileData.assignedVehicle,
          isFleetAssignmentStyle: !hasRating,
        ),
        const SizedBox(height: 14),

        // 4. Advisory Support Footer
        _buildAdvisoryFooter(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context, bool hasRating) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: hasRating
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${profileData.rating!.toStringAsFixed(1)} • ${profileData.reviewCount} reviews',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => context.go('/reviews'),
                  child: const Row(
                    children: [
                      Text(
                        'See reviews',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB71C1C),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Color(0xFFB71C1C),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DRIVER RATING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'New Partner',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star_border,
                        size: 16,
                        color: Colors.black26,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '0 rides completed. Complete your first trip in Lethbridge to unlock your passenger ratings score.',
                  style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.3),
                ),
              ],
            ),
    );
  }

  Widget _buildCredentialsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DRIVER CREDENTIALS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    size: 14,
                    color: profileData.isVerifiedFleet
                        ? const Color(0xFF2E7D32)
                        : Colors.black45,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profileData.isVerifiedFleet
                        ? 'Verified Fleet Driver'
                        : 'Verified',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: profileData.isVerifiedFleet
                          ? const Color(0xFF2E7D32)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildLockedField(
            icon: Icons.person_outline,
            label: 'FULL NAME',
            value: profileData.fullName,
          ),
          const SizedBox(height: 10),

          _buildLockedField(
            icon: Icons.alternate_email,
            label: 'DISPATCH EMAIL',
            value: profileData.email,
          ),
          const SizedBox(height: 10),

          _buildLockedField(
            icon: Icons.phone_outlined,
            label: 'PHONE NUMBER',
            value: profileData.phone,
          ),
          const SizedBox(height: 10),

          _buildLockedField(
            icon: Icons.badge_outlined,
            label: 'DRIVER LICENCE NUMBER',
            value: profileData.licenseNumber,
          ),
          const SizedBox(height: 10),

          _buildLockedField(
            icon: Icons.wc,
            label: 'GENDER',
            value: profileData.gender,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: const Color(0xFFC62828)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 14, color: Colors.black38),
        ],
      ),
    );
  }

  Widget _buildAdvisoryFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEBEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFC62828)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'To change any detail or vehicle assignment, please contact Bridge City Cabs dispatch.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onContactSupport,
                  child: const Text(
                    'Contact support ➔',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
