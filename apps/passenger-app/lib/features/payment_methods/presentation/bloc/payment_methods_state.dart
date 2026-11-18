import 'package:equatable/equatable.dart';
import '../../data/models/payment_card_model.dart';
import '../../data/models/payment_methods_config.dart';

class PaymentMethodsState extends Equatable {
  final PaymentMethodsStatus status;
  final List<PaymentCard> cards;
  final SelectedPaymentType selectedPaymentType;
  final String? updatingCardId;
  final PaymentCard? cardPendingRemoval;
  final String? errorMessage;
  final bool navigateBack;
  final bool showAddCardSheet;

  const PaymentMethodsState({
    this.status = PaymentMethodsStatus.loading,
    this.cards = const [],
    this.selectedPaymentType = SelectedPaymentType.card,
    this.updatingCardId,
    this.cardPendingRemoval,
    this.errorMessage,
    this.navigateBack = false,
    this.showAddCardSheet = false,
  });

  bool get isLoading => status == PaymentMethodsStatus.loading;
  bool get isUpdatingDefault => status == PaymentMethodsStatus.updatingDefault;
  bool get hasCards => cards.isNotEmpty;
  bool get isCashDefault =>
      selectedPaymentType == SelectedPaymentType.cash || cards.isEmpty;

  PaymentCard? get defaultCard {
    for (final card in cards) {
      if (card.isDefault) return card;
    }
    return cards.isNotEmpty ? cards.first : null;
  }

  String get cardsCountSubtitle {
    if (cards.isEmpty) return '0 on file';
    return '${cards.length} cards available';
  }

  PaymentMethodsState copyWith({
    PaymentMethodsStatus? status,
    List<PaymentCard>? cards,
    SelectedPaymentType? selectedPaymentType,
    String? updatingCardId,
    PaymentCard? cardPendingRemoval,
    String? errorMessage,
    bool clearError = false,
    bool clearPendingRemoval = false,
    bool? navigateBack,
    bool? showAddCardSheet,
  }) {
    return PaymentMethodsState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      selectedPaymentType: selectedPaymentType ?? this.selectedPaymentType,
      updatingCardId: updatingCardId,
      cardPendingRemoval: clearPendingRemoval
          ? null
          : (cardPendingRemoval ?? this.cardPendingRemoval),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navigateBack: navigateBack ?? this.navigateBack,
      showAddCardSheet: showAddCardSheet ?? this.showAddCardSheet,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cards,
        selectedPaymentType,
        updatingCardId,
        cardPendingRemoval,
        errorMessage,
        navigateBack,
        showAddCardSheet,
      ];
}
