import 'package:flutter/material.dart';

class RatingCommentBox extends StatelessWidget {
  final String comment;
  final ValueChanged<String> onCommentChanged;
  final bool isSubmitting;
  final String? title;
  final String? hintText;
  final bool readOnly;

  const RatingCommentBox({
    super.key,
    required this.comment,
    required this.onCommentChanged,
    this.isSubmitting = false,
    this.title,
    this.hintText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: comment,
                selection: TextSelection.collapsed(offset: comment.length),
              ),
            ),
            onChanged: onCommentChanged,
            readOnly: readOnly || isSubmitting,
            maxLines: 3,
            maxLength: 1000,
            buildCounter: (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) =>
                null,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText ?? 'Add a comment (optional)',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: isSubmitting
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSubmitting ? 'Sending securely' : 'Shared anonymously',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSubmitting
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Text(
                '${comment.length} / 1000',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
