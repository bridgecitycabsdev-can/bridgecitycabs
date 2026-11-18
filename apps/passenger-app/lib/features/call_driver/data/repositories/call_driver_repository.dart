import '../models/call_driver_model.dart';

abstract class CallDriverRepository {
  Future<DriverCallDetails> getDriverDetails(String tripId);
  Future<bool> initiateMaskedCall({
    required String tripId,
    required String driverId,
  });
  Future<void> endCall();
}

class MockCallDriverRepository implements CallDriverRepository {
  @override
  Future<DriverCallDetails> getDriverDetails(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return DriverCallDetails.defaultMichael;
  }

  @override
  Future<bool> initiateMaskedCall({
    required String tripId,
    required String driverId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 80));
    return true;
  }

  @override
  Future<void> endCall() async {
    await Future.delayed(const Duration(milliseconds: 40));
  }
}
