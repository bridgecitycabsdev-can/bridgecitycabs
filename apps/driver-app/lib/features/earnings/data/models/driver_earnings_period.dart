enum DriverEarningsPeriod {
  today('Today', "Today's active shift", 41.77),
  thisWeek('This week', '24 Jun – 30 Jun', 53.93),
  thisMonth('This month', '1 Jun – 30 Jun', 1248.50),
  lastMonth('Last month', '1 May – 31 May', 2840.10),
  customRange('Custom date range', 'Define specific start and end day', null);

  final String label;
  final String dateSubtitle;
  final double? amount;
  const DriverEarningsPeriod(this.label, this.dateSubtitle, this.amount);
}
