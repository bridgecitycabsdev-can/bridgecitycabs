import '../models/driver_splash_model.dart';

abstract class DriverSplashRepository {
  Future<bool> checkFleetConnectivity();
  Future<bool> isUpdateRequired();
  Future<DriverDispatchHubInfo> getHubInfo();
  Future<bool> retryHubConnection();
}

class MockDriverSplashRepository implements DriverSplashRepository {
  final Duration delay;
  final bool shouldSimulateError;
  final bool shouldSimulateUpdate;

  MockDriverSplashRepository({
    this.delay = const Duration(milliseconds: 60),
    this.shouldSimulateError = false,
    this.shouldSimulateUpdate = false,
  });

  @override
  Future<bool> checkFleetConnectivity() async {
    await Future.delayed(delay);
    return !shouldSimulateError;
  }

  @override
  Future<bool> isUpdateRequired() async {
    await Future.delayed(delay);
    return shouldSimulateUpdate;
  }

  @override
  Future<DriverDispatchHubInfo> getHubInfo() async {
    await Future.delayed(delay);
    return const DriverDispatchHubInfo();
  }

  @override
  Future<bool> retryHubConnection() async {
    await Future.delayed(delay);
    return true;
  }
}
