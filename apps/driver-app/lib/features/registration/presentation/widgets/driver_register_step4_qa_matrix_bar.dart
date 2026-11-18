import 'package:flutter/material.dart';
import '../../data/models/driver_register_step4_status.dart';

class DriverRegisterStep4QaMatrixBar extends StatelessWidget {
  final DriverRegisterStep4Status currentStatus;
  final ValueChanged<DriverRegisterStep4Status> onStatusSelected;

  const DriverRegisterStep4QaMatrixBar({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune, color: Color(0xFF38BDF8), size: 14),
              SizedBox(width: 6),
              Text(
                'QA STATE PREVIEW MATRIX (STEP 4 - APPROVAL)',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
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
                _buildChip(
                  label: '1. Approved',
                  status: DriverRegisterStep4Status.approved,
                  keyString: 'qa_step4_state_approved',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '2. Reviewing',
                  status: DriverRegisterStep4Status.reviewing,
                  keyString: 'qa_step4_state_reviewing',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '3. Action Req',
                  status: DriverRegisterStep4Status.actionRequired,
                  keyString: 'qa_step4_state_action_req',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '4. Rejected (2008)',
                  status: DriverRegisterStep4Status.rejected,
                  keyString: 'qa_step4_state_rejected',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '5. Offline',
                  status: DriverRegisterStep4Status.offline,
                  keyString: 'qa_step4_state_offline',
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
    required DriverRegisterStep4Status status,
    required String keyString,
  }) {
    final isSelected = currentStatus == status;
    return InkWell(
      key: ValueKey(keyString),
      onTap: () => onStatusSelected(status),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
