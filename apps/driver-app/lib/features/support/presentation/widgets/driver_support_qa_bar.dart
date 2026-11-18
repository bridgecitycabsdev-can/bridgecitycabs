import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_support_bloc.dart';
import '../../bloc/driver_support_event.dart';
import '../../data/models/driver_support_status.dart';

class DriverSupportQaBar extends StatelessWidget {
  final DriverSupportViewStatus currentStatus;

  const DriverSupportQaBar({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1EFEF),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: DriverSupportViewStatus.values.map((status) {
            final isSelected = currentStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF333333),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF8B181B),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF8B181B) : const Color(0xFFD6D1D1),
                  ),
                ),
                showCheckmark: false,
                onSelected: (_) {
                  context.read<DriverSupportBloc>().add(
                        DriverSupportSwitchView(status),
                      );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
