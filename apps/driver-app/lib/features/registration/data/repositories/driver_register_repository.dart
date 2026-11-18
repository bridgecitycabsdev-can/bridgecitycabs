import '../models/driver_application_milestone.dart';
import '../models/driver_document_item.dart';
import '../models/driver_document_type.dart';
import '../models/driver_register_step1_data.dart';
import '../models/driver_register_step2_data.dart';
import '../models/driver_register_step3_data.dart';
import '../models/driver_register_step4_data.dart';

abstract class DriverRegisterRepository {
  Future<bool> saveStep1Details(DriverRegisterStep1Data data);
  Future<String?> pickProfilePhoto({required String source});
  Future<bool> saveStep2VehicleDetails(DriverRegisterStep2Data data);
  Future<DriverDocumentItem> uploadDocument({
    required DriverDocumentType type,
    required String source,
  });
  Future<bool> submitStep3Documents(DriverRegisterStep3Data data);
  Future<DriverRegisterStep4Data> checkApplicationStatus();
  Future<bool> retryConnection();
}

class MockDriverRegisterRepository implements DriverRegisterRepository {
  @override
  Future<bool> saveStep1Details(DriverRegisterStep1Data data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  @override
  Future<String?> pickProfilePhoto({required String source}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb';
  }

  @override
  Future<bool> saveStep2VehicleDetails(DriverRegisterStep2Data data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  @override
  Future<DriverDocumentItem> uploadDocument({
    required DriverDocumentType type,
    required String source,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    switch (type) {
      case DriverDocumentType.driversLicence:
        return const DriverDocumentItem(
          type: DriverDocumentType.driversLicence,
          status: DocumentUploadStatus.uploaded,
          fileName: 'alberta_dl_front_back.jpg',
          fileSize: '2.4 MB',
          fileDescriptor: 'High resolution',
          expiryDate: 'Oct 14, 2027',
          complianceBadge: 'VALID 3+ YRS',
        );
      case DriverDocumentType.vehicleRegistration:
        return const DriverDocumentItem(
          type: DriverDocumentType.vehicleRegistration,
          status: DocumentUploadStatus.uploaded,
          fileName: 'ab_registration_2024.pdf',
          fileSize: '1.1 MB',
          fileDescriptor: 'Scanned document',
          expiryDate: 'May 31, 2025',
          complianceBadge: 'IN FLEET SPEC',
        );
      case DriverDocumentType.vehicleInsurance:
        return const DriverDocumentItem(
          type: DriverDocumentType.vehicleInsurance,
          status: DocumentUploadStatus.uploaded,
          fileName: 'pink_card_insurance.jpg',
          fileSize: '3.2 MB',
          fileDescriptor: 'Color photo',
          expiryDate: 'Dec 15, 2025',
          complianceBadge: r'$2M LIABILITY OK',
        );
      case DriverDocumentType.taxiChauffeurPermit:
        return const DriverDocumentItem(
          type: DriverDocumentType.taxiChauffeurPermit,
          status: DocumentUploadStatus.uploaded,
          fileName: 'lethbridge_chauffeur_badge.pdf',
          fileSize: '890 KB',
          fileDescriptor: 'City permit',
          expiryDate: 'Aug 20, 2026',
          complianceBadge: 'FAST-TRACK BONUS',
        );
    }
  }

  @override
  Future<bool> submitStep3Documents(DriverRegisterStep3Data data) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true;
  }

  @override
  Future<DriverRegisterStep4Data> checkApplicationStatus() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const DriverRegisterStep4Data(
      driverName: 'Marcus Vance',
      vehicleModel: 'Toyota Camry Hybrid',
      vehicleYear: 2021,
      licensePlate: 'AB · BCC-9482',
      fleetId: '#409',
      fleetTag: 'Active Partner',
      milestones: [
        DriverApplicationMilestone(
          title: 'Application submitted',
          subtitle: 'Driver profile and provincial licensing received',
          timestamp: 'Oct 24, 2024',
          status: MilestoneStatus.completed,
        ),
        DriverApplicationMilestone(
          title: 'Documents reviewed & verified',
          subtitle: 'City of Lethbridge Bylaw 5834 passed',
          status: MilestoneStatus.completed,
          badgeText: 'Passed',
        ),
        DriverApplicationMilestone(
          title: 'Approved and ready to drive',
          subtitle: 'Vehicle inspection & insurance authenticated',
          status: MilestoneStatus.completed,
          badgeText: '● Ready',
        ),
      ],
    );
  }

  @override
  Future<bool> retryConnection() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }
}
