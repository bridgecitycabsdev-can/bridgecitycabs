import '../models/driver_home_metrics.dart';

abstract class DriverHomeRepository {
  Future<bool> startShift();
  Future<bool> pauseShift();
  Future<bool> resumeShift();
  Future<bool> endShift();
  Future<bool> retryNetworkConnection();
  Future<bool> requestLocationPermission();
  Future<DriverHomeMetrics> refreshMetrics();
}

class MockDriverHomeRepository implements DriverHomeRepository {
  @override
  Future<bool> startShift() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> pauseShift() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> resumeShift() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> endShift() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> retryNetworkConnection() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  @override
  Future<DriverHomeMetrics> refreshMetrics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const DriverHomeMetrics(
      todayEarnings: 41.77,
      ridesToday: 1,
      acceptanceRate: 50,
      onlineTime: '2h 15m',
      pingMs: 18,
    );
  }
}
