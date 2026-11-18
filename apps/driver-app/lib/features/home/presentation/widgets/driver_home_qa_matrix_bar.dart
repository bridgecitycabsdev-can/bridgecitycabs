import 'package:flutter/material.dart';
import '../../data/models/driver_home_status.dart';

class DriverHomeQaMatrixBar extends StatelessWidget {
  final DriverHomeStatus currentStatus;
  final ValueChanged<DriverHomeStatus> onStatusSelected;

  const DriverHomeQaMatrixBar({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune, color: Color(0xFF38BDF8), size: 13),
              SizedBox(width: 6),
              Text(
                'QA STATE PREVIEW MATRIX (DRIVER HOME)',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip(
                  label: '1. Offline',
                  status: DriverHomeStatus.offline,
                  keyString: 'qa_home_state_offline',
                ),
                const SizedBox(width: 5),
                _buildChip(
                  label: '2. Searching',
                  status: DriverHomeStatus.onlineSearching,
                  keyString: 'qa_home_state_searching',
                ),
                const SizedBox(width: 5),
                _buildChip(
                  label: '3. GPS Off',
                  status: DriverHomeStatus.locationOff,
                  keyString: 'qa_home_state_gps_off',
                ),
                const SizedBox(width: 5),
                _buildChip(
                  label: '4. Away',
                  status: DriverHomeStatus.shiftAway,
                  keyString: 'qa_home_state_away',
                ),
                const SizedBox(width: 5),
                _buildChip(
                  label: '5. Net Lost',
                  status: DriverHomeStatus.networkOffline,
                  keyString: 'qa_home_state_net_lost',
                ),
                const SizedBox(width: 5),
                _buildChip(
                  label: '6. Offer (13s)',
                  status: DriverHomeStatus.incomingOffer,
                  keyString: 'qa_home_state_offer',
                ),
                const SizedBox(width: 5),
                _buildChip(
                  label: '7. Pending (Lock)',
                  status: DriverHomeStatus.accountPending,
                  keyString: 'qa_home_state_pending',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required DriverHomeStatus status,
    required String keyString,
  }) {
    final isSelected = currentStatus == status;
    return InkWell(
      key: ValueKey(keyString),
      onTap: () => onStatusSelected(status),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC62828) : const Color(0xFF334155),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8A80)
                : const Color(0xFF475569),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
