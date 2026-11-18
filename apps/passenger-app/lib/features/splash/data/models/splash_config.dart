/// Configuration and localized copy constants for Bridge City Cabs splash screens.
class SplashConfig {
  static const String appName = 'Bridge City Cabs';
  static const String appTagline = 'Your perfect ride is just a tap away.';
  static const String trustedBadgeText = "Southern Alberta's Trusted Choice";
  static const String cityRegion = 'LETHBRIDGE, ALBERTA';
  static const String reconnectingDispatchNotice = 'Reconnecting to fleet dispatch';
  static const String stillConnectingPill = 'Still connecting...';
  static const String lowSignalPill = 'Low Signal';
  static const String offlinePill = 'Offline';
  static const String searchingSignalPill = 'SEARCHING SIGNAL';

  // Modal Card Strings
  static const String errorTitle = 'Connection Interrupted';
  static const String errorSubtitle =
      "Couldn't connect. Check your internet and try again.";
  static const String tryAgainButton = 'Try again';
  static const String urgentCabHeader = 'Need a cab urgently?';
  static const String urgentCabPhoneDisplay = 'Call 403-555-CABS →';
  static const String urgentCabPhoneDialUrl = 'tel:4035552227';

  // Latency & Timeout thresholds
  static const Duration slowConnectionThreshold = Duration(milliseconds: 2500);
  static const Duration offlineTimeoutThreshold = Duration(milliseconds: 7000);
}
