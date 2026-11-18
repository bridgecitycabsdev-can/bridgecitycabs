import 'package:equatable/equatable.dart';
import '../data/models/driver_document_type.dart';
import '../data/models/driver_register_step3_data.dart';
import '../data/models/driver_register_step3_status.dart';

class DriverRegisterStep3State extends Equatable {
  final DriverRegisterStep3Status status;
  final DriverRegisterStep3Data data;
  final bool isUploadModalOpen;
  final DriverDocumentType? selectedDocumentForModal;
  final String? actionRequiredMessage;
  final String? actionRequiredDetails;
  final String? feedbackMessage;

  const DriverRegisterStep3State({
    this.status = DriverRegisterStep3Status.initial,
    this.data = const DriverRegisterStep3Data(),
    this.isUploadModalOpen = false,
    this.selectedDocumentForModal,
    this.actionRequiredMessage,
    this.actionRequiredDetails,
    this.feedbackMessage,
  });

  bool get canSubmit =>
      status == DriverRegisterStep3Status.ready &&
      data.areAllRequiredUploaded &&
      !data.hasAnyUploading;

  bool get isSubmitting => status == DriverRegisterStep3Status.submitting;

  bool get isActionRequired =>
      status == DriverRegisterStep3Status.actionRequired;

  int get verifiedRatioNumerator => data.uploadedRequiredCount;
  int get verifiedRatioDenominator => data.requiredDocumentsCount;

  DriverRegisterStep3State copyWith({
    DriverRegisterStep3Status? status,
    DriverRegisterStep3Data? data,
    bool? isUploadModalOpen,
    DriverDocumentType? selectedDocumentForModal,
    String? actionRequiredMessage,
    String? actionRequiredDetails,
    String? feedbackMessage,
  }) {
    return DriverRegisterStep3State(
      status: status ?? this.status,
      data: data ?? this.data,
      isUploadModalOpen: isUploadModalOpen ?? this.isUploadModalOpen,
      selectedDocumentForModal:
          selectedDocumentForModal ?? this.selectedDocumentForModal,
      actionRequiredMessage:
          actionRequiredMessage ?? this.actionRequiredMessage,
      actionRequiredDetails:
          actionRequiredDetails ?? this.actionRequiredDetails,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        isUploadModalOpen,
        selectedDocumentForModal,
        actionRequiredMessage,
        actionRequiredDetails,
        feedbackMessage,
      ];
}
