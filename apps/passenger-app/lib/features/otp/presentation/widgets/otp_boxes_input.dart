import 'package:flutter/material.dart';
import '../bloc/otp_state.dart';
import '../../data/models/otp_config.dart';

/// The 6-digit OTP input row supporting all 5 visual states:
/// Initial typing, Auto-filled, Verifying/Locked, Error/Red, and Expired/Dimmed.
class OtpBoxesInput extends StatefulWidget {
  final String code;
  final OtpStatus status;

  const OtpBoxesInput({
    super.key,
    required this.code,
    required this.status,
  });

  @override
  State<OtpBoxesInput> createState() => _OtpBoxesInputState();
}

class _OtpBoxesInputState extends State<OtpBoxesInput>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.status == OtpStatus.error;
    final isVerifying = widget.status == OtpStatus.verifying;
    final isExpired = widget.status == OtpStatus.expired;
    final isAutofilled = widget.status == OtpStatus.autofilled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Row of 6 digit boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(OtpConfig.codeLength, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildDigitBox(
                    index: index,
                    isError: isError,
                    isVerifying: isVerifying,
                    isExpired: isExpired,
                  ),
                );
              }),
            ),

            // Screen 4: "🔒 LOCKED" badge attached to top-right
            if (isVerifying)
              Positioned(
                top: -12,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 10),
                      SizedBox(width: 4),
                      Text(
                        OtpConfig.lockedBadge,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        // Screen 2: "✓ Code auto-filled from SMS" badge
        if (isAutofilled) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFFB71C1C),
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  OtpConfig.autoFilledBadge,
                  style: TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDigitBox({
    required int index,
    required bool isError,
    required bool isVerifying,
    required bool isExpired,
  }) {
    final hasChar = index < widget.code.length;
    final isCurrent = index == widget.code.length;
    final char = hasChar ? widget.code[index] : '';

    final boxWidth = 46.0;
    final boxHeight = 56.0;

    // Styling rules per state
    Color bgColor = const Color(0xFFF3F4F6);
    Border? border;

    if (isError) {
      bgColor = Colors.white;
      border = Border.all(color: const Color(0xFFB71C1C), width: 1.8);
    } else if (isCurrent && !isVerifying && !isExpired) {
      bgColor = Colors.white;
      border = Border.all(color: const Color(0xFFE5E7EB), width: 1.5);
    }

    return Container(
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: border,
        boxShadow: (isCurrent || isError)
            ? [
                BoxShadow(
                  color: (isError ? const Color(0xFFB71C1C) : Colors.black)
                      .withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Content: Character, Blinking Cursor, or Subtle Dot
          if (hasChar)
            Text(
              char,
              style: TextStyle(
                color: isError
                    ? const Color(0xFFB71C1C)
                    : isExpired
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF111827),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            )
          else if (isCurrent && !isVerifying && !isExpired)
            FadeTransition(
              opacity: _cursorController,
              child: Container(
                width: 2,
                height: 22,
                color: const Color(0xFFB71C1C),
              ),
            )
          else
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFD1D5DB),
                shape: BoxShape.circle,
              ),
            ),

          // Red underline accent during verifying state (Screen 4)
          if (isVerifying && hasChar)
            Positioned(
              bottom: 8,
              child: Container(
                width: 14,
                height: 2.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFB71C1C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
