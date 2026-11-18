import 'dart:async';
import '../models/driver_decline_reason.dart';
import '../models/driver_request_config.dart';
import '../models/driver_request_model.dart';

abstract class DriverRequestRepository {
  Future<DriverRequestModel> fetchCurrentRequest();
  Future<bool> acceptRequest(String id);
  Future<bool> declineRequest(String id, {DriverDeclineReason? reason});
  Stream<int> startCountdown(int initialSeconds);
}

class FakeDriverRequestRepository implements DriverRequestRepository {
  final Duration networkLatency;

  FakeDriverRequestRepository({
    this.networkLatency = const Duration(milliseconds: 300),
  });

  @override
  Future<DriverRequestModel> fetchCurrentRequest() async {
    await Future.delayed(networkLatency);
    return DriverRequestConfig.instantPreset();
  }

  @override
  Future<bool> acceptRequest(String id) async {
    await Future.delayed(networkLatency);
    return true;
  }

  @override
  Future<bool> declineRequest(String id, {DriverDeclineReason? reason}) async {
    await Future.delayed(networkLatency);
    return true;
  }

  @override
  Stream<int> startCountdown(int initialSeconds) async* {
    for (int sec = initialSeconds; sec >= 0; sec--) {
      yield sec;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
