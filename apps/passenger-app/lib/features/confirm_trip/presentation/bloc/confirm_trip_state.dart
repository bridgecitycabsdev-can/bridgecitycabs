import 'package:equatable/equatable.dart';
import '../../data/models/fare_breakdown.dart';
import '../../data/models/payment_method_info.dart';
import '../../data/models/trip_booking_details.dart';

enum ConfirmTripStatus {
  /// Screen 1 & 3: Ready to book (Cash or valid linked Card).
  ready,

  /// Screen 2: Card option chosen but no card is on file (CTA disabled).
  cardRequired,

  /// Screen 4: Booking request actively submitting ("Booking your ride...").
  booking,

  /// Screen 5: Card was declined by bank/issuer.
  declined,

  /// Screen 6: Surge or traffic recalculation modal ("Your fare has changed").
  fareChanged,

  /// Successful booking submission, ready to transition to searching / tracking.
  success,
}

class ConfirmTripState extends Equatable {
  final ConfirmTripStatus status;
  final TripBookingDetails details;
  final PaymentMethodInfo payment;
  final FareBreakdown fare;
  final String? targetRoute;

  const ConfirmTripState({
    this.status = ConfirmTripStatus.ready,
    this.details = const TripBookingDetails(),
    this.payment = PaymentMethodInfo.cash,
    this.fare = FareBreakdown.standard,
    this.targetRoute,
  });

  bool get isReady => status == ConfirmTripStatus.ready;
  bool get isBooking => status == ConfirmTripStatus.booking;
  bool get isCardRequired => status == ConfirmTripStatus.cardRequired;
  bool get isDeclined => status == ConfirmTripStatus.declined || payment.isDeclined;
  bool get isFareChanged => status == ConfirmTripStatus.fareChanged;

  bool get canBook {
    if (isBooking) return false;
    if (payment.isCash) return true;
    return payment.isCard && payment.isLinked && !payment.isDeclined;
  }

  String get ctaButtonText {
    if (isBooking) return 'Booking your ride...';
    if (isDeclined) return 'Update payment method • ${fare.formattedTotal}';
    return 'Book ride • ${fare.formattedTotal}';
  }

  ConfirmTripState copyWith({
    ConfirmTripStatus? status,
    TripBookingDetails? details,
    PaymentMethodInfo? payment,
    FareBreakdown? fare,
    String? targetRoute,
  }) {
    return ConfirmTripState(
      status: status ?? this.status,
      details: details ?? this.details,
      payment: payment ?? this.payment,
      fare: fare ?? this.fare,
      targetRoute: targetRoute,
    );
  }

  @override
  List<Object?> get props => [
        status,
        details,
        payment,
        fare,
        targetRoute,
      ];
}
