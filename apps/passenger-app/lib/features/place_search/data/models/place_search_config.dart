/// Localized strings and configurations for the Place Search feature.
class PlaceSearchConfig {
  static const String screenTitle = 'Set Location';
  static const String pickupLabel = 'PICKUP';
  static const String defaultPickupAddress =
      'Current location (Downtown Lethbridge)';
  static const String downtownPickupAddress = '515 5th Ave S, Downtown';

  static const String destinationLabel = 'Where to?';
  static const String destinationPlaceholder = 'Where to?';

  // State 2: Empty / Prompt
  static const String promptHeadline = 'Search address or place';
  static const String promptDescription =
      'Type an address, business, or Lethbridge landmark to find your ride.';
  static const List<String> popularLandmarks = [
    'University of Lethbridge',
    'Park Place Mall',
    'Enmax Centre',
  ];

  // State 3: Searching
  static const String searchingNotice = '• Searching Lethbridge...';

  // State 4: Zero Results
  static const String emptyHeadline = 'No places found';
  static const String emptyDescription =
      'Try a different address, check spelling, or search for a nearby landmark in Lethbridge.';
  static const String setPinOnMapButton = 'Set pin on map instead';

  // State 5: Offline / Connection Error
  static const String offlineModeBadge = 'Offline mode';
  static const String offlineHeadline = 'Unable to connect to place search';
  static const String offlineDescription =
      'Please check your mobile data or Wi-Fi connection in Lethbridge and try again.';
  static const String tryAgainButton = 'Try again';
  static const String chooseOnMapButton = 'Choose on map instead';
  static const String dispatchHotlineNotice =
      'Need a cab right away? Dispatch is available at 403-328-8888';
  static const String dispatchPhoneNumber = '403-328-8888';
}
