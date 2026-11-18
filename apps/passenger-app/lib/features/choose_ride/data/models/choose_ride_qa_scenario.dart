enum QaPromoScenario {
  invalidCode,
  expired,
  usageLimit,
  minFare,
  validApplied,
  stackingBlocked,
  geofenceError;

  String get chipLabel {
    switch (this) {
      case QaPromoScenario.invalidCode:
        return '1. Invalid Code';
      case QaPromoScenario.expired:
        return '2. Expired';
      case QaPromoScenario.usageLimit:
        return '3. Usage Limit';
      case QaPromoScenario.minFare:
        return '4. Min Fare';
      case QaPromoScenario.validApplied:
        return '5. Valid Applied';
      case QaPromoScenario.stackingBlocked:
        return '6. Stacking Blocked';
      case QaPromoScenario.geofenceError:
        return '7. Geofence Error';
    }
  }

  String get defaultCouponCode {
    switch (this) {
      case QaPromoScenario.invalidCode:
        return 'WINTER50';
      case QaPromoScenario.expired:
        return 'SUMMER24';
      case QaPromoScenario.usageLimit:
        return 'FIRST50';
      case QaPromoScenario.minFare:
        return 'RIDE20';
      case QaPromoScenario.validApplied:
        return 'WELCOME5';
      case QaPromoScenario.stackingBlocked:
        return 'EXTRA5';
      case QaPromoScenario.geofenceError:
        return 'OUTZONE';
    }
  }

  String get errorMessage {
    switch (this) {
      case QaPromoScenario.invalidCode:
        return "This promo code isn't valid.\nCheck for typos or contact Bridge City support.";
      case QaPromoScenario.expired:
        return 'This promo code expired on Oct 15, 2026.\nCheck current promotions.';
      case QaPromoScenario.usageLimit:
        return 'You have reached the maximum redemption limit for this code.';
      case QaPromoScenario.minFare:
        return 'Minimum trip fare of \$12.00 CAD required to use this discount.';
      case QaPromoScenario.validApplied:
        return '';
      case QaPromoScenario.stackingBlocked:
        return 'Cannot be combined with another promotional discount.';
      case QaPromoScenario.geofenceError:
        return 'Promotion only valid for pickups within West Lethbridge corridor.';
    }
  }

  bool get isValid => this == QaPromoScenario.validApplied;
}

enum ChooseRideDemoState {
  collapsed,
  expanded,
  applying;

  String get chipLabel {
    switch (this) {
      case ChooseRideDemoState.collapsed:
        return '1. Collapsed';
      case ChooseRideDemoState.expanded:
        return '2. Expanded';
      case ChooseRideDemoState.applying:
        return '3. Applying';
    }
  }
}
