import 'package:flutter/material.dart';

/// In-app numeric keypad matching the screenshots (1..9, 0, and backspace).
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final bool isEnabled;

  const NumericKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(['1', '2', '3'], ['', 'ABC', 'DEF']),
            const SizedBox(height: 10),
            _buildRow(['4', '5', '6'], ['GHI', 'JKL', 'MNO']),
            const SizedBox(height: 10),
            _buildRow(['7', '8', '9'], ['PQRS', 'TUV', 'WXYZ']),
            const SizedBox(height: 10),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> digits, List<String> letters) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _buildKey(digits[i], letters[i]),
          ),
        );
      }),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Left auxiliary key (Dialpad icon)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.dialpad_rounded,
                color: Color(0xFF4B5563),
                size: 20,
              ),
            ),
          ),
        ),

        // Center '0' key
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _buildKey('0', '+'),
          ),
        ),

        // Right Delete / Backspace key
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDeletePressed,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.backspace_outlined,
                      color: Color(0xFF1E1E1E),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKey(String digit, String subtext) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onDigitPressed(digit),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                digit,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              if (subtext.isNotEmpty)
                Text(
                  subtext,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
