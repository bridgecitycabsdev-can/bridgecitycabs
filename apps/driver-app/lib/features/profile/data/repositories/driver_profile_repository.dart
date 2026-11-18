import '../models/driver_profile_config.dart';
import '../models/driver_profile_data.dart';

abstract class DriverProfileRepository {
  Future<DriverProfileData> fetchProfile();
  Future<bool> uploadCredential(String credentialId, List<int> bytes);
  Future<bool> retryOfflineSync();
}

class FakeDriverProfileRepository implements DriverProfileRepository {
  final Duration latency;

  FakeDriverProfileRepository({
    this.latency = const Duration(milliseconds: 200),
  });

  @override
  Future<DriverProfileData> fetchProfile() async {
    await Future.delayed(latency);
    return DriverProfileConfig.activeOnlinePreset();
  }

  @override
  Future<bool> uploadCredential(String credentialId, List<int> bytes) async {
    await Future.delayed(latency);
    return true;
  }

  @override
  Future<bool> retryOfflineSync() async {
    await Future.delayed(latency);
    return true;
  }
}
