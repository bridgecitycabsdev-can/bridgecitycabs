import 'package:equatable/equatable.dart';
import '../../data/models/receipt_models.dart';
import '../../data/models/trip_receipt_config.dart';

class TripReceiptState extends Equatable {
  final TripReceiptStatus status;
  final TripReceiptDetails receipt;
  final bool isSubmittingRating;
  final bool isRatingSubmitted;
  final bool showRatingSheet;
  final bool showProblemSheet;
  final bool isCopiedToClipboard;
  final bool navigateToHome;

  const TripReceiptState({
    this.status = TripReceiptStatus.cashPending,
    this.receipt = const TripReceiptDetails(),
    this.isSubmittingRating = false,
    this.isRatingSubmitted = false,
    this.showRatingSheet = false,
    this.showProblemSheet = false,
    this.isCopiedToClipboard = false,
    this.navigateToHome = false,
  });

  bool get isLoading => status == TripReceiptStatus.loading;
  bool get isCashPending => status == TripReceiptStatus.cashPending;
  bool get isCashConfirmed => status == TripReceiptStatus.cashConfirmed;
  bool get isCardPaid => status == TripReceiptStatus.cardPaid;
  bool get isDiscountApplied => status == TripReceiptStatus.discountApplied;

  bool get canRateDriver => !isCashPending && !isRatingSubmitted;

  String get totalLabel =>
      isCashPending ? TripReceiptConfig.totalDueLabel : TripReceiptConfig.totalPaidLabel;

  String get formattedTotal => receipt.fare.formattedTotal;

  TripReceiptState copyWith({
    TripReceiptStatus? status,
    TripReceiptDetails? receipt,
    bool? isSubmittingRating,
    bool? isRatingSubmitted,
    bool? showRatingSheet,
    bool? showProblemSheet,
    bool? isCopiedToClipboard,
    bool? navigateToHome,
  }) {
    return TripReceiptState(
      status: status ?? this.status,
      receipt: receipt ?? this.receipt,
      isSubmittingRating: isSubmittingRating ?? this.isSubmittingRating,
      isRatingSubmitted: isRatingSubmitted ?? this.isRatingSubmitted,
      showRatingSheet: showRatingSheet ?? this.showRatingSheet,
      showProblemSheet: showProblemSheet ?? this.showProblemSheet,
      isCopiedToClipboard: isCopiedToClipboard ?? this.isCopiedToClipboard,
      navigateToHome: navigateToHome ?? this.navigateToHome,
    );
  }

  @override
  List<Object?> get props => [
        status,
        receipt,
        isSubmittingRating,
        isRatingSubmitted,
        showRatingSheet,
        showProblemSheet,
        isCopiedToClipboard,
        navigateToHome,
      ];
}
