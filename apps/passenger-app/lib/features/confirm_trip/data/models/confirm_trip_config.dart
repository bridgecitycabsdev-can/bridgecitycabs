/// Localized strings and configurations for the Confirm Trip screen.
class ConfirmTripConfig {
  static const String screenTitle = 'Confirm Trip';
  static const String pickupTitle = 'PICKUP';
  static const String dropoffTitle = 'DROPOFF';

  // Badges
  static const String oldmanRiverBadge = 'Route across Oldman River';
  static const String routeCalibrated = 'Route calibrated';
  static const String locatingDriver =
      'Locating nearest Bridge City cab... • High River corridor';

  // Time & Notes
  static const String pickupTimeLabel = 'Pickup time';
  static const String onDemandDispatch = 'On-demand dispatch';
  static const String fastestPickup = 'Now (Fastest pickup)';
  static const String addDriverNote = 'Add a note for the driver (optional)';

  // Fare
  static const String guaranteedRateNotice = 'Guaranteed upfront rate';
  static const String noSurgeNotice = 'Fixed rate • No surge applied';

  // Payment
  static const String paymentSectionTitle = 'Payment';
  static const String selectPaymentMethod = 'Select payment method';
  static const String payDriverAtDestination = 'Pay driver at destination';
  static const String cashNotice =
      'Pay your driver in cash at the end of the trip. Exact change or CAD currency accepted.';
  static const String notChargedUntilBooked =
      "You won't be charged until the trip is booked.";
  static const String notChargedUntilCompleted =
      "You won't be charged until the trip is completed.";

  // Declined state
  static const String cardDeclinedTitle =
      'Your card was declined. No booking was made.';
  static const String cardDeclinedSub =
      'Please check your card details, try another card, or switch to cash.';
  static const String tryAnotherCard = 'Try another card';
  static const String payWithCash = 'Pay with cash';
  static const String updatePaymentMethod = 'Update payment method';

  // Fare changed state
  static const String fareChangedTitle = 'Your fare has changed';
  static const String fareChangedDesc =
      'Due to updated traffic conditions and Lethbridge bridge corridor demand, the fare for this ride has been recalculated.';
  static const String previousFare = 'PREVIOUS FARE';
  static const String bridgeLineNotice =
      'Locking this rate guarantees arrival window regardless of bridge line delays.';
  static const String confirmNewTotal = 'Confirm new total';
  static const String backToVehicles = 'Back to vehicles';

  // Booking CTA
  static const String bookRide = 'Book ride';
  static const String bookingYourRide = 'Booking your ride...';
  static const String contactingDrivers =
      'Contacting nearby Lethbridge drivers...';
  static const String freeCancellation =
      'Free cancellation until a driver accepts your trip';
}
