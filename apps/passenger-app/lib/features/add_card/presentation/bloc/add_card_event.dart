import 'package:equatable/equatable.dart';
import '../../data/models/add_card_models.dart';

abstract class AddCardEvent extends Equatable {
  const AddCardEvent();

  @override
  List<Object?> get props => [];
}

class AddCardStarted extends AddCardEvent {
  final CardFormData? initialForm;
  final AddCardStatus? initialStatus;
  final ThreeDSecureData? initialThreeD;

  const AddCardStarted({
    this.initialForm,
    this.initialStatus,
    this.initialThreeD,
  });

  @override
  List<Object?> get props => [initialForm, initialStatus, initialThreeD];
}

class AddCardNumberChanged extends AddCardEvent {
  final String cardNumber;

  const AddCardNumberChanged(this.cardNumber);

  @override
  List<Object?> get props => [cardNumber];
}

class AddCardExpiryChanged extends AddCardEvent {
  final String expiry;

  const AddCardExpiryChanged(this.expiry);

  @override
  List<Object?> get props => [expiry];
}

class AddCardCvcChanged extends AddCardEvent {
  final String cvc;

  const AddCardCvcChanged(this.cvc);

  @override
  List<Object?> get props => [cvc];
}

class AddCardPostalCodeChanged extends AddCardEvent {
  final String postalCode;

  const AddCardPostalCodeChanged(this.postalCode);

  @override
  List<Object?> get props => [postalCode];
}

class AddCardNameChanged extends AddCardEvent {
  final String name;

  const AddCardNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class AddCardDefaultToggled extends AddCardEvent {
  final bool isDefault;

  const AddCardDefaultToggled(this.isDefault);

  @override
  List<Object?> get props => [isDefault];
}

class AddCardSaveTapped extends AddCardEvent {
  const AddCardSaveTapped();
}

class AddCardOtpChanged extends AddCardEvent {
  final String otpCode;

  const AddCardOtpChanged(this.otpCode);

  @override
  List<Object?> get props => [otpCode];
}

class AddCardOtpSubmitted extends AddCardEvent {
  const AddCardOtpSubmitted();
}

class AddCard3DCancelled extends AddCardEvent {
  const AddCard3DCancelled();
}

class AddCardRetryTapped extends AddCardEvent {
  const AddCardRetryTapped();
}

class AddCardUseDifferentCardTapped extends AddCardEvent {
  const AddCardUseDifferentCardTapped();
}

class AddCardRefreshPendingTapped extends AddCardEvent {
  const AddCardRefreshPendingTapped();
}

class AddCardErrorDismissed extends AddCardEvent {
  const AddCardErrorDismissed();
}

class AddCardReturnToPaymentMethodsTapped extends AddCardEvent {
  const AddCardReturnToPaymentMethodsTapped();
}

class AddCardBackTapped extends AddCardEvent {
  const AddCardBackTapped();
}
