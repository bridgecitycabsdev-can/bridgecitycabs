enum DriverTripHistoryStatus {
  gallery,
  tripDetail,
  filterSheet,
  emptyNoRides,
}

extension DriverTripHistoryStatusX on DriverTripHistoryStatus {
  String get label {
    switch (this) {
      case DriverTripHistoryStatus.gallery:
        return '1. History & Edge States';
      case DriverTripHistoryStatus.tripDetail:
        return '2. Trip Details & Manifest';
      case DriverTripHistoryStatus.filterSheet:
        return '3. Period Filter Sheet';
      case DriverTripHistoryStatus.emptyNoRides:
        return '4. Empty State (Zero Dispatches)';
    }
  }
}
