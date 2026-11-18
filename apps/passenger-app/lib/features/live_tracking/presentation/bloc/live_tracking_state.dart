import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../data/models/live_tracking_config.dart';
import '../../data/models/tracking_models.dart';

class LiveTrackingState extends Equatable {
  final LiveTrackingStatus status;
  final TrackingTripDetails trip;
  final TrackingDriverInfo driver;
  final bool isTelemetrySyncing;
  final bool isSosTriggered;
  final bool isCopiedToClipboard;
  final bool showCancelDialog;
  final bool showSafetyToolkit;
  final bool navigateToHome;
  final bool navigateToReceipt;

  const LiveTrackingState({
    this.status = LiveTrackingStatus.driverAssigned,
    this.trip = const TrackingTripDetails(),
    this.driver = TrackingDriverInfo.sample,
    this.isTelemetrySyncing = false,
    this.isSosTriggered = false,
    this.isCopiedToClipboard = false,
    this.showCancelDialog = false,
    this.showSafetyToolkit = false,
    this.navigateToHome = false,
    this.navigateToReceipt = false,
  });

  bool get isDriverAssigned => status == LiveTrackingStatus.driverAssigned;
  bool get isDriverArrived => status == LiveTrackingStatus.driverArrived;
  bool get isDriverArriving => status == LiveTrackingStatus.driverArriving;
  bool get isTripInProgress =>
      status == LiveTrackingStatus.tripInProgress ||
      status == LiveTrackingStatus.telemetrySyncing ||
      isSosTriggered;

  String get pillText {
    switch (status) {
      case LiveTrackingStatus.driverAssigned:
        return LiveTrackingConfig.driverAssignedPill;
      case LiveTrackingStatus.driverArrived:
        return LiveTrackingConfig.driverArrivedPill;
      case LiveTrackingStatus.driverArriving:
        return LiveTrackingConfig.driverArrivingPill;
      case LiveTrackingStatus.tripInProgress:
      case LiveTrackingStatus.telemetrySyncing:
      case LiveTrackingStatus.sosTriggered:
      case LiveTrackingStatus.tripCompleted:
      case LiveTrackingStatus.cancelled:
        return LiveTrackingConfig.tripInProgressPill;
    }
  }

  Color get pillDotColor {
    switch (status) {
      case LiveTrackingStatus.driverAssigned:
        return const Color(0xFFF59E0B); // Amber / orange
      case LiveTrackingStatus.driverArrived:
        return const Color(0xFF00A86B); // Green
      case LiveTrackingStatus.driverArriving:
        return const Color(0xFFC62828); // Red
      case LiveTrackingStatus.tripInProgress:
      case LiveTrackingStatus.telemetrySyncing:
      case LiveTrackingStatus.sosTriggered:
      case LiveTrackingStatus.tripCompleted:
      case LiveTrackingStatus.cancelled:
        return const Color(0xFF1F1F1F); // Black / dark
    }
  }

  String get title {
    if (isSosTriggered) return LiveTrackingConfig.sosTriggeredTitle;
    switch (status) {
      case LiveTrackingStatus.driverAssigned:
        return '${driver.name} is assigned to your ride';
      case LiveTrackingStatus.driverArrived:
        return '${driver.name} has arrived';
      case LiveTrackingStatus.driverArriving:
        return 'Your driver is arriving in ${trip.etaMinutes} min';
      case LiveTrackingStatus.tripInProgress:
      case LiveTrackingStatus.telemetrySyncing:
      case LiveTrackingStatus.tripCompleted:
      case LiveTrackingStatus.cancelled:
      case LiveTrackingStatus.sosTriggered:
        return 'On the way to ${trip.dropoffAddress}';
    }
  }

  String get subtitle {
    if (isSosTriggered) return LiveTrackingConfig.sosTriggeredSubtitle;
    switch (status) {
      case LiveTrackingStatus.driverAssigned:
        return LiveTrackingConfig.driverAssignedSubtitle;
      case LiveTrackingStatus.driverArrived:
        return 'Look for ${driver.vehicleModel} (${driver.licensePlate})';
      case LiveTrackingStatus.driverArriving:
        return LiveTrackingConfig.driverArrivingSubtitle;
      case LiveTrackingStatus.tripInProgress:
        final time = trip.estimatedArrivalTime ?? '3:38 PM';
        return 'Estimated arrival in ${trip.etaMinutes} min ($time)';
      case LiveTrackingStatus.telemetrySyncing:
        return '~${trip.etaMinutes} min';
      case LiveTrackingStatus.tripCompleted:
      case LiveTrackingStatus.cancelled:
      case LiveTrackingStatus.sosTriggered:
        return '';
    }
  }

  LiveTrackingState copyWith({
    LiveTrackingStatus? status,
    TrackingTripDetails? trip,
    TrackingDriverInfo? driver,
    bool? isTelemetrySyncing,
    bool? isSosTriggered,
    bool? isCopiedToClipboard,
    bool? showCancelDialog,
    bool? showSafetyToolkit,
    bool? navigateToHome,
    bool? navigateToReceipt,
  }) {
    return LiveTrackingState(
      status: status ?? this.status,
      trip: trip ?? this.trip,
      driver: driver ?? this.driver,
      isTelemetrySyncing: isTelemetrySyncing ?? this.isTelemetrySyncing,
      isSosTriggered: isSosTriggered ?? this.isSosTriggered,
      isCopiedToClipboard: isCopiedToClipboard ?? this.isCopiedToClipboard,
      showCancelDialog: showCancelDialog ?? this.showCancelDialog,
      showSafetyToolkit: showSafetyToolkit ?? this.showSafetyToolkit,
      navigateToHome: navigateToHome ?? this.navigateToHome,
      navigateToReceipt: navigateToReceipt ?? this.navigateToReceipt,
    );
  }

  @override
  List<Object?> get props => [
        status,
        trip,
        driver,
        isTelemetrySyncing,
        isSosTriggered,
        isCopiedToClipboard,
        showCancelDialog,
        showSafetyToolkit,
        navigateToHome,
        navigateToReceipt,
      ];
}
