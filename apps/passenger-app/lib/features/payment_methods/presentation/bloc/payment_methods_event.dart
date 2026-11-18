import 'package:equatable/equatable.dart';
import '../../data/models/payment_card_model.dart';

abstract class PaymentMethodsEvent extends Equatable {
  const PaymentMethodsEvent();

  @override
  List<Object?> get props => [];
}

class PaymentMethodsStarted extends PaymentMethodsEvent {
  final List<PaymentCard>? initialCards;
  final PaymentMethodsStatus? initialStatus;
  final bool simulateLoading;
  final SelectedPaymentType? initialPaymentType;

  const PaymentMethodsStarted({
    this.initialCards,
    this.initialStatus,
    this.simulateLoading = false,
    this.initialPaymentType,
  });

  @override
  List<Object?> get props => [
        initialCards,
        initialStatus,
        simulateLoading,
        initialPaymentType,
      ];
}

class PaymentMethodsCashSelected extends PaymentMethodsEvent {
  const PaymentMethodsCashSelected();
}

class PaymentMethodsCardSelected extends PaymentMethodsEvent {
  final String cardId;

  const PaymentMethodsCardSelected(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class PaymentMethodsRemoveCardInitiated extends PaymentMethodsEvent {
  final PaymentCard card;

  const PaymentMethodsRemoveCardInitiated(this.card);

  @override
  List<Object?> get props => [card];
}

class PaymentMethodsRemoveCardConfirmed extends PaymentMethodsEvent {
  final String cardId;

  const PaymentMethodsRemoveCardConfirmed(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class PaymentMethodsRemoveCardCancelled extends PaymentMethodsEvent {
  const PaymentMethodsRemoveCardCancelled();
}

class PaymentMethodsAddCardTapped extends PaymentMethodsEvent {
  const PaymentMethodsAddCardTapped();
}

class PaymentMethodsCardAdded extends PaymentMethodsEvent {
  final CardBrand brand;
  final String last4;
  final String expiry;

  const PaymentMethodsCardAdded({
    required this.brand,
    required this.last4,
    required this.expiry,
  });

  @override
  List<Object?> get props => [brand, last4, expiry];
}

class PaymentMethodsErrorDismissed extends PaymentMethodsEvent {
  const PaymentMethodsErrorDismissed();
}

class PaymentMethodsRetryTapped extends PaymentMethodsEvent {
  const PaymentMethodsRetryTapped();
}

class PaymentMethodsBackTapped extends PaymentMethodsEvent {
  const PaymentMethodsBackTapped();
}
