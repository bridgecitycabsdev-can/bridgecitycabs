import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Platform location settings for on-shift tracking.
///
/// Android uses a location foreground service (while-in-use) so we avoid
/// ACCESS_BACKGROUND_LOCATION. iOS uses When In Use + the location background mode.
LocationSettings settingsFor(int intervalSec) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      intervalDuration: Duration(seconds: intervalSec),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'Bridge City Cabs: on shift',
        notificationText: 'Sharing your location while you are on shift',
        notificationChannelName: 'Shift tracking',
        enableWakeLock: true,
        setOngoing: true,
      ),
    );
  }
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return AppleSettings(
      accuracy: LocationAccuracy.high,
      activityType: ActivityType.automotiveNavigation,
      distanceFilter: 10,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
      allowBackgroundLocationUpdates: true,
    );
  }
  return const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );
}

/// Day-5 cadence: 5s with an active booking/offer, 15s when idle on shift.
int intervalSecondsFor({required bool bookingActive}) =>
    bookingActive ? 5 : 15;
