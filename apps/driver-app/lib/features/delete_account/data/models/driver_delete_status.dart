enum DriverDeleteStatus {
  checklistReady,
  safeguardsBlocked,
  deletionRequested,
  recoveryBanner,
  emergencyModal;

  String get label {
    switch (this) {
      case DriverDeleteStatus.checklistReady:
        return '1. Checklist';
      case DriverDeleteStatus.safeguardsBlocked:
        return '2. Safeguards';
      case DriverDeleteStatus.deletionRequested:
        return '3. Requested';
      case DriverDeleteStatus.recoveryBanner:
        return '4. Recovery';
      case DriverDeleteStatus.emergencyModal:
        return '5. SOS Modal';
    }
  }

  bool get isChecklistReady => this == DriverDeleteStatus.checklistReady;
  bool get isSafeguardsBlocked => this == DriverDeleteStatus.safeguardsBlocked;
  bool get isDeletionRequested => this == DriverDeleteStatus.deletionRequested;
  bool get isRecoveryBanner => this == DriverDeleteStatus.recoveryBanner;
  bool get isEmergencyModal => this == DriverDeleteStatus.emergencyModal;
}
