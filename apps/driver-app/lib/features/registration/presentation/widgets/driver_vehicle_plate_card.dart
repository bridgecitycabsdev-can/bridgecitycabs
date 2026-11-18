import 'package:flutter/material.dart';

class DriverVehiclePlateCard extends StatelessWidget {
  final String plateNumber;
  final String? errorText;
  final bool isValid;
  final ValueChanged<String>? onChanged;

  const DriverVehiclePlateCard({
    super.key,
    required this.plateNumber,
    this.errorText,
    this.isValid = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayPlate =
        plateNumber.trim().isEmpty ? 'ABC-1234' : plateNumber.toUpperCase();
    final isPlaceholder = plateNumber.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Embossed Alberta Taxi Plate
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFFE2E4E8),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Plate Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ALBERTA',
                    style: TextStyle(
                      color: Color(0xFF90141E),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  // Wild rose floral icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '❀',
                        style: TextStyle(
                          color: Color(0xFFC62828),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'WILD ROSE COUNTRY',
                    style: TextStyle(
                      color: Color(0xFF90141E),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Embossed Plate Number
              Text(
                displayPlate,
                key: const ValueKey('driver_plate_display_text'),
                style: TextStyle(
                  color: isPlaceholder
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFFB71C1C),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 6),

              // Plate Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'COMMERCIAL TAXI',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'EXP 2026',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Subtext / Verification Status
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              if (errorText != null) ...[
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFD32F2F),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText!,
                    key: const ValueKey('driver_plate_error_text'),
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else if (isValid) ...[
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 15,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Registered with Lethbridge Vehicle Registry',
                    key: const ValueKey('driver_plate_verified_text'),
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF6B7280),
                  size: 15,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Enter exact registration plate as issued',
                    key: const ValueKey('driver_plate_hint_text'),
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
