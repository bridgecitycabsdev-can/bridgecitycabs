import 'package:flutter/material.dart';
import '../bloc/auth_state.dart';
import '../../data/models/auth_config.dart';

/// The phone number input pill supporting all 5 visual states:
/// Empty, Valid, Invalid, Submitting, and Rate Limited (Locked).
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final AuthStatus status;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.status,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isRateLimited = status == AuthStatus.rateLimited;
    final isInvalid = status == AuthStatus.invalid;
    final isValid = status == AuthStatus.valid;
    final isSubmitting = status == AuthStatus.submitting;

    final hasRedBorder = isValid || isInvalid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label Above
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            isInvalid ? 'Phone Number' : AuthConfig.phoneFieldLabel,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Input Container
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: hasRedBorder ? Colors.white : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: hasRedBorder
                  ? const Color(0xFFB71C1C)
                  : Colors.transparent,
              width: hasRedBorder ? 1.6 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // Left: Country Code & Flag
              _buildLeadingCountryWidget(status),
              const SizedBox(width: 8),

              // Vertical divider
              Container(
                height: 20,
                width: 1,
                color: const Color(0xFFE5E7EB),
                margin: const EdgeInsets.only(right: 8),
              ),

              // Phone Number Editable Input Field
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !isRateLimited && !isSubmitting,
                  keyboardType: TextInputType.phone,
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmitted(),
                  style: TextStyle(
                    color: isRateLimited
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  decoration: const InputDecoration(
                    hintText: AuthConfig.phonePlaceholder,
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Right Trailing Status Icon
              _buildTrailingIcon(status),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Subtext / Error / Status indicators below field
        _buildSubtextRow(status),
      ],
    );
  }

  Widget _buildLeadingCountryWidget(AuthStatus status) {
    if (status == AuthStatus.rateLimited) {
      // Screen 2: Red CA badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFB71C1C),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'CA +1',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pink circle with phone icon (Screens 1, 3, 5)
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFFFEBEE),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.phone_iphone_rounded,
              color: Color(0xFFB71C1C),
              size: 15,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Flag + Country code
        const Text(
          '🇨🇦 +1',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingIcon(AuthStatus status) {
    switch (status) {
      case AuthStatus.valid:
        // Screen 1: Grey circle with checkmark
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF4B5563),
            size: 15,
          ),
        );
      case AuthStatus.invalid:
        // Screen 5: Red warning exclamation circle
        return const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFB71C1C),
          size: 22,
        );
      case AuthStatus.submitting:
        // Screen 4: Red circular checkmark
        return const Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xFFB71C1C),
          size: 20,
        );
      case AuthStatus.rateLimited:
        // Screen 2: Lock icon
        return const Icon(
          Icons.lock_outline_rounded,
          color: Color(0xFF6B7280),
          size: 20,
        );
      case AuthStatus.empty:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSubtextRow(AuthStatus status) {
    if (status == AuthStatus.invalid) {
      // Screen 5: Red error prompt
      return const Padding(
        padding: EdgeInsets.only(left: 6),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB71C1C),
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              AuthConfig.phoneErrorPrompt,
              style: TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (status == AuthStatus.rateLimited) {
      // Screen 2: e.g. 587 329 5577 on left, "● Cooldown active" on right
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'e.g. ${AuthConfig.phoneExample}',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  color: Color(0xFFB71C1C),
                  size: 6,
                ),
                SizedBox(width: 4),
                Text(
                  AuthConfig.cooldownActiveTag,
                  style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (status == AuthStatus.valid) {
      // Screen 1: e.g. text + Ready for dispatch pill
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              'e.g. ${AuthConfig.phoneExample}',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  color: Color(0xFFB71C1C),
                  size: 6,
                ),
                SizedBox(width: 6),
                Text(
                  AuthConfig.readyForDispatch,
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
      );
    }

    // Screen 3: Location pin + Alberta hint
    return const Padding(
      padding: EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: Color(0xFF6B7280),
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            AuthConfig.phoneExampleWithRegion,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
