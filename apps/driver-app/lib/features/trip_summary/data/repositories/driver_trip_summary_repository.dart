import '../models/driver_rate_passenger_model.dart';
import '../models/driver_trip_summary_config.dart';
import '../models/driver_trip_summary_model.dart';

abstract class DriverTripSummaryRepository {
  Future<DriverTripSummaryModel> fetchSummary({
    String? tripId,
    String? paymentMethod,
  });
  Future<void> collectCash({
    required String tripId,
    required double amount,
  });
  Future<void> submitPassengerRating({
    required String tripId,
    required DriverRatePassengerModel rating,
  });
  Future<void> retryPaymentSync({required String tripId});
}

class FakeDriverTripSummaryRepository implements DriverTripSummaryRepository {
  DriverTripSummaryModel _currentSummary;

  FakeDriverTripSummaryRepository({DriverTripSummaryModel? initialSummary})
      : _currentSummary =
            initialSummary ?? DriverTripSummaryConfig.cardSummaryPreset;

  @override
  Future<DriverTripSummaryModel> fetchSummary({
    String? tripId,
    String? paymentMethod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (paymentMethod?.toUpperCase() == 'CASH') {
      return DriverTripSummaryConfig.cashSummaryPreset;
    }
    return _currentSummary;
  }

  @override
  Future<void> collectCash({
    required String tripId,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentSummary = _currentSummary.copyWith(
      isCashCollected: true,
      isPaid: true,
    );
  }

  @override
  Future<void> submitPassengerRating({
    required String tripId,
    required DriverRatePassengerModel rating,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentSummary = _currentSummary.copyWith(
      ratingModel: rating.copyWith(isSubmitted: true),
    );
  }

  @override
  Future<void> retryPaymentSync({required String tripId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
