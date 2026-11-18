import 'rate_driver_models.dart';

class RateDriverConfig {
  static const List<RatingTag> negativeTags = [
    RatingTag(id: 'unsafe', label: 'Unsafe driving', isNegative: true),
    RatingTag(id: 'late', label: 'Late pickup', isNegative: true),
    RatingTag(id: 'rude', label: 'Rude', isNegative: true),
    RatingTag(id: 'dirty', label: 'Dirty car', isNegative: true),
    RatingTag(id: 'wrong_route', label: 'Wrong route', isNegative: true),
  ];

  static const List<RatingTag> positiveTags = [
    RatingTag(id: 'great_driving', label: 'Great driving', isNegative: false),
    RatingTag(id: 'clean_car', label: 'Clean car', isNegative: false),
    RatingTag(id: 'friendly', label: 'Friendly', isNegative: false),
    RatingTag(id: 'on_time', label: 'On time', isNegative: false),
    RatingTag(id: 'quick_route', label: 'Quick route', isNegative: false),
    RatingTag(id: 'conversation', label: 'Great conversation', isNegative: false),
  ];

  static String getSentimentLabel(int stars) {
    switch (stars) {
      case 1:
        return 'POOR';
      case 2:
        return 'FAIR';
      case 3:
        return 'GOOD';
      case 4:
        return 'GREAT!';
      case 5:
        return '🔥 Excellent!';
      default:
        return 'Tap a star to rate';
    }
  }

  static RatingSentiment getSentiment(int stars) {
    switch (stars) {
      case 1:
        return RatingSentiment.poor;
      case 2:
        return RatingSentiment.fair;
      case 3:
        return RatingSentiment.good;
      case 4:
        return RatingSentiment.great;
      case 5:
        return RatingSentiment.excellent;
      default:
        return RatingSentiment.unrated;
    }
  }

  static const String bridgeCityGuaranteeText =
      'Trip fare under automatic review for route discrepancies.';

  static const String alreadyRatedNotice =
      "You've already rated this trip.\nEach ride can only be rated once to preserve driver evaluation integrity.";

  static const String expiredNotice =
      'The rating window for this trip has closed.\nRatings must be submitted within 48 hours of trip completion.';

  static const String successFeedbackSubtitle =
      'Your review for Michael has been recorded. Ratings help keep Bridge City Cabs safe, reliable, and friendly across Lethbridge.';

  static const String highFiveTitle = 'High Five for Southern Alberta!';
  static const String highFiveSubtitle =
      "Tip & feedback forwarded to Michael's driver dashboard.";
}
