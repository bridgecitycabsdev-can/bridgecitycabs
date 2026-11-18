import 'package:equatable/equatable.dart';
import '../../data/models/location_hub.dart';

/// Base class for all location permission events.
abstract class LocationPermissionEvent extends Equatable {
  const LocationPermissionEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on page mount to check current device permission & GPS status.
class LocationPermissionCheckRequested extends LocationPermissionEvent {
  const LocationPermissionCheckRequested();
}

/// Dispatched when passenger taps "🧭 Allow location".
class LocationPermissionAllowTapped extends LocationPermissionEvent {
  const LocationPermissionAllowTapped();
}

/// Dispatched when passenger taps "⚙️ Open settings".
class LocationPermissionOpenSettingsTapped extends LocationPermissionEvent {
  const LocationPermissionOpenSettingsTapped();
}

/// Dispatched when passenger taps "🔍 Search address" in unavailable state.
class LocationPermissionSearchAddressTapped extends LocationPermissionEvent {
  const LocationPermissionSearchAddressTapped();
}

/// Dispatched when passenger taps "Enter pickup manually" in prompt state.
class LocationPermissionManualPickupTapped extends LocationPermissionEvent {
  const LocationPermissionManualPickupTapped();
}

/// Dispatched when passenger selects one of the common hubs (Park Place, Downtown, ULeth).
class LocationPermissionHubSelected extends LocationPermissionEvent {
  final LocationHub hub;

  const LocationPermissionHubSelected(this.hub);

  @override
  List<Object?> get props => [hub];
}

/// Dispatched when passenger taps "Skip for now" or the top close button `✕`.
class LocationPermissionSkipTapped extends LocationPermissionEvent {
  const LocationPermissionSkipTapped();
}
