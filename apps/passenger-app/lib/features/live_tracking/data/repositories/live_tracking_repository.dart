import 'dart:async';
import '../models/tracking_models.dart';

abstract class LiveTrackingRepository {
  Stream<LiveTrackingStatus> watchTripStatus(String trackingId);
  Future<void> triggerSosAlert(String trackingId);
  Future<void> cancelSosAlert(String trackingId);
  Future<void> cancelTrip(String trackingId);
  Future<TrackingDriverInfo> getDriverInfo(String trackingId);
}

class MockLiveTrackingRepository implements LiveTrackingRepository {
  final StreamController<LiveTrackingStatus> _controller =
      StreamController<LiveTrackingStatus>.broadcast();

  @override
  Stream<LiveTrackingStatus> watchTripStatus(String trackingId) {
    return _controller.stream;
  }

  @override
  Future<void> triggerSosAlert(String trackingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _controller.add(LiveTrackingStatus.sosTriggered);
  }

  @override
  Future<void> cancelSosAlert(String trackingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _controller.add(LiveTrackingStatus.tripInProgress);
  }

  @override
  Future<void> cancelTrip(String trackingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _controller.add(LiveTrackingStatus.cancelled);
  }

  @override
  Future<TrackingDriverInfo> getDriverInfo(String trackingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return TrackingDriverInfo.sample;
  }

  void simulateStatus(LiveTrackingStatus status) {
    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  void dispose() {
    _controller.close();
  }
}
