enum DriverTripSummaryStatus {
  cardSettled,
  cashDue,
  ratePassenger,
  edgeStatesGallery,
  returnedToDispatch;

  String get label {
    switch (this) {
      case DriverTripSummaryStatus.cardSettled:
        return 'Card Auto-Settled';
      case DriverTripSummaryStatus.cashDue:
        return 'Cash Payment Due';
      case DriverTripSummaryStatus.ratePassenger:
        return 'Rate Passenger';
      case DriverTripSummaryStatus.edgeStatesGallery:
        return '6 Edge States';
      case DriverTripSummaryStatus.returnedToDispatch:
        return 'Returned to Dispatch';
    }
  }

  bool get isCardSettled => this == DriverTripSummaryStatus.cardSettled;
  bool get isCashDue => this == DriverTripSummaryStatus.cashDue;
  bool get isRatePassenger => this == DriverTripSummaryStatus.ratePassenger;
  bool get isEdgeStatesGallery => this == DriverTripSummaryStatus.edgeStatesGallery;
}
