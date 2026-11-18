enum DriverReviewFilterStar {
  all,
  star5,
  star4,
  star3,
  star2,
  star1,
}

extension DriverReviewFilterStarX on DriverReviewFilterStar {
  int? get starValue {
    switch (this) {
      case DriverReviewFilterStar.all:
        return null;
      case DriverReviewFilterStar.star5:
        return 5;
      case DriverReviewFilterStar.star4:
        return 4;
      case DriverReviewFilterStar.star3:
        return 3;
      case DriverReviewFilterStar.star2:
        return 2;
      case DriverReviewFilterStar.star1:
        return 1;
    }
  }

  String label(int count) {
    switch (this) {
      case DriverReviewFilterStar.all:
        return 'All ($count)';
      case DriverReviewFilterStar.star5:
        return '5 ★ ($count)';
      case DriverReviewFilterStar.star4:
        return '4 ★ ($count)';
      case DriverReviewFilterStar.star3:
        return '3 ★ ($count)';
      case DriverReviewFilterStar.star2:
        return '2 ★ ($count)';
      case DriverReviewFilterStar.star1:
        return '1 ★ ($count)';
    }
  }
}
