import 'package:equatable/equatable.dart';
import '../data/models/driver_register_step2_data.dart';
import '../data/models/driver_register_step2_status.dart';

class DriverRegisterStep2State extends Equatable {
  final DriverRegisterStep2Status status;
  final DriverRegisterStep2Data data;
  final String? yearError;
  final String? plateError;
  final String? generalAlertMessage;
  final bool isYearPickerOpen;
  final int selectedYearInPicker;
  final String? feedbackMessage;

  const DriverRegisterStep2State({
    this.status = DriverRegisterStep2Status.initial,
    this.data = const DriverRegisterStep2Data(),
    this.yearError,
    this.plateError,
    this.generalAlertMessage,
    this.isYearPickerOpen = false,
    this.selectedYearInPicker = 2021,
    this.feedbackMessage,
  });

  bool get isFormValid => data.isFormValid;
  bool get canProceed => status == DriverRegisterStep2Status.valid;
  bool get isSubmitting => status == DriverRegisterStep2Status.submitting;

  bool get hasAnyError =>
      yearError != null || plateError != null || generalAlertMessage != null;

  DriverRegisterStep2State copyWith({
    DriverRegisterStep2Status? status,
    DriverRegisterStep2Data? data,
    String? yearError,
    String? plateError,
    String? generalAlertMessage,
    bool? isYearPickerOpen,
    int? selectedYearInPicker,
    String? feedbackMessage,
  }) {
    return DriverRegisterStep2State(
      status: status ?? this.status,
      data: data ?? this.data,
      yearError: yearError,
      plateError: plateError,
      generalAlertMessage: generalAlertMessage,
      isYearPickerOpen: isYearPickerOpen ?? this.isYearPickerOpen,
      selectedYearInPicker: selectedYearInPicker ?? this.selectedYearInPicker,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        yearError,
        plateError,
        generalAlertMessage,
        isYearPickerOpen,
        selectedYearInPicker,
        feedbackMessage,
      ];
}
