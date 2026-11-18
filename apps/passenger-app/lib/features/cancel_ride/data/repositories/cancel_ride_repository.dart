import 'dart:async';

abstract class CancelRideRepository {
  Future<bool> checkCanCancel({required String bookingId});
  Future<void> submitCancellation({
    required String bookingId,
    required String reason,
  });
}

class MockCancelRideRepository implements CancelRideRepository {
  final bool isTripOngoing;
  final Duration delay;

  MockCancelRideRepository({
    this.isTripOngoing = false,
    this.delay = const Duration(milliseconds: 1000),
  });

  @override
  Future<bool> checkCanCancel({required String bookingId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return !isTripOngoing;
  }

  @override
  Future<void> submitCancellation({
    required String bookingId,
    required String reason,
  }) async {
    await Future.delayed(delay);
  }
}
