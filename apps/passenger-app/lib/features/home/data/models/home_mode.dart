/// Modes / screens represented on the Home Screen.
enum HomeMode {
  /// Screen 1: Initial state ("Where to?").
  /// Shows floating menu & notifications, central location indicator,
  /// pickup/destination input card, category chips, and disabled Continue button.
  whereTo,

  /// Screen 5: Route defined with single destination ("Ready to ride").
  /// Shows computed distance (e.g., 3.4 km • ~6 mins), route map with pickup/dropoff pins,
  /// destination badge, category chips, and enabled Continue button.
  readyToRide,

  /// Screen 2: Single destination with disabled location alert ("Book a Ride").
  /// Shows back arrow, "Lethbridge Central" map pin, location disabled banner,
  /// preference chips, single vehicle tier card (City Red Cruiser), and trust footer.
  bookRide,

  /// Screen 3: Multi-stop itinerary ("Plan Ride").
  /// Shows polyline route with 3 waypoints, distance/ETA overlay (11.4 km • 16 min),
  /// hub chips, reorderable/removable itinerary stops, vehicle tier (Crimson Standard),
  /// payment method selector, and Continue button.
  planRide,
}
