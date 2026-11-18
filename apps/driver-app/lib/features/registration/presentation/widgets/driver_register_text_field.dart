import 'package:flutter/material.dart';

class DriverRegisterTextField extends StatelessWidget {
  final String? label;
  final String? tagText;
  final Color? tagColor;
  final IconData icon;
  final String value;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool isReadOnly;
  final String? errorText;
  final bool isValid;
  final Widget? customSuffix;
  final TextInputType keyboardType;

  const DriverRegisterTextField({
    super.key,
    this.label,
    this.tagText,
    this.tagColor,
    required this.icon,
    required this.value,
    required this.hintText,
    this.onChanged,
    this.isReadOnly = false,
    this.errorText,
    this.isValid = false,
    this.customSuffix,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and Tag Row
        if (label != null || tagText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (tagText != null)
                  Text(
                    tagText!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: tagColor ?? const Color(0xFF6B7280),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],

        // Input Field Container
        Container(
          width: double.infinity,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: hasError
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFE5E7EB),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 15,
                    color: const Color(0xFFC91A25),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // TextField or ReadOnly Text
              Expanded(
                child: isReadOnly
                    ? Text(
                        value.isEmpty ? hintText : value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: value.isEmpty
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF111827),
                        ),
                      )
                    : TextFormField(
                        initialValue: value,
                        key: ValueKey('$hintText-$value'),
                        onChanged: onChanged,
                        keyboardType: keyboardType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
              ),

              // Suffix: customSuffix OR checkmark OR error exclamation
              if (customSuffix != null)
                customSuffix!
              else if (hasError)
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 18,
                )
              else if (isValid)
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF059669),
                  size: 18,
                ),
            ],
          ),
        ),

        // Error message below input
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: [
                const Text(
                  '!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  errorText!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
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
