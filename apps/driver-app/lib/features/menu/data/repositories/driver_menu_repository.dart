import '../models/driver_menu_config.dart';
import '../models/driver_menu_profile.dart';
import '../models/driver_menu_stats.dart';

abstract class DriverMenuRepository {
  Future<DriverMenuProfile> fetchProfile();
  Future<DriverMenuStats> fetchDailyStats();
  Future<bool> logoutDriver();
  Future<void> flagCurrentRide({required String reason});
}

class FakeDriverMenuRepository implements DriverMenuRepository {
  final Duration latency;

  FakeDriverMenuRepository({
    this.latency = const Duration(milliseconds: 250),
  });

  @override
  Future<DriverMenuProfile> fetchProfile() async {
    await Future.delayed(latency);
    return DriverMenuConfig.defaultProfile();
  }

  @override
  Future<DriverMenuStats> fetchDailyStats() async {
    await Future.delayed(latency);
    return DriverMenuConfig.onlineStats();
  }

  @override
  Future<bool> logoutDriver() async {
    await Future.delayed(latency);
    return true;
  }

  @override
  Future<void> flagCurrentRide({required String reason}) async {
    await Future.delayed(latency);
  }
}
