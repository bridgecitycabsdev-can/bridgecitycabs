import '../models/driver_routing_pathway.dart';

abstract class DriverOtpRepository {
  Future<bool> verifyOtp({required String phone, required String code});
  Future<DriverRoutingPathwayType> resolveDriverPathway({required String phone});
  Future<bool> resendOtp({required String phone});
}

class MockDriverOtpRepository implements DriverOtpRepository {
  @override
  Future<bool> verifyOtp({required String phone, required String code}) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulation triggers based on screenshot examples:
    if (code == '519482') {
      return false; // Triggers incorrect code state
    }
    if (code == '409153') {
      return false; // Triggers expired code state
    }
    return true;
  }

  @override
  Future<DriverRoutingPathwayType> resolveDriverPathway({
    required String phone,
  }) async {
    if (phone.endsWith('17')) {
      return DriverRoutingPathwayType.approvedDriver;
    }
    return DriverRoutingPathwayType.approvedDriver;
  }

  @override
  Future<bool> resendOtp({required String phone}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}
