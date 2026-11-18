enum DriverRegisterStep4Status {
  approved,
  reviewing,
  actionRequired,
  rejected,
  offline;

  bool get isApproved => this == DriverRegisterStep4Status.approved;
  bool get isReviewing => this == DriverRegisterStep4Status.reviewing;
  bool get isActionRequired => this == DriverRegisterStep4Status.actionRequired;
  bool get isRejected => this == DriverRegisterStep4Status.rejected;
  bool get isOffline => this == DriverRegisterStep4Status.offline;
}
