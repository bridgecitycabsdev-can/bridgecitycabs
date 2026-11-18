import 'package:flutter/material.dart';
import '../../data/models/driver_register_config.dart';
import '../../data/models/driver_register_step2_status.dart';
import '../../data/models/driver_vehicle_class.dart';

class DriverVehicleClassSelector extends StatelessWidget {
  final DriverVehicleClass? selectedClass;
  final DriverRegisterStep2Status status;
  final ValueChanged<DriverVehicleClass> onSelectClass;

  const DriverVehicleClassSelector({
    super.key,
    required this.selectedClass,
    required this.status,
    required this.onSelectClass,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = status == DriverRegisterStep2Status.valid;
    final isInvalid = status == DriverRegisterStep2Status.invalid;

    String headerLabel;
    String? rightTag;
    Color? rightTagColor;

    if (isValid) {
      headerLabel = DriverRegisterConfig.vehicleClassLabel;
      rightTag = DriverRegisterConfig.verifiedForFleet;
      rightTagColor = const Color(0xFF059669);
    } else if (isInvalid) {
      headerLabel = DriverRegisterConfig.vehicleCategoryLabel;
      rightTag = DriverRegisterConfig.selectSizeLabel;
      rightTagColor = const Color(0xFF6B7280);
    } else {
      headerLabel = DriverRegisterConfig.vehicleTypeLabel;
      rightTag = DriverRegisterConfig.requiredBadge;
      rightTagColor = const Color(0xFFDC2626);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              headerLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFF374151),
              ),
            ),
            if (rightTag != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isValid) ...[
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    rightTag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: rightTagColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),

        // 3 Cards: Compact / Medium / Big OR Medium / Big / Premium
        Row(
          children: [
            _buildClassCard(
              vehicleClass: isInvalid
                  ? DriverVehicleClass.compact
                  : DriverVehicleClass.medium,
              title: isInvalid ? 'Compact' : 'Medium',
              subtitle: isInvalid ? 'Up to 3 seats' : 'Sedan / CUV',
              icon: isInvalid
                  ? Icons.directions_car_outlined
                  : Icons.directions_car_rounded,
            ),
            const SizedBox(width: 8),
            _buildClassCard(
              vehicleClass: DriverVehicleClass.medium,
              title: 'Medium',
              subtitle: isInvalid ? '4 Passenger' : (isValid ? 'Sedan / CUV' : 'Sedan (4)'),
              icon: Icons.directions_car_rounded,
              isForceSelected: isInvalid || isValid,
            ),
            const SizedBox(width: 8),
            _buildClassCard(
              vehicleClass: isInvalid
                  ? DriverVehicleClass.big
                  : (isValid ? DriverVehicleClass.premium : DriverVehicleClass.big),
              title: isInvalid ? 'Large / Van' : (isValid ? 'Premium' : 'Big'),
              subtitle: isInvalid
                  ? '6+ Passenger'
                  : (isValid ? 'Executive' : 'SUV / Van (6)'),
              icon: isInvalid
                  ? Icons.airport_shuttle_rounded
                  : (isValid ? Icons.star_border_rounded : Icons.airport_shuttle_rounded),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Info description container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedClass != null
                      ? selectedClass!.infoDescription
                      : DriverRegisterConfig.selectClassificationDesc,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard({
    required DriverVehicleClass vehicleClass,
    required String title,
    required String subtitle,
    required IconData icon,
    bool isForceSelected = false,
  }) {
    final isSelected = isForceSelected || selectedClass == vehicleClass;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelectClass(vehicleClass),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF7F1D1D)
                          : const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Red Checkmark Dot for Selected card
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB91C1C),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 9,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
