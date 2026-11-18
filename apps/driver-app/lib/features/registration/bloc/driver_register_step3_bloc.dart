import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_document_item.dart';
import '../data/models/driver_document_type.dart';
import '../data/models/driver_register_config.dart';
import '../data/models/driver_register_step3_data.dart';
import '../data/models/driver_register_step3_status.dart';
import '../data/repositories/driver_register_repository.dart';
import 'driver_register_step3_event.dart';
import 'driver_register_step3_state.dart';

class DriverRegisterStep3Bloc
    extends Bloc<DriverRegisterStep3Event, DriverRegisterStep3State> {
  final DriverRegisterRepository repository;

  DriverRegisterStep3Bloc({DriverRegisterRepository? repository})
      : repository = repository ?? MockDriverRegisterRepository(),
        super(const DriverRegisterStep3State()) {
    on<DriverRegisterStep3Started>(_onStarted);
    on<DriverRegisterUploadModalOpened>(_onUploadModalOpened);
    on<DriverRegisterUploadModalDismissed>(_onUploadModalDismissed);
    on<DriverRegisterDocumentUploadRequested>(_onDocumentUploadRequested);
    on<DriverRegisterDocumentUploadProgressed>(_onDocumentUploadProgressed);
    on<DriverRegisterDocumentDeleted>(_onDocumentDeleted);
    on<DriverRegisterDocumentRetakeRequested>(_onDocumentRetakeRequested);
    on<DriverRegisterStep3Submitted>(_onSubmitted);
    on<DriverRegisterStep3StateSwitched>(_onStateSwitched);
  }

  void _onStarted(
    DriverRegisterStep3Started event,
    Emitter<DriverRegisterStep3State> emit,
  ) {
    if (event.initialStatus != DriverRegisterStep3Status.initial) {
      add(DriverRegisterStep3StateSwitched(event.initialStatus));
      return;
    }

    final initialDocs = {
      for (final type in DriverDocumentType.values)
        type: DriverDocumentItem(type: type),
    };

    emit(state.copyWith(
      status: DriverRegisterStep3Status.initial,
      data: DriverRegisterStep3Data(documents: initialDocs),
      isUploadModalOpen: false,
      selectedDocumentForModal: null,
      actionRequiredMessage: null,
      actionRequiredDetails: null,
    ));
  }

  void _onUploadModalOpened(
    DriverRegisterUploadModalOpened event,
    Emitter<DriverRegisterStep3State> emit,
  ) {
    emit(state.copyWith(
      isUploadModalOpen: true,
      selectedDocumentForModal: event.documentType,
      status: DriverRegisterStep3Status.uploadModal,
    ));
  }

  void _onUploadModalDismissed(
    DriverRegisterUploadModalDismissed event,
    Emitter<DriverRegisterStep3State> emit,
  ) {
    final newStatus = state.data.areAllRequiredUploaded
        ? DriverRegisterStep3Status.ready
        : (state.data.hasAnyNeedsRetake
            ? DriverRegisterStep3Status.actionRequired
            : (state.data.hasAnyUploading
                ? DriverRegisterStep3Status.uploading
                : DriverRegisterStep3Status.initial));

    emit(state.copyWith(
      isUploadModalOpen: false,
      selectedDocumentForModal: null,
      status: newStatus,
    ));
  }

  Future<void> _onDocumentUploadRequested(
    DriverRegisterDocumentUploadRequested event,
    Emitter<DriverRegisterStep3State> emit,
  ) async {
    final currentDocs =
        Map<DriverDocumentType, DriverDocumentItem>.from(state.data.documents);

    // Set to uploading state
    currentDocs[event.documentType] = DriverDocumentItem(
      type: event.documentType,
      status: DocumentUploadStatus.uploading,
      fileName: 'uploading_document...',
      uploadProgress: 0.25,
    );

    emit(state.copyWith(
      isUploadModalOpen: false,
      status: DriverRegisterStep3Status.uploading,
      data: state.data.copyWith(documents: currentDocs),
    ));

    // Simulate upload progression
    final uploadedItem = await repository.uploadDocument(
      type: event.documentType,
      source: event.source,
    );

    final updatedDocs =
        Map<DriverDocumentType, DriverDocumentItem>.from(state.data.documents);
    updatedDocs[event.documentType] = uploadedItem;

    final updatedData = state.data.copyWith(documents: updatedDocs);
    final isReady = updatedData.areAllRequiredUploaded &&
        !updatedData.hasAnyUploading &&
        !updatedData.hasAnyNeedsRetake;

    emit(state.copyWith(
      status: isReady
          ? DriverRegisterStep3Status.ready
          : (updatedData.hasAnyUploading
              ? DriverRegisterStep3Status.uploading
              : DriverRegisterStep3Status.initial),
      data: updatedData,
      feedbackMessage: '${event.documentType.title} uploaded successfully!',
    ));
  }

  void _onDocumentUploadProgressed(
    DriverRegisterDocumentUploadProgressed event,
    Emitter<DriverRegisterStep3State> emit,
  ) {
    final currentDocs =
        Map<DriverDocumentType, DriverDocumentItem>.from(state.data.documents);
    final existing = currentDocs[event.documentType];
    if (existing != null) {
      currentDocs[event.documentType] =
          existing.copyWith(uploadProgress: event.progress);
      emit(state.copyWith(data: state.data.copyWith(documents: currentDocs)));
    }
  }

  void _onDocumentDeleted(
    DriverRegisterDocumentDeleted event,
    Emitter<DriverRegisterStep3State> emit,
  ) {
    final currentDocs =
        Map<DriverDocumentType, DriverDocumentItem>.from(state.data.documents);
    currentDocs[event.documentType] =
        DriverDocumentItem(type: event.documentType);

    final updatedData = state.data.copyWith(documents: currentDocs);
    emit(state.copyWith(
      status: DriverRegisterStep3Status.initial,
      data: updatedData,
      feedbackMessage: '${event.documentType.title} removed',
    ));
  }

  void _onDocumentRetakeRequested(
    DriverRegisterDocumentRetakeRequested event,
    Emitter<DriverRegisterStep3State> emit,
  ) {
    emit(state.copyWith(
      isUploadModalOpen: true,
      selectedDocumentForModal: event.documentType,
      status: DriverRegisterStep3Status.uploadModal,
    ));
  }

  Future<void> _onSubmitted(
    DriverRegisterStep3Submitted event,
    Emitter<DriverRegisterStep3State> emit,
  ) async {
    if (!state.data.areAllRequiredUploaded || state.data.hasAnyNeedsRetake) {
      emit(state.copyWith(
        status: DriverRegisterStep3Status.actionRequired,
        actionRequiredMessage:
            DriverRegisterConfig.step3LicenceNeedsReuploadTitle,
        actionRequiredDetails:
            DriverRegisterConfig.step3LicenceNeedsReuploadDesc,
      ));
      return;
    }

    // Set locked and submitting
    final lockedDocs = <DriverDocumentType, DriverDocumentItem>{};
    for (final entry in state.data.documents.entries) {
      lockedDocs[entry.key] = entry.value.copyWith(isLocked: true);
    }

    emit(state.copyWith(
      status: DriverRegisterStep3Status.submitting,
      data: state.data.copyWith(
        documents: lockedDocs,
        transmissionPercentage: 98,
      ),
    ));

    final success = await repository.submitStep3Documents(state.data);
    if (success) {
      emit(state.copyWith(
        status: DriverRegisterStep3Status.success,
        feedbackMessage:
            'Documents submitted for compliance review! Proceeding to Step 4...',
      ));
    } else {
      emit(state.copyWith(
        status: DriverRegisterStep3Status.ready,
        feedbackMessage: 'Failed to submit documents. Please try again.',
      ));
    }
  }

  void _onStateSwitched(
    DriverRegisterStep3StateSwitched event,
    Emitter<DriverRegisterStep3State> emit,
  ) {
    switch (event.status) {
      case DriverRegisterStep3Status.initial:
        // Screen 3: Initial Empty State
        final docs = {
          for (final type in DriverDocumentType.values)
            type: DriverDocumentItem(type: type),
        };
        emit(state.copyWith(
          status: DriverRegisterStep3Status.initial,
          data: DriverRegisterStep3Data(documents: docs),
          isUploadModalOpen: false,
          selectedDocumentForModal: null,
          actionRequiredMessage: null,
          actionRequiredDetails: null,
        ));
        break;

      case DriverRegisterStep3Status.uploading:
        // Screen 1: Upload in Progress (Insurance 68% / 75%)
        final docs = {
          DriverDocumentType.driversLicence: const DriverDocumentItem(
            type: DriverDocumentType.driversLicence,
            status: DocumentUploadStatus.uploaded,
            fileName: 'alberta_dl_front_back.jpg',
            fileSize: '2.4 MB',
            fileDescriptor: 'Ready',
            expiryDate: 'Oct 14, 2027',
          ),
          DriverDocumentType.vehicleRegistration: const DriverDocumentItem(
            type: DriverDocumentType.vehicleRegistration,
            status: DocumentUploadStatus.uploaded,
            fileName: 'ab_registration_2024.pdf',
            fileSize: '1.1 MB',
            fileDescriptor: 'Verified',
            expiryDate: 'May 31, 2025',
          ),
          DriverDocumentType.vehicleInsurance: const DriverDocumentItem(
            type: DriverDocumentType.vehicleInsurance,
            status: DocumentUploadStatus.uploading,
            fileName: 'pink_card_insurance.jpg',
            uploadProgress: 0.75,
            fileDescriptor:
                'Encrypting and uploading to Bridge City Fleet Vault...',
          ),
          DriverDocumentType.taxiChauffeurPermit: const DriverDocumentItem(
            type: DriverDocumentType.taxiChauffeurPermit,
            status: DocumentUploadStatus.notUploaded,
          ),
        };
        emit(state.copyWith(
          status: DriverRegisterStep3Status.uploading,
          data: DriverRegisterStep3Data(documents: docs),
          isUploadModalOpen: false,
          selectedDocumentForModal: null,
          actionRequiredMessage: null,
          actionRequiredDetails: null,
        ));
        break;

      case DriverRegisterStep3Status.uploadModal:
        // Screen 6: Upload Document Modal
        final docs = {
          for (final type in DriverDocumentType.values)
            type: DriverDocumentItem(type: type),
        };
        emit(state.copyWith(
          status: DriverRegisterStep3Status.uploadModal,
          data: DriverRegisterStep3Data(
            documents: docs,
            activeModalDocument: DriverDocumentType.driversLicence,
          ),
          isUploadModalOpen: true,
          selectedDocumentForModal: DriverDocumentType.driversLicence,
        ));
        break;

      case DriverRegisterStep3Status.actionRequired:
        // Screen 5: 1 Action Required (Automated Check Failed on DL)
        final docs = {
          DriverDocumentType.driversLicence: const DriverDocumentItem(
            type: DriverDocumentType.driversLicence,
            status: DocumentUploadStatus.needsRetake,
            errorMessage:
                'Image is blurry and corners are cut off. Please retake in good lighting without flash glare.',
          ),
          DriverDocumentType.vehicleRegistration: const DriverDocumentItem(
            type: DriverDocumentType.vehicleRegistration,
            status: DocumentUploadStatus.uploaded,
            fileName: 'ab_registration_2024.pdf',
            expiryDate: 'May 31, 2025',
            fileDescriptor: 'Class 1-4 Commercial Plate',
          ),
          DriverDocumentType.vehicleInsurance: const DriverDocumentItem(
            type: DriverDocumentType.vehicleInsurance,
            status: DocumentUploadStatus.uploaded,
            fileName: 'pink_card_insurance.jpg',
            expiryDate: 'Dec 15, 2025',
            fileDescriptor: 'Alberta Standard Form (SPF 1)',
          ),
          DriverDocumentType.taxiChauffeurPermit: const DriverDocumentItem(
            type: DriverDocumentType.taxiChauffeurPermit,
            status: DocumentUploadStatus.notUploaded,
            fileDescriptor: 'City dispatch permit · Optional',
          ),
        };
        emit(state.copyWith(
          status: DriverRegisterStep3Status.actionRequired,
          data: DriverRegisterStep3Data(documents: docs),
          isUploadModalOpen: false,
          selectedDocumentForModal: null,
          actionRequiredMessage:
              DriverRegisterConfig.step3LicenceNeedsReuploadTitle,
          actionRequiredDetails:
              DriverRegisterConfig.step3LicenceNeedsReuploadDesc,
        ));
        break;

      case DriverRegisterStep3Status.ready:
        // Screen 2: Ready for Fleet Compliance (All 3 required + optional uploaded)
        final docs = {
          DriverDocumentType.driversLicence: const DriverDocumentItem(
            type: DriverDocumentType.driversLicence,
            status: DocumentUploadStatus.uploaded,
            fileName: 'alberta_dl_front_back.jpg',
            fileSize: '2.4 MB',
            fileDescriptor: 'High resolution',
            expiryDate: 'Oct 14, 2027',
            complianceBadge: 'VALID 3+ YRS',
          ),
          DriverDocumentType.vehicleRegistration: const DriverDocumentItem(
            type: DriverDocumentType.vehicleRegistration,
            status: DocumentUploadStatus.uploaded,
            fileName: 'ab_registration_2024.pdf',
            fileSize: '1.1 MB',
            fileDescriptor: 'Scanned document',
            expiryDate: 'May 31, 2025',
            complianceBadge: 'IN FLEET SPEC',
          ),
          DriverDocumentType.vehicleInsurance: const DriverDocumentItem(
            type: DriverDocumentType.vehicleInsurance,
            status: DocumentUploadStatus.uploaded,
            fileName: 'pink_card_insurance.jpg',
            fileSize: '3.2 MB',
            fileDescriptor: 'Color photo',
            expiryDate: 'Dec 15, 2025',
            complianceBadge: r'$2M LIABILITY OK',
          ),
          DriverDocumentType.taxiChauffeurPermit: const DriverDocumentItem(
            type: DriverDocumentType.taxiChauffeurPermit,
            status: DocumentUploadStatus.uploaded,
            fileName: 'lethbridge_chauffeur_badge.pdf',
            fileSize: '890 KB',
            fileDescriptor: 'City permit',
            expiryDate: 'Aug 20, 2026',
            complianceBadge: 'FAST-TRACK BONUS',
          ),
        };
        emit(state.copyWith(
          status: DriverRegisterStep3Status.ready,
          data: DriverRegisterStep3Data(documents: docs),
          isUploadModalOpen: false,
          selectedDocumentForModal: null,
          actionRequiredMessage: null,
          actionRequiredDetails: null,
        ));
        break;

      case DriverRegisterStep3Status.submitting:
        // Screen 4: Transmitting to Fleet Server
        final docs = {
          DriverDocumentType.driversLicence: const DriverDocumentItem(
            type: DriverDocumentType.driversLicence,
            status: DocumentUploadStatus.uploaded,
            isLocked: true,
            fileDescriptor: 'Alberta Class 4',
          ),
          DriverDocumentType.vehicleRegistration: const DriverDocumentItem(
            type: DriverDocumentType.vehicleRegistration,
            status: DocumentUploadStatus.uploaded,
            isLocked: true,
            fileDescriptor: 'AB Fleet Reg #9410',
          ),
          DriverDocumentType.vehicleInsurance: const DriverDocumentItem(
            type: DriverDocumentType.vehicleInsurance,
            status: DocumentUploadStatus.uploaded,
            isLocked: true,
            fileDescriptor: 'Commercial Endorsement',
          ),
          DriverDocumentType.taxiChauffeurPermit: const DriverDocumentItem(
            type: DriverDocumentType.taxiChauffeurPermit,
            status: DocumentUploadStatus.uploaded,
            isLocked: true,
            fileDescriptor: 'Lethbridge Chauffeur #204',
          ),
        };
        emit(state.copyWith(
          status: DriverRegisterStep3Status.submitting,
          data: DriverRegisterStep3Data(
            documents: docs,
            transmissionPercentage: 98,
            dispatchNode: 'YQL-Fleet-Node-04',
          ),
          isUploadModalOpen: false,
          selectedDocumentForModal: null,
        ));
        break;

      case DriverRegisterStep3Status.success:
        emit(state.copyWith(
          status: DriverRegisterStep3Status.success,
          isUploadModalOpen: false,
          feedbackMessage: 'Step 3 Complete! Proceeding to Step 4.',
        ));
        break;
    }
  }
}
