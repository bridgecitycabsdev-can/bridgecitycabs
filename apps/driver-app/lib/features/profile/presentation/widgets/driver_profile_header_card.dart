import 'package:flutter/material.dart';
import '../../data/models/driver_profile_data.dart';
import '../../data/models/driver_profile_status.dart';

class DriverProfileHeaderCard extends StatelessWidget {
  final DriverProfileData profileData;
  final DriverProfileStatus status;

  const DriverProfileHeaderCard({
    super.key,
    required this.profileData,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = status == DriverProfileStatus.credentialExpiredLocked;
    final isOffline = status == DriverProfileStatus.offlineSyncAlert;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFEBEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLocked
                        ? const Color(0xFFC62828)
                        : isOffline
                            ? Colors.grey
                            : const Color(0xFF2E7D32),
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFE0E0E0),
                  child: Text(
                    profileData.fullName.isNotEmpty ? profileData.fullName[0] : 'D',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              // Status Badge on Avatar
              if (isLocked)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC62828),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, size: 12, color: Colors.white),
                )
              else
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isOffline
                        ? Colors.grey
                        : const Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Shift Stats Box
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLocked) ...[
                  Row(
                    children: [
                      Text(
                        profileData.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${profileData.assignedVehicle.unitNumber} • ${profileData.assignedVehicle.inspectionLabel}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TODAY'S SHIFT",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (profileData.isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                // 2x2 Stats Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Earning', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        Text(
                          '\$${profileData.todayEarnings.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: profileData.todayEarnings > 0
                                ? const Color(0xFFC62828)
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tip', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        Text(
                          '\$${profileData.todayTips.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rides', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        Text(
                          '${profileData.todayRides}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total km', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        Text(
                          '${profileData.todayKm.toInt()} km',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (isLocked) ...[
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.block, size: 12, color: Color(0xFFC62828)),
                      SizedBox(width: 4),
                      Text(
                        'Shift locked due to credentials',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
