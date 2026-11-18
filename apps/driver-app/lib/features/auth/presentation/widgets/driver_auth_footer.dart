import 'package:flutter/material.dart';
import '../../data/models/driver_auth_config.dart';
import '../../data/models/driver_auth_status.dart';

class DriverAuthFooter extends StatelessWidget {
  final DriverAuthStatus status;
  final VoidCallback onBecomeDriver;

  const DriverAuthFooter({
    super.key,
    required this.status,
    required this.onBecomeDriver,
  });

  @override
  Widget build(BuildContext context) {
    String termsText;
    if (status == DriverAuthStatus.invalid) {
      termsText = DriverAuthConfig.termsNoticeBylaw;
    } else if (status == DriverAuthStatus.locked) {
      termsText = DriverAuthConfig.termsNoticeLicence;
    } else {
      termsText = DriverAuthConfig.termsNotice;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "New to Bridge City Cabs? Become a driver"
        GestureDetector(
          onTap: onBecomeDriver,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
              children: [
                const TextSpan(text: '${DriverAuthConfig.newDriverPrompt} '),
                TextSpan(
                  text: status == DriverAuthStatus.locked
                      ? '${DriverAuthConfig.becomeDriverLink} >'
                      : DriverAuthConfig.becomeDriverLink,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFC91A25),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Legal & Bylaw terms notice
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            termsText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
