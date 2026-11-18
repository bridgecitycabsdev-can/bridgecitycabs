import 'package:flutter/material.dart';

/// Clean rounded form input field supporting leading icons, validation checkmarks,
/// institutional verification badges, and red error states.
class ProfileFormField extends StatelessWidget {
  final String label;
  final String initialValue;
  final String? placeholder;
  final IconData? prefixIcon;
  final String? statusTag;
  final Color? statusTagColor;
  final String? errorMessage;
  final bool isValid;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const ProfileFormField({
    super.key,
    required this.label,
    required this.initialValue,
    this.placeholder,
    this.prefixIcon,
    this.statusTag,
    this.statusTagColor,
    this.errorMessage,
    this.isValid = false,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label Header Row (Label on left, Status tag on right)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (statusTag != null)
                Text(
                  statusTag!,
                  style: TextStyle(
                    color: statusTagColor ??
                        (hasError ? const Color(0xFFB71C1C) : const Color(0xFF059669)),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),

        // Input Container
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: hasError ? const Color(0xFFFFF1F2) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFE53935)
                  : const Color(0xFFE5E7EB),
              width: hasError ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // Leading Icon
              if (prefixIcon != null) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: hasError ? const Color(0xFFFFEBEE) : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    prefixIcon,
                    color: hasError ? const Color(0xFFB71C1C) : const Color(0xFF4B5563),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Text Field
              Expanded(
                child: TextFormField(
                  initialValue: initialValue,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  onChanged: onChanged,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Trailing Status Indicator
              if (hasError) ...[
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFE53935),
                  size: 20,
                ),
              ] else if (isValid) ...[
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF059669),
                    size: 15,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Error message below field
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFB71C1C),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFB71C1C),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
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
