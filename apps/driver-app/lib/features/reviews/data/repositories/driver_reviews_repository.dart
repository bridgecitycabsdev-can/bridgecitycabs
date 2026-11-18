import '../models/driver_rating_distribution.dart';
import '../models/driver_review_item.dart';
import '../models/driver_reviews_config.dart';

abstract class DriverReviewsRepository {
  Future<DriverRatingDistribution> fetchDistribution();

  Future<List<DriverReviewItem>> fetchReviews({
    int? starRating,
    int page = 1,
  });

  Future<void> reportReview(String reviewId, String reason);

  Future<void> retryReviewsSync();
}

class FakeDriverReviewsRepository implements DriverReviewsRepository {
  final Duration latency;

  FakeDriverReviewsRepository({
    this.latency = const Duration(milliseconds: 100),
  });

  @override
  Future<DriverRatingDistribution> fetchDistribution() async {
    await Future.delayed(latency);
    return DriverReviewsConfig.defaultDistribution;
  }

  @override
  Future<List<DriverReviewItem>> fetchReviews({
    int? starRating,
    int page = 1,
  }) async {
    await Future.delayed(latency);
    if (starRating == 1) {
      // Simulate no matching filter results for 1 star
      return [];
    }

    final all = DriverReviewsConfig.listPresetReviews();
    if (starRating != null) {
      return all.where((r) => r.rating == starRating).toList();
    }
    return all;
  }

  @override
  Future<void> reportReview(String reviewId, String reason) async {
    await Future.delayed(latency);
  }

  @override
  Future<void> retryReviewsSync() async {
    await Future.delayed(latency);
  }
}
