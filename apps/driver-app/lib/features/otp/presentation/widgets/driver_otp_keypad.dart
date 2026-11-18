import 'package:flutter/material.dart';

class DriverOtpKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool showClearKey;

  const DriverOtpKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
    required this.onClear,
    this.showClearKey = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: [
              _buildKey('1', ''),
              const SizedBox(width: 8),
              _buildKey('2', 'ABC'),
              const SizedBox(width: 8),
              _buildKey('3', 'DEF'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKey('4', 'GHI'),
              const SizedBox(width: 8),
              _buildKey('5', 'JKL'),
              const SizedBox(width: 8),
              _buildKey('6', 'MNO'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKey('7', 'PQRS'),
              const SizedBox(width: 8),
              _buildKey('8', 'TUV'),
              const SizedBox(width: 8),
              _buildKey('9', 'WXYZ'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Bottom left: Clear "C" or blank
              Expanded(
                child: showClearKey
                    ? _buildActionKey(
                        label: 'C',
                        onTap: onClear,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),
              _buildKey('0', '+'),
              const SizedBox(width: 8),
              // Bottom right: Backspace icon
              Expanded(
                child: _buildActionKey(
                  icon: Icons.backspace_outlined,
                  onTap: onBackspace,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String digit, String subtext) {
    return Expanded(
      child: Material(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onDigitPressed(digit),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                if (subtext.isNotEmpty)
                  Text(
                    subtext,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.8,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: icon != null
              ? Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF374151),
                )
              : Text(
                  label ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4B5563),
                  ),
                ),
        ),
      ),
    );
  }
}
