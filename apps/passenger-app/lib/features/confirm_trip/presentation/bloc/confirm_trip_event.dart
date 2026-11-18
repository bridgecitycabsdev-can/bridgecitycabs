import 'package:equatable/equatable.dart';
import '../../data/models/payment_method_info.dart';

abstract class ConfirmTripEvent extends Equatable {
  const ConfirmTripEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the confirmation screen opens.
class ConfirmTripStarted extends ConfirmTripEvent {
  final PaymentType initialPayment;
  final bool hasLinkedCard;
  final bool simulateDecline;
  final bool simulateFareChange;

  const ConfirmTripStarted({
    this.initialPayment = PaymentType.cash,
    this.hasLinkedCard = true,
    this.simulateDecline = false,
    this.simulateFareChange = false,
  });

  @override
  List<Object?> get props => [
        initialPayment,
        hasLinkedCard,
        simulateDecline,
        simulateFareChange,
      ];
}

/// Dispatched when switching between Cash and Card tabs.
class ConfirmTripPaymentTypeChanged extends ConfirmTripEvent {
  final PaymentType type;

  const ConfirmTripPaymentTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Dispatched when passenger taps "+ Link Visa / Mastercard" to add a card.
class ConfirmTripAddCardTapped extends ConfirmTripEvent {
  const ConfirmTripAddCardTapped();
}

/// Dispatched when passenger types a note for the driver (e.g. gate code).
class ConfirmTripDriverNotesUpdated extends ConfirmTripEvent {
  final String notes;

  const ConfirmTripDriverNotesUpdated(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Dispatched when passenger changes departure time (Now vs Schedule).
class ConfirmTripPickupTimeChanged extends ConfirmTripEvent {
  final String time;

  const ConfirmTripPickupTimeChanged(this.time);

  @override
  List<Object?> get props => [time];
}

/// Dispatched when passenger taps "Book ride • $XX.XX CAD".
class ConfirmTripBookTapped extends ConfirmTripEvent {
  const ConfirmTripBookTapped();
}

/// Dispatched when passenger accepts recalculate fare ("Confirm new total • $24.60 CAD").
class ConfirmTripFareChangeAccepted extends ConfirmTripEvent {
  const ConfirmTripFareChangeAccepted();
}

/// Dispatched when passenger rejects new total ("Back to vehicles").
class ConfirmTripFareChangeDeclined extends ConfirmTripEvent {
  const ConfirmTripFareChangeDeclined();
}

/// Dispatched when passenger dismisses or switches to cash from card decline alert.
class ConfirmTripDismissDeclineBanner extends ConfirmTripEvent {
  const ConfirmTripDismissDeclineBanner();
}

/// Dispatched when passenger taps the top back button `←`.
class ConfirmTripBackTapped extends ConfirmTripEvent {
  const ConfirmTripBackTapped();
}
