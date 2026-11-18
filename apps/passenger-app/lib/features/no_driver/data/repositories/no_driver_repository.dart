import 'dart:async';

abstract class NoDriverRepository {
  Future<bool> retrySearch({required String trackingId});
  Future<void> cancelRide({required String trackingId});
}

class MockNoDriverRepository implements NoDriverRepository {
  final bool simulateSuccessOnRetry;
  final Duration retryDelay;
  final Duration cancelDelay;

  MockNoDriverRepository({
    this.simulateSuccessOnRetry = false,
    this.retryDelay = const Duration(milliseconds: 1200),
    this.cancelDelay = const Duration(milliseconds: 800),
  });

  @override
  Future<bool> retrySearch({required String trackingId}) async {
    await Future.delayed(retryDelay);
    return simulateSuccessOnRetry;
  }

  @override
  Future<void> cancelRide({required String trackingId}) async {
    await Future.delayed(cancelDelay);
  }
}
