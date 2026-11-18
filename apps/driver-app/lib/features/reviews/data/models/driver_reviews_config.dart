import 'driver_rating_distribution.dart';
import 'driver_review_item.dart';

class DriverReviewsConfig {
  static const DriverRatingDistribution defaultDistribution =
      DriverRatingDistribution(
    overallRating: 4.8,
    totalReviews: 120,
    star5Count: 98,
    star4Count: 14,
    star3Count: 5,
    star2Count: 2,
    star1Count: 1,
  );

  static List<DriverReviewItem> listPresetReviews() {
    return const [
      DriverReviewItem(
        id: 'REV-88421',
        tripId: 'BC-123456',
        passengerName: 'Marcus T.',
        dateFormatted: '18 Jul 2026',
        rating: 5,
        comment:
            'Fantastic driver! Clean car, arrived right on time, and knew the best route through Lethbridge during peak traffic.',
      ),
      DriverReviewItem(
        id: 'REV-88422',
        tripId: 'BC-123457',
        passengerName: 'Sarah K.',
        dateFormatted: '15 Jul 2026',
        rating: 5,
        comment:
            'Very polite and smooth ride. Helped with luggage at the airport terminal.',
      ),
      DriverReviewItem(
        id: 'REV-88423',
        tripId: 'BC-123458',
        passengerName: 'David L.',
        dateFormatted: '11 Jul 2026',
        rating: 4,
        comment: '',
      ),
      DriverReviewItem(
        id: 'REV-88424',
        tripId: 'BC-123459',
        passengerName: 'Anonymous Passenger',
        dateFormatted: '03 Jul 2026',
        rating: 2,
        isLowRating: true,
        comment:
            'Driver took a slightly longer route via 6th Ave instead of Mayor Magrath Dr.',
      ),
    ];
  }

  static List<DriverReviewItem> feedScrollPresetReviews() {
    return const [
      DriverReviewItem(
        id: 'REV-99101',
        tripId: 'BC-776101',
        passengerName: 'Sarah M.',
        dateFormatted: 'Yesterday',
        pickupLocation: 'University Dr West',
        rating: 5,
        comment:
            'Super smooth drive across Whoop-Up Drive during rush hour. Car was impeccably clean and warm on a freezing evening!',
        tags: ['Smooth Driving', 'Punctual Pickup', '+\$4.00 Tip'],
      ),
      DriverReviewItem(
        id: 'REV-99102',
        tripId: 'BC-776102',
        passengerName: 'Liam K.',
        dateFormatted: '3 days ago',
        pickupLocation: 'Park Place Mall',
        rating: 5,
        comment:
            'Helped with my heavy grocery bags and took the quickest route avoiding the train crossing. Bridge City drivers are the best.',
        tags: ['Great Route', 'Luggage Help'],
      ),
    ];
  }

  static DriverReviewItem singleDetailReview() {
    return const DriverReviewItem(
      id: 'REV-88421',
      tripId: 'BC-123456',
      passengerName: 'Marcus T.',
      dateFormatted: '18 Jul 2026',
      rating: 5,
      tripRouteSummary: '4.52 km • ⏱ 14 mins • 🚘 Sedan Medium',
      comment:
          'Fantastic driver! Clean car, arrived right on time, and knew the best route through Lethbridge during peak traffic. Appreciated the smooth driving and polite greeting.',
    );
  }
}
