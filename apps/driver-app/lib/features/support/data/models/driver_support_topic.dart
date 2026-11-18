enum DriverSupportTopic {
  paymentStatement,
  documentApproval,
  rideIssue,
  passengerIssue,
  safety,
  appIssue,
  other;

  String get label {
    switch (this) {
      case DriverSupportTopic.paymentStatement:
        return 'Payment or statement';
      case DriverSupportTopic.documentApproval:
        return 'Document or approval';
      case DriverSupportTopic.rideIssue:
        return 'Ride issue';
      case DriverSupportTopic.passengerIssue:
        return 'Passenger issue';
      case DriverSupportTopic.safety:
        return 'Safety';
      case DriverSupportTopic.appIssue:
        return 'App issue';
      case DriverSupportTopic.other:
        return 'Other';
    }
  }

  String get iconEmoji {
    switch (this) {
      case DriverSupportTopic.rideIssue:
        return '🚗';
      case DriverSupportTopic.documentApproval:
        return '🛡️';
      case DriverSupportTopic.appIssue:
        return '📱';
      case DriverSupportTopic.paymentStatement:
        return '💳';
      case DriverSupportTopic.passengerIssue:
        return '👤';
      case DriverSupportTopic.safety:
        return '🚨';
      case DriverSupportTopic.other:
        return '💬';
    }
  }
}
