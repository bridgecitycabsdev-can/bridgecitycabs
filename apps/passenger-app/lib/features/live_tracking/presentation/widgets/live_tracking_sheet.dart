import 'package:flutter/material.dart';
import '../../data/models/live_tracking_config.dart';
import '../../data/models/tracking_models.dart';
import 'arriving_alert_banner.dart';
import 'driver_info_card.dart';
import 'priority_sos_banner.dart';
import 'tracking_progress_bar.dart';
import 'tracking_route_card.dart';

class LiveTrackingSheet extends StatelessWidget {
  final LiveTrackingStatus status;
  final TrackingTripDetails trip;
  final TrackingDriverInfo driver;
  final bool isSosTriggered;
  final bool isTelemetrySyncing;
  final VoidCallback onCancelRide;
  final VoidCallback onTriggerSos;
  final VoidCallback onCancelSos;
  final VoidCallback onCall911;
  final VoidCallback onCopyTrackingId;

  const LiveTrackingSheet({
    super.key,
    required this.status,
    required this.trip,
    required this.driver,
    this.isSosTriggered = false,
    this.isTelemetrySyncing = false,
    required this.onCancelRide,
    required this.onTriggerSos,
    required this.onCancelSos,
    required this.onCall911,
    required this.onCopyTrackingId,
  });

  @override
  Widget build(BuildContext context) {
    final isTripOngoing = status == LiveTrackingStatus.tripInProgress ||
        status == LiveTrackingStatus.telemetrySyncing ||
        isSosTriggered;

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
              const SizedBox(height: 14),

              // Driver waiting banner (Screen 2)
              if (status == LiveTrackingStatus.driverArrived)
                const ArrivingAlertBanner(isSosSent: false),

              // Priority SOS Banner (Screen 4)
              if (isSosTriggered) const PrioritySosBanner(),

              // Title, ETA Badge & Subtitle
              _buildHeaderSection(),
              const SizedBox(height: 12),

              // Progress bar (for Trip in progress Screens 5 & 6)
              if (isTripOngoing && !isSosTriggered) ...[
                TrackingProgressBar(
                  progress: trip.tripProgress > 0 ? trip.tripProgress : 0.45,
                  pickupLabel: '515 5th Ave S',
                  dropoffLabel: trip.dropoffAddress,
                  isSyncing: isTelemetrySyncing,
                ),
                const SizedBox(height: 12),
              ],

              // Driver Card
              DriverInfoCard(
                driver: driver,
                showCarPhoto: status != LiveTrackingStatus.driverAssigned,
              ),
              const SizedBox(height: 12),

              // Tracking ID chip (Screens 1, 2, 3)
              if (!isTripOngoing) ...[
                _buildTrackingIdRow(),
                const SizedBox(height: 12),
              ],

              // Route Card
              TrackingRouteCard(
                trip: trip,
                isTripInProgress: isTripOngoing,
              ),
              const SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(isTripOngoing),
              const SizedBox(height: 8),

              // 911 Footer notice (Screens 4, 5, 6)
              if (isTripOngoing) ...[
                Center(
                  child: InkWell(
                    onTap: onCall911,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.info_outline,
                              size: 13, color: Color(0xFFC62828)),
                          SizedBox(width: 4),
                          Text(
                            LiveTrackingConfig.emergencyCallFooter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    if (isSosTriggered) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFC62828), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  LiveTrackingConfig.sosTriggeredTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F1F1F),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            LiveTrackingConfig.sosTriggeredSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      );
    }

    String title;
    String subtitle;
    Widget? trailingBadge;

    switch (status) {
      case LiveTrackingStatus.driverAssigned:
        title = '${driver.name} is assigned to your ride';
        subtitle = LiveTrackingConfig.driverAssignedSubtitle;
        trailingBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${trip.etaMinutes} MIN',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFC62828),
            ),
          ),
        );
        break;
      case LiveTrackingStatus.driverArrived:
        title = '${driver.name} has arrived';
        subtitle = 'Look for ${driver.vehicleModel} (${driver.licensePlate})';
        break;
      case LiveTrackingStatus.driverArriving:
        title = 'Your driver is arriving in ${trip.etaMinutes} min';
        subtitle = LiveTrackingConfig.driverArrivingSubtitle;
        break;
      case LiveTrackingStatus.tripInProgress:
        title = 'On the way to ${trip.dropoffAddress}';
        subtitle =
            'Estimated arrival in ${trip.etaMinutes} min (${trip.estimatedArrivalTime ?? '3:38 PM'})';
        break;
      case LiveTrackingStatus.telemetrySyncing:
        title = 'On the way to ${trip.dropoffAddress}';
        subtitle = '';
        trailingBadge = Text(
          '~${trip.etaMinutes} min',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        );
        break;
      default:
        title = 'Trip tracking';
        subtitle = '';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F1F1F),
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailingBadge != null) trailingBadge,
      ],
    );
  }

  Widget _buildTrackingIdRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onCopyTrackingId,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.copy, size: 12, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  'Tracking ID • ${trip.trackingId}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF00A86B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'GPS Synchronized',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00A86B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isTripOngoing) {
    if (isSosTriggered) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onCancelSos,
          icon: const Icon(Icons.cancel_outlined, color: Color(0xFF4B5563)),
          label: const Text(
            LiveTrackingConfig.cancelSosButton,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE5E7EB),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      );
    }

    if (isTripOngoing) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onTriggerSos,
          icon: const Icon(Icons.shield, color: Colors.white, size: 20),
          label: const Text(
            LiveTrackingConfig.sosEmergencyButton,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      );
    }

    // Cancel ride text button before pickup (Screens 1, 2, 3)
    return Center(
      child: TextButton(
        onPressed: onCancelRide,
        child: const Text(
          '✕ Cancel ride',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFFC62828),
          ),
        ),
      ),
    );
  }
}
