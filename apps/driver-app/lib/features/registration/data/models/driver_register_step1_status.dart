enum DriverRegisterStep1Status {
  initial, // Empty form with placeholder avatar, "REQUIRED" tag, disabled Next Step button
  valid, // Complete form with headshot, "25%" tag, active "Next: Vehicle details ➔" button
  invalid, // Inline field validation errors, missing photo error, bottom warning banner
  photoModal, // "Add profile photo" bottom sheet modal open with guidelines & actions
  submitting, // Spinner on button "Saving details..."
  success, // Step 1 complete, transition to Step 2 (Vehicle details)
}

extension DriverRegisterStep1StatusX on DriverRegisterStep1Status {
  bool get isInitial => this == DriverRegisterStep1Status.initial;
  bool get isValid => this == DriverRegisterStep1Status.valid;
  bool get isInvalid => this == DriverRegisterStep1Status.invalid;
  bool get isPhotoModal => this == DriverRegisterStep1Status.photoModal;
  bool get isSubmitting => this == DriverRegisterStep1Status.submitting;
  bool get isSuccess => this == DriverRegisterStep1Status.success;

  bool get canProceed => this == DriverRegisterStep1Status.valid;
}
