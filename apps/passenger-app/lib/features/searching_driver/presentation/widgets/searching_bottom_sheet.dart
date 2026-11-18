import 'package:flutter/material.dart';
import '../../data/models/driver_search_models.dart';
import '../../data/models/searching_driver_config.dart';
import 'searching_progress_bar.dart';
import 'searching_route_summary_card.dart';
import 'searching_tracking_id_pill.dart';

class SearchingBottomSheet extends StatelessWidget {
  final SearchingDriverStatus status;
  final SearchBookingDetails booking;
  final bool isReconnecting;
  final int connectingSecondsRemaining;
  final bool isSubmittingCancel;
  final VoidCallback onCancel;
  final VoidCallback onCopyTrackingId;
  final VoidCallback onCallDispatch;

  const SearchingBottomSheet({
    super.key,
    required this.status,
    required this.booking,
    this.isReconnecting = false,
    this.connectingSecondsRemaining = 2,
    this.isSubmittingCancel = false,
    required this.onCancel,
    required this.onCopyTrackingId,
    required this.onCallDispatch,
  });

  @override
  Widget build(BuildContext context) {
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

              // Status Header Row
              _buildStatusHeader(),
              const SizedBox(height: 14),

              // Progress Bar
              SearchingProgressBar(
                status: status,
                isReconnecting: isReconnecting,
              ),
              const SizedBox(height: 12),

              // Tracking ID Row
              SearchingTrackingIdPill(
                trackingId: booking.trackingId,
                status: status,
                isReconnecting: isReconnecting,
                connectingSecondsRemaining: connectingSecondsRemaining,
                onCopy: onCopyTrackingId,
              ),
              const SizedBox(height: 14),

              // Route & Vehicle Card
              SearchingRouteSummaryCard(
                booking: booking,
                status: status,
                isReconnecting: isReconnecting,
              ),
              const SizedBox(height: 16),

              // Action Button
              _buildActionButton(),
              const SizedBox(height: 12),

              // Footer info/policy/dispatch notice
              _buildFooterNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    Widget iconWidget;

    if (booking.isScheduled) {
      iconWidget = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.calendar_today,
          color: Color(0xFFC62828),
          size: 22,
        ),
      );
    } else if (status == SearchingDriverStatus.driverFound) {
      iconWidget = Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFF00A86B),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 26,
        ),
      );
    } else if (isReconnecting) {
      iconWidget = Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.signal_wifi_off,
              color: Color(0xFF6B7280),
              size: 20,
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFC62828),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (status == SearchingDriverStatus.cancelling) {
      iconWidget = const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation(Color(0xFFE57373)),
        ),
      );
    } else {
      // Default searching loader
      iconWidget = const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation(Color(0xFFC62828)),
        ),
      );
    }

    String title;
    String subtitle;

    if (booking.isScheduled) {
      title = SearchingDriverConfig.rideScheduledTitle;
      subtitle = SearchingDriverConfig.rideScheduledSubtitle;
    } else if (status == SearchingDriverStatus.driverFound) {
      title = SearchingDriverConfig.driverFoundTitle;
      subtitle = SearchingDriverConfig.driverFoundSubtitle;
    } else if (status == SearchingDriverStatus.cancelling) {
      title = SearchingDriverConfig.cancellingTitle;
      subtitle = SearchingDriverConfig.cancellingSubtitle;
    } else if (isReconnecting) {
      title = SearchingDriverConfig.findingDriverTitle;
      subtitle = SearchingDriverConfig.reconnectingSubtitle;
    } else {
      title = SearchingDriverConfig.findingDriverTitle;
      subtitle = SearchingDriverConfig.findingDriverSubtitle;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F1F1F),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (booking.isScheduled &&
                      booking.scheduledDateTime != null) ...[
                    Text(
                      booking.scheduledDateTime!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (booking.isScheduled && booking.scheduledDayText != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 13,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Text(
                  booking.scheduledDayText!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton() {
    if (status == SearchingDriverStatus.cancelling || isSubmittingCancel) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFEBEE),
            disabledBackgroundColor: const Color(0xFFFFEBEE),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFFC62828)),
                ),
              ),
              SizedBox(width: 10),
              Text(
                SearchingDriverConfig.cancellingRideButton,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (booking.isScheduled) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFEBEE),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            '✕ Cancel scheduled ride',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFC62828),
            ),
          ),
        ),
      );
    }

    if (status == SearchingDriverStatus.driverFound || isReconnecting) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFEBEE),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            '✕ Cancel ride',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFC62828),
            ),
          ),
        ),
      );
    }

    // Default outlined cancel button for active search (Screen 1)
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFC62828), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          '✕ Cancel ride',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFFC62828),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNotice() {
    if (isReconnecting) {
      return Center(
        child: InkWell(
          onTap: onCallDispatch,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.phone_in_talk,
                  size: 14,
                  color: Color(0xFFC62828),
                ),
                SizedBox(width: 6),
                Text(
                  SearchingDriverConfig.callDispatchLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC62828),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (status == SearchingDriverStatus.cancelling) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.shield_outlined,
              size: 13,
              color: Color(0xFF6B7280),
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                SearchingDriverConfig.freeCancellationNotice,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.directions_car_outlined,
            size: 13,
            color: Color(0xFF6B7280),
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              SearchingDriverConfig.operatorTrustNotice,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
