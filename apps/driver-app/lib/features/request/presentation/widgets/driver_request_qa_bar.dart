import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/driver_request_bloc.dart';
import '../../bloc/driver_request_event.dart';
import '../../data/models/driver_request_status.dart';

class DriverRequestQABar extends StatelessWidget {
  final DriverRequestStatus activeStatus;

  const DriverRequestQABar({
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
                  'QA MATRIX: REQUEST STATES (${activeStatus.name})',
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
                    label: '1: Instant (10s)',
                    status: DriverRequestStatus.incomingInstant,
                  ),
                  const SizedBox(width: 6),
                  _chip(
                    context,
                    label: '2: Handshake Sync',
                    status: DriverRequestStatus.securingDispatch,
                  ),
                  const SizedBox(width: 6),
                  _chip(
                    context,
                    label: '3: Urgent (2s)',
                    status: DriverRequestStatus.expiringUrgent,
                  ),
                  const SizedBox(width: 6),
                  _chip(
                    context,
                    label: '4: Expired Modal',
                    status: DriverRequestStatus.expired,
                  ),
                  const SizedBox(width: 6),
                  _chip(
                    context,
                    label: '5: Taken by Unit 18',
                    status: DriverRequestStatus.takenByAnother,
                  ),
                  const SizedBox(width: 6),
                  _chip(
                    context,
                    label: '6: Scheduled Airport',
                    status: DriverRequestStatus.scheduled,
                  ),
                  const SizedBox(width: 6),
                  _chip(
                    context,
                    label: '7: Decline Alert',
                    status: DriverRequestStatus.declineConfirmation,
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
    required DriverRequestStatus status,
  }) {
    final isSelected = activeStatus == status;
    return GestureDetector(
      onTap: () {
        context.read<DriverRequestBloc>().add(DriverRequestStateForced(status));
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
