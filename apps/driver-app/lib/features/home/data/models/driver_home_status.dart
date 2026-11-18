enum DriverHomeStatus {
  offline,
  onlineSearching,
  locationOff,
  shiftAway,
  networkOffline,
  incomingOffer,
  accountPending;

  bool get isOffline => this == DriverHomeStatus.offline;
  bool get isOnlineSearching => this == DriverHomeStatus.onlineSearching;
  bool get isLocationOff => this == DriverHomeStatus.locationOff;
  bool get isShiftAway => this == DriverHomeStatus.shiftAway;
  bool get isNetworkOffline => this == DriverHomeStatus.networkOffline;
  bool get isIncomingOffer => this == DriverHomeStatus.incomingOffer;
  bool get isAccountPending => this == DriverHomeStatus.accountPending;
}
