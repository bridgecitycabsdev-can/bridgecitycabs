import '../models/past_trip_detail_config.dart';
import '../models/past_trip_detail_model.dart';

abstract class PastTripDetailRepository {
  Future<PastTripDetailModel> getTripDetail(String tripId);
  Future<PastTripDetailModel> getTripForScenario(PastTripQaScenario scenario);
  Future<String> downloadOfficialTaxReceipt(String tripId);
  Future<bool> bookReturnTrip(PastTripDetailModel trip);
}

class PastTripDetailRepositoryImpl implements PastTripDetailRepository {
  final Duration latency;

  PastTripDetailRepositoryImpl({
    this.latency = const Duration(milliseconds: 250),
  });

  @override
  Future<PastTripDetailModel> getTripDetail(String tripId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (tripId.contains('BCC-84920')) {
      return PastTripDetailConfig.defaultTripHarpreet;
    }
    return PastTripDetailConfig.defaultTripMarcus;
  }

  @override
  Future<PastTripDetailModel> getTripForScenario(
      PastTripQaScenario scenario) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    return PastTripDetailConfig.getTripForScenario(scenario);
  }

  @override
  Future<String> downloadOfficialTaxReceipt(String tripId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    return 'Receipt-$tripId-CRA-Alberta.pdf';
  }

  @override
  Future<bool> bookReturnTrip(PastTripDetailModel trip) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    return true;
  }
}
