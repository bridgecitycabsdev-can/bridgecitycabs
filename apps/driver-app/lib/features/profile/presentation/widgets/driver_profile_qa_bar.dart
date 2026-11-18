import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/driver_profile_bloc.dart';
import '../../bloc/driver_profile_event.dart';
import '../../data/models/driver_profile_status.dart';

class DriverProfileQaBar extends StatelessWidget {
  final DriverProfileStatus activeStatus;

  const DriverProfileQaBar({
    super.key,
    required this.activeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, size: 14, color: Colors.orangeAccent),
                const SizedBox(width: 6),
                Text(
                  'QA MATRIX: DRIVER PROFILE (${activeStatus.name})',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip(
                    context,
                    label: '1: Active Info',
                    status: DriverProfileStatus.activeOnline,
                  ),
                  const SizedBox(width: 6),
                  _chip(
                    context,
                    label: '2: Expired Locked',
                    status: DriverProfileStatus.credentialExpiredLocked,
                  ),
                  const SizedBox(width: 6),
                  _chip(
                    context,
                    label: '3: Expiring Inspection',
                    status: DriverProfileStatus.expiringSoonInspection,
                  ),
                  const SizedBox(width: 6),
                  _chip(
                    context,
                    label: '4: Offline Sync Alert',
                    status: DriverProfileStatus.offlineSyncAlert,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required DriverProfileStatus status,
  }) {
    final isSelected = activeStatus == status;
    return GestureDetector(
      onTap: () {
        context.read<DriverProfileBloc>().add(DriverProfileStateForced(status));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC62828) : Colors.white12,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
