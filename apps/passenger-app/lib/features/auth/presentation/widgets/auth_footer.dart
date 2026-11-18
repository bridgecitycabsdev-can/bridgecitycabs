import 'package:flutter/material.dart';
import '../../data/models/auth_config.dart';

/// Terms, Privacy Policy links, and Alberta service region footer.
class AuthFooter extends StatelessWidget {
  final bool isServingDetailed;

  const AuthFooter({
    super.key,
    this.isServingDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Terms & Privacy
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'By continuing you agree to our '),
                TextSpan(
                  text: AuthConfig.termsText,
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' and acknowledge our '),
                TextSpan(
                  text: AuthConfig.privacyText,
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Service Region Tagline
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isServingDetailed
                  ? Icons.local_shipping_outlined
                  : Icons.shield_outlined,
              color: const Color(0xFF9CA3AF),
              size: 13,
            ),
            const SizedBox(width: 6),
            Text(
              isServingDetailed
                  ? AuthConfig.footerRegionsServing
                  : AuthConfig.footerRegionsClassic,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
