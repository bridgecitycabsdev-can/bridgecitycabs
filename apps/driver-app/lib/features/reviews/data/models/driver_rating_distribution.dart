import 'package:equatable/equatable.dart';
import 'driver_review_filter_star.dart';

class DriverRatingDistribution extends Equatable {
  final double overallRating;
  final int totalReviews;
  final int star5Count;
  final int star4Count;
  final int star3Count;
  final int star2Count;
  final int star1Count;

  const DriverRatingDistribution({
    this.overallRating = 4.8,
    this.totalReviews = 120,
    this.star5Count = 98,
    this.star4Count = 14,
    this.star3Count = 5,
    this.star2Count = 2,
    this.star1Count = 1,
  });

  int getCountForFilter(DriverReviewFilterStar filter) {
    switch (filter) {
      case DriverReviewFilterStar.all:
        return totalReviews;
      case DriverReviewFilterStar.star5:
        return star5Count;
      case DriverReviewFilterStar.star4:
        return star4Count;
      case DriverReviewFilterStar.star3:
        return star3Count;
      case DriverReviewFilterStar.star2:
        return star2Count;
      case DriverReviewFilterStar.star1:
        return star1Count;
    }
  }

  DriverRatingDistribution copyWith({
    double? overallRating,
    int? totalReviews,
    int? star5Count,
    int? star4Count,
    int? star3Count,
    int? star2Count,
    int? star1Count,
  }) {
    return DriverRatingDistribution(
      overallRating: overallRating ?? this.overallRating,
      totalReviews: totalReviews ?? this.totalReviews,
      star5Count: star5Count ?? this.star5Count,
      star4Count: star4Count ?? this.star4Count,
      star3Count: star3Count ?? this.star3Count,
      star2Count: star2Count ?? this.star2Count,
      star1Count: star1Count ?? this.star1Count,
    );
  }

  @override
  List<Object?> get props => [
    overallRating,
    totalReviews,
    star5Count,
    star4Count,
    star3Count,
    star2Count,
    star1Count,
  ];
}
