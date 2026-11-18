import '../models/driver_flag_ride_config.dart';
import '../models/driver_flag_ride_model.dart';

abstract class DriverFlagRideRepository {
  Future<DriverFlagRideModel> fetchFlagRideState();
  Future<void> startFlagRide({
    required int passengerCount,
    String? destination,
  });
  Future<void> endFlagRide(String flagTripId);
  Future<void> collectCashPayment({
    required String flagTripId,
    required double amount,
  });
  Future<void> retryTelemetry(String flagTripId);
  Future<void> refreshFareCalculation(String flagTripId);
}

class FakeDriverFlagRideRepository implements DriverFlagRideRepository {
  DriverFlagRideModel _currentModel;

  FakeDriverFlagRideRepository({DriverFlagRideModel? initialModel})
      : _currentModel = initialModel ?? DriverFlagRideConfig.startFlagRidePreset;

  @override
  Future<DriverFlagRideModel> fetchFlagRideState() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentModel;
  }

  @override
  Future<void> startFlagRide({
    required int passengerCount,
    String? destination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentModel = DriverFlagRideConfig.flagInProgressPreset.copyWith(
      passengerCount: passengerCount,
      dropoffAddress: destination ?? '440 University Dr W',
    );
  }

  @override
  Future<void> endFlagRide(String flagTripId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentModel = DriverFlagRideConfig.flagCompletePreset;
  }

  @override
  Future<void> collectCashPayment({
    required String flagTripId,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentModel = _currentModel.copyWith(isCashCollected: true);
  }

  @override
  Future<void> retryTelemetry(String flagTripId) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> refreshFareCalculation(String flagTripId) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
