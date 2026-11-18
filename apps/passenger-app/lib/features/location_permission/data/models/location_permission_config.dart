/// Configuration and localized copy for the Location Permission flow.
class LocationPermissionConfig {
  static const String screenTitle = 'Location Permission';

  // Screen 1: Prompt State
  static const String serviceAreaBadge = 'Lethbridge Service Area';
  static const String skipForNow = 'Skip for now';
  static const String accurate5m = 'Accurate to 5m';
  static const String scenicPickupCardTitle = 'Downtown / Scenic Dr';
  static const String scenicPickupCardSub = '3 mins average pickup';

  static const String promptHeadline = 'Find your pickup spot';
  static const String promptDescription =
      'We use your precise location only to set your pickup point with zero hassle. Never tracked in the background.';
  static const String privacyBadge =
      'Used only while actively using the app';

  static const String valProp1Title = '1-Tap Booking';
  static const String valProp1Sub = 'No street typing required';
  static const String valProp2Title = 'Driver Meetup';
  static const String valProp2Sub = 'Guides driver straight to curb';

  static const String allowLocationButton = 'Allow location';
  static const String enterPickupManually = 'Enter pickup manually';

  // Screen 2: Unavailable State
  static const String fleetBadge = 'Bridge City Fleet • Lethbridge';
  static const String gpsInactive = 'GPS Inactive';
  static const String awaitingCoords =
      'Awaiting coordinates • Coulee Corridor';
  static const String permissionUnavailableBadge = 'PERMISSION UNAVAILABLE';

  static const String unavailableHeadline =
      'Location is off. You can still type your pickup address.';
  static const String unavailableDescription =
      'To automatically detect your pickup point at Park Place Mall, Downtown, or West Lethbridge, enable location permissions in system settings.';
  static const String commonHubsHeader = 'Common hubs nearby';

  static const String searchAddressButton = 'Search address';
  static const String openSettingsButton = 'Open settings';
  static const String settingsNotice =
      'You can change permission settings anytime in your device Settings.';
}
