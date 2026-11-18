import 'package:equatable/equatable.dart';
import '../../data/models/receipt_models.dart';

abstract class TripReceiptEvent extends Equatable {
  const TripReceiptEvent();

  @override
  List<Object?> get props => [];
}

class TripReceiptStarted extends TripReceiptEvent {
  final TripReceiptDetails? receipt;
  final bool simulateLoading;
  final TripReceiptStatus? initialStatus;

  const TripReceiptStarted({
    this.receipt,
    this.simulateLoading = false,
    this.initialStatus,
  });

  @override
  List<Object?> get props => [receipt, simulateLoading, initialStatus];
}

class TripReceiptCashPaymentConfirmed extends TripReceiptEvent {
  const TripReceiptCashPaymentConfirmed();
}

class TripReceiptRateDriverTapped extends TripReceiptEvent {
  const TripReceiptRateDriverTapped();
}

class TripReceiptRatingSubmitted extends TripReceiptEvent {
  final double rating;
  final String? feedback;

  const TripReceiptRatingSubmitted({
    required this.rating,
    this.feedback,
  });

  @override
  List<Object?> get props => [rating, feedback];
}

class TripReceiptReportProblemTapped extends TripReceiptEvent {
  const TripReceiptReportProblemTapped();
}

class TripReceiptCopyTrackingIdTapped extends TripReceiptEvent {
  const TripReceiptCopyTrackingIdTapped();
}

class TripReceiptDoneTapped extends TripReceiptEvent {
  const TripReceiptDoneTapped();
}
