import 'dart:async';
import '../models/receipt_models.dart';

abstract class TripReceiptRepository {
  Future<TripReceiptDetails> fetchReceipt({required String trackingId});
  Future<bool> checkCashPaymentStatus({required String trackingId});
  Future<void> submitDriverRating({
    required String trackingId,
    required double rating,
    String? feedback,
  });
  Future<void> reportProblem({
    required String trackingId,
    required String description,
  });
}

class MockTripReceiptRepository implements TripReceiptRepository {
  final Duration delay;
  final bool simulateAutoCashConfirmation;

  MockTripReceiptRepository({
    this.delay = const Duration(milliseconds: 600),
    this.simulateAutoCashConfirmation = false,
  });

  @override
  Future<TripReceiptDetails> fetchReceipt({required String trackingId}) async {
    await Future.delayed(delay);
    return const TripReceiptDetails();
  }

  @override
  Future<bool> checkCashPaymentStatus({required String trackingId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return simulateAutoCashConfirmation;
  }

  @override
  Future<void> submitDriverRating({
    required String trackingId,
    required double rating,
    String? feedback,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> reportProblem({
    required String trackingId,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}
