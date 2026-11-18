import 'package:flutter/material.dart';
import '../../data/models/no_driver_models.dart';

class NoDriverActionButtons extends StatelessWidget {
  final NoDriverStatus status;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const NoDriverActionButtons({
    super.key,
    required this.status,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelling = status == NoDriverStatus.cancelling;
    final isRetrySearching = status == NoDriverStatus.retrySearching;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isCancelling
                ? null
                : (isRetrySearching ? null : onRetry),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCancelling
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFFC62828),
              disabledBackgroundColor: isCancelling
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFFC62828),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCancelling) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Cancelling ride...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ] else if (isRetrySearching) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Searching...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.refresh, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Try again',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Text Button
        TextButton(
          onPressed: isCancelling ? null : onCancel,
          child: Text(
            'Cancel ride',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isCancelling
                  ? const Color(0xFFBDBDBD)
                  : const Color(0xFFC62828),
            ),
          ),
        ),
      ],
    );
  }
}
