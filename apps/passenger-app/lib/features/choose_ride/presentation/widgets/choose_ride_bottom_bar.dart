import 'package:flutter/material.dart';

class ChooseRideBottomBar extends StatelessWidget {
  final String buttonLabel;
  final String? securityNote;
  final bool hasCheckmark;
  final bool hasArrow;
  final bool hasCarIcon;
  final VoidCallback onContinue;

  const ChooseRideBottomBar({
    super.key,
    required this.buttonLabel,
    this.securityNote = 'Server verified rate · Valid for this ride',
    this.hasCheckmark = false,
    this.hasArrow = true,
    this.hasCarIcon = true,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (securityNote != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 13,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    securityNote!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Main Red Button
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF991B1B),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasCheckmark) ...[
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                  ] else if (hasCarIcon) ...[
                    const Icon(Icons.directions_car, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (hasArrow) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
