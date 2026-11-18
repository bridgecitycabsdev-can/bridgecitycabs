import 'package:flutter/material.dart';
import '../../data/models/driver_register_step2_status.dart';

class DriverRegisterStep2QaMatrixBar extends StatelessWidget {
  final DriverRegisterStep2Status currentStatus;
  final ValueChanged<DriverRegisterStep2Status> onStatusSelected;

  const DriverRegisterStep2QaMatrixBar({
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
                'QA STATE PREVIEW MATRIX (STEP 2 - VEHICLE)',
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
                  status: DriverRegisterStep2Status.initial,
                  keyString: 'qa_step2_state_initial',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '2. Valid (Camry)',
                  status: DriverRegisterStep2Status.valid,
                  keyString: 'qa_step2_state_valid',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '3. Invalid (2008)',
                  status: DriverRegisterStep2Status.invalid,
                  keyString: 'qa_step2_state_invalid',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: '4. Year Picker',
                  status: DriverRegisterStep2Status.yearPickerModal,
                  keyString: 'qa_step2_state_year_picker',
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
    required DriverRegisterStep2Status status,
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
