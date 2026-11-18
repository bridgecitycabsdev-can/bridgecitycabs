enum DriverReviewsStatus {
  list,
  detailModal,
  edgeStatesGallery,
  noMatchingFilter,
  newDriverEmpty,
  serviceFailure,
}

extension DriverReviewsStatusX on DriverReviewsStatus {
  String get label {
    switch (this) {
      case DriverReviewsStatus.list:
        return '1. Reviews List';
      case DriverReviewsStatus.detailModal:
        return '2. Review Detail & Report';
      case DriverReviewsStatus.edgeStatesGallery:
        return '3. Edge States Gallery';
      case DriverReviewsStatus.noMatchingFilter:
        return '4. 1★ No Filter Matches';
      case DriverReviewsStatus.newDriverEmpty:
        return '5. New Driver (Zero Reviews)';
      case DriverReviewsStatus.serviceFailure:
        return '6. 504 Gateway Failure';
    }
  }
}
