import 'package:equatable/equatable.dart';
import '../data/models/driver_register_step1_data.dart';
import '../data/models/driver_register_step1_status.dart';

class DriverRegisterStep1State extends Equatable {
  final DriverRegisterStep1Status status;
  final DriverRegisterStep1Data data;
  final String? photoError;
  final String? emailError;
  final String? licenceError;
  final String? postalCodeError;
  final String? generalAlertMessage;
  final bool isPhotoModalOpen;
  final String? feedbackMessage;

  const DriverRegisterStep1State({
    this.status = DriverRegisterStep1Status.initial,
    this.data = const DriverRegisterStep1Data(),
    this.photoError,
    this.emailError,
    this.licenceError,
    this.postalCodeError,
    this.generalAlertMessage,
    this.isPhotoModalOpen = false,
    this.feedbackMessage,
  });

  bool get isFormValid => data.isFormValid;
  bool get canProceed => status == DriverRegisterStep1Status.valid;
  bool get isSubmitting => status == DriverRegisterStep1Status.submitting;

  bool get hasAnyError =>
      photoError != null ||
      emailError != null ||
      licenceError != null ||
      postalCodeError != null ||
      generalAlertMessage != null;

  DriverRegisterStep1State copyWith({
    DriverRegisterStep1Status? status,
    DriverRegisterStep1Data? data,
    String? photoError,
    String? emailError,
    String? licenceError,
    String? postalCodeError,
    String? generalAlertMessage,
    bool? isPhotoModalOpen,
    String? feedbackMessage,
  }) {
    return DriverRegisterStep1State(
      status: status ?? this.status,
      data: data ?? this.data,
      photoError: photoError,
      emailError: emailError,
      licenceError: licenceError,
      postalCodeError: postalCodeError,
      generalAlertMessage: generalAlertMessage,
      isPhotoModalOpen: isPhotoModalOpen ?? this.isPhotoModalOpen,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        photoError,
        emailError,
        licenceError,
        postalCodeError,
        generalAlertMessage,
        isPhotoModalOpen,
        feedbackMessage,
      ];
}
