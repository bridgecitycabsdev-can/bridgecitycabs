import 'package:flutter/material.dart';
import '../../data/models/driver_shift_mode.dart';

class DriverHomeShiftToggle extends StatelessWidget {
  final DriverShiftMode shiftMode;
  final bool isLocked;
  final String? lockedCustomText;
  final VoidCallback? onActiveTap;
  final VoidCallback? onAwayTap;

  const DriverHomeShiftToggle({
    super.key,
    required this.shiftMode,
    this.isLocked = false,
    this.lockedCustomText,
    this.onActiveTap,
    this.onAwayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lockedCustomText != null) {
      // Locked pill across full width (e.g. State 7)
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline, size: 14, color: Color(0xFF9CA3AF)),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, size: 13, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    lockedCustomText!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Away',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isLocked) {
      // Locked segmented buttons (State 3 & 5)
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline, size: 14, color: Color(0xFF9CA3AF)),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline, size: 14, color: Color(0xFF9CA3AF)),
                    SizedBox(width: 4),
                    Text(
                      'Away',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isActive = shiftMode == DriverShiftMode.active;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Active Segment Button
          Expanded(
            child: InkWell(
              onTap: onActiveTap,
              borderRadius: BorderRadius.circular(9),
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF15803D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive
                            ? Icons.radio_button_checked
                            : Icons.circle_outlined,
                        size: 14,
                        color: isActive ? Colors.white : const Color(0xFF4B5563),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              isActive ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Away Segment Button
          Expanded(
            child: InkWell(
              onTap: onAwayTap,
              borderRadius: BorderRadius.circular(9),
              child: Container(
                decoration: BoxDecoration(
                  color: !isActive ? const Color(0xFF1F2937) : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pause_circle_outline,
                        size: 15,
                        color:
                            !isActive ? const Color(0xFFFBBF24) : const Color(0xFF4B5563),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Away',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              !isActive ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
