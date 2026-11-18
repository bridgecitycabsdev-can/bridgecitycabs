import 'package:flutter/material.dart';
import '../../data/models/no_driver_config.dart';
import '../../data/models/no_driver_models.dart';
import 'no_driver_action_buttons.dart';
import 'no_driver_notice_banner.dart';
import 'no_driver_route_summary_card.dart';
import 'no_driver_tip_card.dart';

class NoDriverBottomSheet extends StatelessWidget {
  final NoDriverStatus status;
  final NoDriverBookingDetails booking;
  final VoidCallback onRetry;
  final VoidCallback onCancel;
  final VoidCallback onCopyTrackingId;
  final VoidCallback onCallDispatch;
  final VoidCallback? onBookDifferentVehicle;

  const NoDriverBottomSheet({
    super.key,
    required this.status,
    required this.booking,
    required this.onRetry,
    required this.onCancel,
    required this.onCopyTrackingId,
    required this.onCallDispatch,
    this.onBookDifferentVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelling = status == NoDriverStatus.cancelling;
    final isStillNoDriver = status == NoDriverStatus.stillNoDriver;
    final isRetrySearching = status == NoDriverStatus.retrySearching;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isCancelling
                    ? NoDriverConfig.cancellingTitle
                    : NoDriverConfig.noDriverTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F1F1F),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                isCancelling
                    ? NoDriverConfig.cancellingSubtitle
                    : NoDriverConfig.noDriverSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),

              // Tracking ID chip
              Center(
                child: InkWell(
                  onTap: onCopyTrackingId,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy,
                          size: 13,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tracking ID • ${booking.trackingId}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Route & Vehicle Summary
              NoDriverRouteSummaryCard(
                booking: booking,
                isCancelling: isCancelling,
              ),
              const SizedBox(height: 12),

              // Cancellation or Error or Tip Banner
              if (isCancelling) ...[
                const NoDriverNoticeBanner(isCancellation: true),
                const SizedBox(height: 14),
              ] else ...[
                NoDriverTipCard(
                  onBookDifferentVehicle: onBookDifferentVehicle,
                ),
                if (isStillNoDriver) ...[
                  const SizedBox(height: 10),
                  const NoDriverNoticeBanner(isCancellation: false),
                ],
                const SizedBox(height: 14),
              ],

              // Action Buttons
              NoDriverActionButtons(
                status: status,
                onRetry: onRetry,
                onCancel: onCancel,
              ),
              const SizedBox(height: 8),

              // Footer Link / Status text
              Center(
                child: _buildFooter(
                  isCancelling: isCancelling,
                  isStillNoDriver: isStillNoDriver,
                  isRetrySearching: isRetrySearching,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter({
    required bool isCancelling,
    required bool isStillNoDriver,
    required bool isRetrySearching,
  }) {
    if (isCancelling) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, size: 6, color: Color(0xFFC62828)),
          SizedBox(width: 6),
          Text(
            NoDriverConfig.returningHomeFooter,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      );
    }

    if (isRetrySearching) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, size: 6, color: Color(0xFF6B7280)),
          SizedBox(width: 6),
          Text(
            NoDriverConfig.searchingFleetFooter,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onCallDispatch,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.phone,
              size: 14,
              color: Color(0xFFC62828),
            ),
            const SizedBox(width: 6),
            Text(
              isStillNoDriver
                  ? NoDriverConfig.callDispatchFooter
                  : NoDriverConfig.urgentCallFooter,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
