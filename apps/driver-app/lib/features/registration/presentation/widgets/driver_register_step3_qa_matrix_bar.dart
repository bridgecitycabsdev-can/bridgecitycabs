import 'package:flutter/material.dart';
import '../../data/models/driver_register_step3_status.dart';

class DriverRegisterStep3QaMatrixBar extends StatelessWidget {
  final DriverRegisterStep3Status currentStatus;
  final ValueChanged<DriverRegisterStep3Status> onStatusSelected;

  const DriverRegisterStep3QaMatrixBar({
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
                'QA STATE PREVIEW MATRIX (STEP 3 - DOCUMENTS)',
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
                  label: '1. Initial',
                  status: DriverRegisterStep3Status.initial,
                  keyString: 'qa_step3_state_initial',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '2. Uploading',
                  status: DriverRegisterStep3Status.uploading,
                  keyString: 'qa_step3_state_uploading',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '3. Modal',
                  status: DriverRegisterStep3Status.uploadModal,
                  keyString: 'qa_step3_state_modal',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '4. Action Req',
                  status: DriverRegisterStep3Status.actionRequired,
                  keyString: 'qa_step3_state_action_req',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '5. Ready',
                  status: DriverRegisterStep3Status.ready,
                  keyString: 'qa_step3_state_ready',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '6. Submitting',
                  status: DriverRegisterStep3Status.submitting,
                  keyString: 'qa_step3_state_submitting',
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
    required DriverRegisterStep3Status status,
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
