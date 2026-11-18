import 'package:flutter/material.dart';

class DriverProfileOfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;
  final bool isLoading;

  const DriverProfileOfflineBanner({
    super.key,
    required this.onRetry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: Color(0xFFC62828),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "You're offline. Some info may be out of sync.",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB71C1C),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFC62828)),
                    ),
                  )
                : const Icon(Icons.sync, size: 16, color: Color(0xFFC62828)),
            onPressed: isLoading ? null : onRetry,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
