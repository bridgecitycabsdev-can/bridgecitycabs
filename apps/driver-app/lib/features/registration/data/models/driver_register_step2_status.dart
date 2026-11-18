enum DriverRegisterStep2Status {
  initial, // Unselected vehicle type, empty make/model/year/colour, disabled Next button
  valid, // Complete with Medium, 2021 Toyota Camry Hybrid, BCC-9482 plate, active red button
  invalid, // Year too old (2008 < 2014), incomplete plate (ABC), alert banner
  yearPickerModal, // "Select Vehicle year" bottom sheet modal open with 2014+ minimum rule
  submitting, // Spinner on button "Saving vehicle..."
  success, // Step 2 complete, navigate to Step 3 (Driver documents)
}

extension DriverRegisterStep2StatusX on DriverRegisterStep2Status {
  bool get isInitial => this == DriverRegisterStep2Status.initial;
  bool get isValid => this == DriverRegisterStep2Status.valid;
  bool get isInvalid => this == DriverRegisterStep2Status.invalid;
  bool get isYearPickerModal =>
      this == DriverRegisterStep2Status.yearPickerModal;
  bool get isSubmitting => this == DriverRegisterStep2Status.submitting;
  bool get isSuccess => this == DriverRegisterStep2Status.success;

  bool get canProceed => this == DriverRegisterStep2Status.valid;
}
