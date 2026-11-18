import 'package:equatable/equatable.dart';

enum DriverSplashStatus {
  initial,          // State 1: Clean splash with spinner & Lethbridge, Alberta
  connecting,       // State 2: "Still connecting..." + ● RETRYING LETHBRIDGE HUB
  connectionError,  // State 3: Modal "Couldn't connect. Check your internet and try again."
  updateRequired,   // State 4: Modal "Update available. Please update the app to continue."
  ready,            // Completed bootstrap -> Navigate to auth or driver dashboard
}

class DriverDispatchHubInfo extends Equatable {
  final String hubName;
  final String fleetDispatchTag;
  final String appVersion;
  final String minimumRequiredVersion;
  final String locationTag;
  final String tagline;
  final bool isFleetDispatchOnline;

  const DriverDispatchHubInfo({
    this.hubName = 'Lethbridge Hub',
    this.fleetDispatchTag = 'Fleet Dispatch',
    this.appVersion = 'v2.1.0',
    this.minimumRequiredVersion = 'v2.0.0',
    this.locationTag = 'Lethbridge, Alberta',
    this.tagline = 'Drive. Earn. On your schedule.',
    this.isFleetDispatchOnline = true,
  });

  @override
  List<Object?> get props => [
        hubName,
        fleetDispatchTag,
        appVersion,
        minimumRequiredVersion,
        locationTag,
        tagline,
        isFleetDispatchOnline,
      ];
}
