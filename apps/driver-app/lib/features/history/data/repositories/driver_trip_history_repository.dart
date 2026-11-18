import '../models/driver_trip_filter_period.dart';
import '../models/driver_trip_history_config.dart';
import '../models/driver_trip_record.dart';

abstract class DriverTripHistoryRepository {
  Future<List<DriverTripRecord>> fetchTrips({
    DriverTripFilterPeriod period = DriverTripFilterPeriod.thisWeek,
    String? startDate,
    String? endDate,
  });

  Future<DriverTripRecord> fetchTripDetail(String tripId);

  Future<void> retryOfflineSync();

  Future<void> reportTripIssue(String tripId, String reason);
}

class FakeDriverTripHistoryRepository implements DriverTripHistoryRepository {
  final Duration latency;

  FakeDriverTripHistoryRepository({
    this.latency = const Duration(milliseconds: 100),
  });

  @override
  Future<List<DriverTripRecord>> fetchTrips({
    DriverTripFilterPeriod period = DriverTripFilterPeriod.thisWeek,
    String? startDate,
    String? endDate,
  }) async {
    await Future.delayed(latency);
    if (period == DriverTripFilterPeriod.lastMonth) {
      // simulate filtered empty notice if requested
      return [];
    }
    return [
      DriverTripHistoryConfig.sampleCompletedTrip(),
      DriverTripHistoryConfig.sampleCancelledTrip(),
    ];
  }

  @override
  Future<DriverTripRecord> fetchTripDetail(String tripId) async {
    await Future.delayed(latency);
    if (tripId == 'BC-987654') {
      return DriverTripHistoryConfig.sampleCancelledTrip();
    }
    return DriverTripHistoryConfig.sampleCompletedTrip();
  }

  @override
  Future<void> retryOfflineSync() async {
    await Future.delayed(latency);
  }

  @override
  Future<void> reportTripIssue(String tripId, String reason) async {
    await Future.delayed(latency);
  }
}
