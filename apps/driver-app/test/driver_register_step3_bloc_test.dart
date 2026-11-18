import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/registration/registration.dart';

class TestDriverRegisterRepository implements DriverRegisterRepository {
  final bool shouldSucceed;

  TestDriverRegisterRepository({this.shouldSucceed = true});

  @override
  Future<bool> saveStep1Details(DriverRegisterStep1Data data) async =>
      shouldSucceed;

  @override
  Future<String?> pickProfilePhoto({required String source}) async =>
      'https://example.com/driver.png';

  @override
  Future<bool> saveStep2VehicleDetails(DriverRegisterStep2Data data) async =>
      shouldSucceed;

  @override
  Future<DriverDocumentItem> uploadDocument({
    required DriverDocumentType type,
    required String source,
  }) async {
    return DriverDocumentItem(
      type: type,
      status: DocumentUploadStatus.uploaded,
      fileName: 'test_${type.name}.jpg',
      fileSize: '2.0 MB',
      fileDescriptor: 'Verified',
      expiryDate: 'Dec 31, 2026',
      complianceBadge: 'VALID',
    );
  }

  @override
  Future<bool> submitStep3Documents(DriverRegisterStep3Data data) async =>
      shouldSucceed;
}

void main() {
  group('DriverRegisterStep3Bloc Tests', () {
    test('initial state has all documents not uploaded and cannot submit', () {
      final bloc = DriverRegisterStep3Bloc(
        repository: TestDriverRegisterRepository(),
      );

      expect(bloc.state.status, DriverRegisterStep3Status.initial);
      expect(bloc.state.data.uploadedRequiredCount, 0);
      expect(bloc.state.data.areAllRequiredUploaded, isFalse);
      expect(bloc.state.canSubmit, isFalse);
      expect(bloc.state.isUploadModalOpen, isFalse);
    });

    test('opening and dismissing upload modal toggles state correctly', () {
      final bloc = DriverRegisterStep3Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterUploadModalOpened(
          DriverDocumentType.driversLicence));
      expect(bloc.state.isUploadModalOpen, isTrue);
      expect(bloc.state.selectedDocumentForModal,
          DriverDocumentType.driversLicence);
      expect(bloc.state.status, DriverRegisterStep3Status.uploadModal);

      bloc.add(const DriverRegisterUploadModalDismissed());
      expect(bloc.state.isUploadModalOpen, isFalse);
      expect(bloc.state.selectedDocumentForModal, isNull);
    });

    test('document upload request updates document to uploaded', () async {
      final bloc = DriverRegisterStep3Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterDocumentUploadRequested(
        documentType: DriverDocumentType.driversLicence,
        source: 'camera',
      ));

      // Initially uploading
      expect(
          bloc.state.data
              .getDocument(DriverDocumentType.driversLicence)
              .status,
          DocumentUploadStatus.uploading);

      await Future.delayed(const Duration(milliseconds: 10));

      // Becomes uploaded
      expect(
          bloc.state.data
              .getDocument(DriverDocumentType.driversLicence)
              .status,
          DocumentUploadStatus.uploaded);
    });

    test('deleting an uploaded document resets it to notUploaded', () {
      final bloc = DriverRegisterStep3Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(
          const DriverRegisterStep3StateSwitched(DriverRegisterStep3Status.ready));
      expect(
          bloc.state.data
              .getDocument(DriverDocumentType.driversLicence)
              .status,
          DocumentUploadStatus.uploaded);

      bloc.add(const DriverRegisterDocumentDeleted(
          DriverDocumentType.driversLicence));
      expect(
          bloc.state.data
              .getDocument(DriverDocumentType.driversLicence)
              .status,
          DocumentUploadStatus.notUploaded);
      expect(bloc.state.canSubmit, isFalse);
    });

    test('switching state directly via QA event sets expected datasets', () {
      final bloc = DriverRegisterStep3Bloc(
        repository: TestDriverRegisterRepository(),
      );

      // 1. Initial
      bloc.add(const DriverRegisterStep3StateSwitched(
          DriverRegisterStep3Status.initial));
      expect(bloc.state.status, DriverRegisterStep3Status.initial);
      expect(bloc.state.data.uploadedRequiredCount, 0);

      // 2. Uploading (Screen 1)
      bloc.add(const DriverRegisterStep3StateSwitched(
          DriverRegisterStep3Status.uploading));
      expect(bloc.state.status, DriverRegisterStep3Status.uploading);
      expect(
          bloc.state.data
              .getDocument(DriverDocumentType.vehicleInsurance)
              .status,
          DocumentUploadStatus.uploading);

      // 3. Modal (Screen 6)
      bloc.add(const DriverRegisterStep3StateSwitched(
          DriverRegisterStep3Status.uploadModal));
      expect(bloc.state.status, DriverRegisterStep3Status.uploadModal);
      expect(bloc.state.isUploadModalOpen, isTrue);

      // 4. Action Required (Screen 5)
      bloc.add(const DriverRegisterStep3StateSwitched(
          DriverRegisterStep3Status.actionRequired));
      expect(bloc.state.status, DriverRegisterStep3Status.actionRequired);
      expect(
          bloc.state.data
              .getDocument(DriverDocumentType.driversLicence)
              .status,
          DocumentUploadStatus.needsRetake);
      expect(bloc.state.actionRequiredMessage, isNotNull);

      // 5. Ready (Screen 2)
      bloc.add(const DriverRegisterStep3StateSwitched(
          DriverRegisterStep3Status.ready));
      expect(bloc.state.status, DriverRegisterStep3Status.ready);
      expect(bloc.state.data.areAllRequiredUploaded, isTrue);
      expect(bloc.state.canSubmit, isTrue);

      // 6. Submitting (Screen 4)
      bloc.add(const DriverRegisterStep3StateSwitched(
          DriverRegisterStep3Status.submitting));
      expect(bloc.state.status, DriverRegisterStep3Status.submitting);
      expect(
          bloc.state.data
              .getDocument(DriverDocumentType.driversLicence)
              .isLocked,
          isTrue);
      expect(bloc.state.data.transmissionPercentage, 98);
    });

    test('submitting documents when ready calls repository and emits success',
        () async {
      final bloc = DriverRegisterStep3Bloc(
        repository: TestDriverRegisterRepository(shouldSucceed: true),
      );

      bloc.add(
          const DriverRegisterStep3StateSwitched(DriverRegisterStep3Status.ready));
      bloc.add(const DriverRegisterStep3Submitted());

      expect(bloc.state.status, DriverRegisterStep3Status.submitting);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.status, DriverRegisterStep3Status.success);
    });
  });
}
