class DriverHomeConfig {
  // State 1: Offline
  static const String offlineTitle = 'Currently offline';
  static const String offlineSubtitle = 'Lethbridge Fleet Zone 01';
  static const String offlineTag = 'OFFLINE';
  static const String offlineDesc =
      "You're offline. Start your shift to receive rides across Lethbridge and surrounding areas.";
  static const String goOnlineButton = 'GO ONLINE';
  static const String dispatchServerActive = 'Bridge City Dispatch Server Active';
  static const String pingValue = 'Ping 18ms';

  // State 2: Online & Searching
  static const String onlineTag = 'ONLINE';
  static const String searchingRidesTitle = 'Searching for rides...';
  static const String stayInBusyAreaDesc =
      'Stay in a busy area for faster requests.';
  static const String highDemandTitle = 'High demand near...';
  static const String surgeMultiplierText = '1.3x request surge in 4t...';
  static const String surgeBadge = '1.3x Surge';

  // State 3: Location / GPS Off
  static const String locationRequiredTitle = 'Location required';
  static const String locationRequiredSubtitle = 'Lethbridge City Zone Fleet #402';
  static const String locationOffTag = 'Offline (GPS)';
  static const String locationOffBannerTitle =
      'Location is off. Turn it on to get rides.';
  static const String locationOffBannerDesc =
      'High precision GPS is required by municipal dispatch rules.';
  static const String enableLocationSettings = 'Enable Location in Settings';
  static const String gpsNotice =
      'Bridge City dispatch relies on precise GPS to match nearby Lethbridge passengers, calculate route fares, and verify cab stand queues.';
  static const String signalLostBadge = 'SIGNAL LOST';

  // State 4: Shift On Pause (Away)
  static const String shiftOnPauseTitle = 'Shift on pause';
  static const String shiftOnPauseSubtitle = 'Bridge City Cabs • Unit 42';
  static const String awayTag = 'AWAY';
  static const String currentlyAwayTitle = "You're currently Away";
  static const String currentlyAwayDesc =
      "You won't get ride requests while you're away. Take a break, stretch, or grab a refuel on Scenic Drive.";
  static const String backToActiveButton = 'BACK TO ACTIVE';
  static const String downtownLocationPill = 'Downtown Lethbridge • 3 Ave S';

  // State 5: Connection Lost (Network Offline)
  static const String connectionLostTitle = 'Connection lost';
  static const String offlineNetworkTag = 'Offline (Network)';
  static const String signalPausedTopBar =
      'Signal paused • Auto-reconnecting GPS...';
  static const String offlineReconnectingBanner =
      "You're offline. Reconnecting...";
  static const String checkingConnectionServer =
      'Checking connection to Lethbridge dispatch server...';
  static const String attemptingRestoreTitle =
      'Attempting to restore dispatch f...';
  static const String cellularFallbackDesc =
      'Cellular data fallback active (LTE/3G)';
  static const String dispatchHelpline = 'Dispatch helpline';
  static const String dispatchPhone = '403-328-8888';
  static const String retryConnectionNow = 'Retry Connection Now';

  // State 6: Incoming Ride Offer
  static const String incomingRideOfferTitle = 'Incoming ride offer';
  static const String alertActiveTag = 'Alert active';
  static const String incomingDispatchChime =
      'Incoming dispatch chime playing... Tap below to review the ride details.';
  static const String dispatchBroadcast = 'Dispatch broadcast';
  static const String viewIncomingOffer =
      'View incoming trip offer (13s remaining)';

  // State 7: Account Pending (Dispatch Locked)
  static const String accountPendingTitle = 'Account pending';
  static const String accountPendingSubtitle =
      'Lethbridge City Bylaw #6141 verification';
  static const String pendingReviewTag = 'PENDING REVIEW';
  static const String documentsUnderReviewTitle =
      'Your documents are under review';
  static const String documentsUnderReviewDesc =
      'Lethbridge Taxi Commission compliance check in progress.';
  static const String viewDocumentsButton = 'View documents';
  static const String checkApplicationStatus = 'Check application status';
  static const String dispatchLockedTag = 'Dispatch locked';
  static const String verificationChecklistTitle = 'VERIFICATION CHECKLIST';
  static const String verificationRatio = '1 of 3 Approved';
  static const String verificationDeskNotice =
      'Submissions are reviewed by our Lethbridge dispatch operations desk. Most driver verifications finalize within 2 to 4 business hours.';
  static const String contactCitySupport =
      'Need assistance? Contact City Dispatch Support';
}
