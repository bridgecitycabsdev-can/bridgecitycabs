enum DriverTripFilterPeriod {
  today,
  thisWeek,
  thisMonth,
  lastMonth,
  customRange,
}

extension DriverTripFilterPeriodX on DriverTripFilterPeriod {
  String get label {
    switch (this) {
      case DriverTripFilterPeriod.today:
        return 'Today';
      case DriverTripFilterPeriod.thisWeek:
        return 'This week';
      case DriverTripFilterPeriod.thisMonth:
        return 'This month';
      case DriverTripFilterPeriod.lastMonth:
        return 'Last month';
      case DriverTripFilterPeriod.customRange:
        return 'Custom date range';
    }
  }

  String get subtitle {
    switch (this) {
      case DriverTripFilterPeriod.today:
        return "Today's active shift • \$41.77";
      case DriverTripFilterPeriod.thisWeek:
        return '24 Jun – 30 Jun • \$53.93';
      case DriverTripFilterPeriod.thisMonth:
        return '1 Jun – 30 Jun • \$1,248.50';
      case DriverTripFilterPeriod.lastMonth:
        return '1 May – 31 May • \$2,840.10';
      case DriverTripFilterPeriod.customRange:
        return 'Define specific start and end day';
    }
  }
}
