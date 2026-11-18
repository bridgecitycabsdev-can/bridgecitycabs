import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/location_hub.dart';

enum LocationPermissionStatus {
  /// Screen 2: Initial precision prompt ("Find your pickup spot").
  prompt,

  /// Screen 1: Permission denied, deniedForever, or GPS switched off ("Location is off").
  unavailable,

  /// Location permission granted and coordinates ready, routes to next step.
  granted,

  /// User chose manual address entry or selected a common hub.
  manualSearch,
}

abstract class LocationPermissionState extends Equatable {
  final LocationPermissionStatus status;
  final Position? position;
  final LocationHub? selectedHub;
  final String? targetRoute;

  const LocationPermissionState({
    required this.status,
    this.position,
    this.selectedHub,
    this.targetRoute,
  });

  bool get isPrompt => status == LocationPermissionStatus.prompt;
  bool get isUnavailable => status == LocationPermissionStatus.unavailable;
  bool get isGranted => status == LocationPermissionStatus.granted;
  bool get isManualSearch => status == LocationPermissionStatus.manualSearch;

  @override
  List<Object?> get props => [status, position, selectedHub, targetRoute];
}

/// Screen 2 (Prompt State):
/// "Find your pickup spot", "Accurate to 5m", value props, and "Allow location" button.
class LocationPermissionPromptState extends LocationPermissionState {
  const LocationPermissionPromptState()
      : super(status: LocationPermissionStatus.prompt);
}

/// Screen 1 (Unavailable / Denied State):
/// "Location is off", "PERMISSION UNAVAILABLE" badge, common hubs, "Search address" and "Open settings".
class LocationPermissionUnavailableState extends LocationPermissionState {
  final bool isGpsDisabled;

  const LocationPermissionUnavailableState({this.isGpsDisabled = false})
      : super(status: LocationPermissionStatus.unavailable);

  @override
  List<Object?> get props => [...super.props, isGpsDisabled];
}

/// Terminal State: Permission granted with coordinates.
class LocationPermissionGrantedState extends LocationPermissionState {
  const LocationPermissionGrantedState({
    super.position,
    required String targetRoute,
  }) : super(
          status: LocationPermissionStatus.granted,
          targetRoute: targetRoute,
        );
}

/// Terminal State: User chose to search or pick a hub manually.
class LocationPermissionManualSearchState extends LocationPermissionState {
  const LocationPermissionManualSearchState({
    super.selectedHub,
    required String targetRoute,
  }) : super(
          status: LocationPermissionStatus.manualSearch,
          targetRoute: targetRoute,
        );
}
