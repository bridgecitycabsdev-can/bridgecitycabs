import 'package:flutter/material.dart';
import '../../data/models/driver_auth_config.dart';
import '../../data/models/driver_auth_status.dart';

class DriverPhoneInputField extends StatelessWidget {
  final DriverAuthStatus status;
  final String formattedPhone;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onClear;
  final VoidCallback? onNotYourNumber;

  const DriverPhoneInputField({
    super.key,
    required this.status,
    required this.formattedPhone,
    required this.onPhoneChanged,
    required this.onClear,
    this.onNotYourNumber,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;

    if (status == DriverAuthStatus.valid) {
      borderColor = const Color(0xFFC91A25); // Highlight red border
      backgroundColor = Colors.white;
    } else if (status == DriverAuthStatus.invalid) {
      borderColor = const Color(0xFFFCA5A5);
      backgroundColor = const Color(0xFFFEF2F2);
    } else {
      borderColor = Colors.transparent;
      backgroundColor = const Color(0xFFF3F4F6);
    }

    final isLocked = status == DriverAuthStatus.locked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Header Row (for Invalid and Locked states)
        if (status == DriverAuthStatus.invalid) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  DriverAuthConfig.mobileNumberLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF374151),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 13,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 4),
                    Text(
                      DriverAuthConfig.incompleteNumberWarning,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else if (status == DriverAuthStatus.unregistered) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              DriverAuthConfig.mobileNumberLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ] else if (status == DriverAuthStatus.locked) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              DriverAuthConfig.registeredMobileNumberLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],

        // Input Container
        Container(
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: borderColor,
              width: 1.8,
            ),
            boxShadow: status == DriverAuthStatus.valid
                ? [
                    BoxShadow(
                      color: const Color(0xFFC91A25).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Phone Icon in Circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: status == DriverAuthStatus.invalid
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.phone_rounded,
                    size: 16,
                    color: status == DriverAuthStatus.invalid
                        ? Colors.white
                        : const Color(0xFFC91A25),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Canadian Flag & +1
              const Text(
                '🇨🇦',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
              const Text(
                DriverAuthConfig.countryCallingCode,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 8),

              // Vertical Divider
              Container(
                width: 1,
                height: 22,
                color: const Color(0xFFD1D5DB),
              ),
              const SizedBox(width: 10),

              // Input TextField
              Expanded(
                child: isLocked
                    ? Text(
                        formattedPhone.isEmpty
                            ? DriverAuthConfig.phonePlaceholder
                            : formattedPhone,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.3,
                        ),
                      )
                    : TextFormField(
                        initialValue: formattedPhone,
                        key: ValueKey(formattedPhone),
                        keyboardType: TextInputType.phone,
                        onChanged: onPhoneChanged,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: 0.3,
                        ),
                        decoration: InputDecoration(
                          hintText: DriverAuthConfig.phonePlaceholder,
                          hintStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
              ),

              // Suffix Actions
              if (status == DriverAuthStatus.valid) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ] else if (status == DriverAuthStatus.invalid ||
                  status == DriverAuthStatus.unregistered) ...[
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
              ] else if (isLocked) ...[
                const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Subtext / Error Banner below input
        if (status == DriverAuthStatus.invalid) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 15,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DriverAuthConfig.invalidPhoneMessage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (status == DriverAuthStatus.locked) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 13,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 5),
                    Text(
                      DriverAuthConfig.attemptsExceededText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onNotYourNumber,
                  child: const Text(
                    DriverAuthConfig.notYourNumberLink,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC91A25),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  status == DriverAuthStatus.valid
                      ? Icons.shield_outlined
                      : Icons.info_outline_rounded,
                  size: 13,
                  color: status == DriverAuthStatus.valid
                      ? const Color(0xFF059669)
                      : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    DriverAuthConfig.defaultSubtext,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
