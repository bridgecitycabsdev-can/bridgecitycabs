import 'dart:async';
import '../models/driver_search_models.dart';

abstract class SearchingDriverRepository {
  Stream<SearchingDriverStatus> watchStatus(String trackingId);
  Future<void> cancelBooking(String trackingId, {String? reason});
  Future<void> retrySearch(String trackingId);
  Future<MatchedDriverInfo?> getDriverInfo(String trackingId);
}

class MockSearchingDriverRepository implements SearchingDriverRepository {
  final Duration? autoDriverFoundDelay;
  final bool shouldFailCancel;
  final StreamController<SearchingDriverStatus> _controller =
      StreamController<SearchingDriverStatus>.broadcast();

  MockSearchingDriverRepository({
    this.autoDriverFoundDelay,
    this.shouldFailCancel = false,
  });

  @override
  Stream<SearchingDriverStatus> watchStatus(String trackingId) {
    if (autoDriverFoundDelay != null) {
      Future.delayed(autoDriverFoundDelay!, () {
        if (!_controller.isClosed) {
          _controller.add(SearchingDriverStatus.driverFound);
        }
      });
    }
    return _controller.stream;
  }

  @override
  Future<void> cancelBooking(String trackingId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (shouldFailCancel) {
      throw Exception('Failed to cancel dispatch. Please try again.');
    }
    if (!_controller.isClosed) {
      _controller.add(SearchingDriverStatus.cancelled);
    }
  }

  @override
  Future<void> retrySearch(String trackingId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_controller.isClosed) {
      _controller.add(SearchingDriverStatus.searching);
    }
  }

  @override
  Future<MatchedDriverInfo?> getDriverInfo(String trackingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MatchedDriverInfo.sample;
  }

  void simulateStatus(SearchingDriverStatus status) {
    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  void dispose() {
    _controller.close();
  }
}
