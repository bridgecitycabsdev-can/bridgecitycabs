import 'driver_assigned_vehicle.dart';
import 'driver_credential_model.dart';
import 'driver_profile_data.dart';
import 'driver_profile_status.dart';

class DriverProfileConfig {
  const DriverProfileConfig._();

  static const String dispatchHotline = '403-328-8888';
  static const String operationsDesk = 'Lethbridge Operations Desk 24/7';

  static DriverProfileData activeOnlinePreset() {
    return const DriverProfileData(
      fullName: 'Shajil Kunhumon',
      email: 's.kunhumon@bridgecity.ca',
      phone: '+1 (403) 555-0192',
      licenseNumber: 'AB-DL-982104-X',
      gender: 'Male',
      rating: 4.9,
      reviewCount: 120,
      todayEarnings: 41.77,
      todayTips: 0.00,
      todayRides: 1,
      todayKm: 10.0,
      isOnline: true,
      isVerifiedFleet: true,
      assignedVehicle: DriverAssignedVehicle(
        makeModel: 'White Toyota Camry Hybrid (2021)',
        unitNumber: 'Unit #42',
        plateNumber: 'BCC-9482',
        vehicleClass: 'Sedan • Medium',
        inspectionLabel: 'City Inspected • Lethbridge Fleet Municipal Permit',
        isGpsLinked: true,
      ),
      credentials: [
        DriverCredentialModel(
          id: 'cred_dl_1',
          title: "Driver's licence",
          subtitle: 'AB Standard Livery',
          status: DriverCredentialStatus.approved,
          expiryText: 'Expires 14 Mar 2027 • AB',
          idNumber: 'AB-DL-982104-X',
        ),
        DriverCredentialModel(
          id: 'cred_reg_1',
          title: 'Vehicle registration',
          subtitle: 'Commercial Fleet',
          status: DriverCredentialStatus.approved,
          expiryText: 'Expires 31 May 2025 • Fleet',
          idNumber: 'BCC-9482',
        ),
      ],
      status: DriverProfileStatus.activeOnline,
    );
  }

  static DriverProfileData expiredLockedPreset() {
    return const DriverProfileData(
      fullName: 'Marcus Vance',
      email: 'marcus.vance@bridgecitycabs.ca',
      phone: '+1 (403) 555-0182',
      licenseNumber: 'AB-DL-829104-M',
      gender: 'Male',
      rating: 4.9,
      reviewCount: 94,
      todayEarnings: 0.00,
      todayTips: 0.00,
      todayRides: 0,
      todayKm: 0.0,
      isOnline: false,
      isVerifiedFleet: false,
      assignedVehicle: DriverAssignedVehicle(
        makeModel: 'Toyota Camry Hybrid (2021)',
        unitNumber: 'Cab #104',
        plateNumber: 'BCC-9482',
        vehicleClass: 'Sedan • Medium',
        inspectionLabel: 'Bridge City Fleet',
        isGpsLinked: false,
      ),
      credentials: [
        DriverCredentialModel(
          id: 'cred_dl_expired',
          title: "Class 4 Driver's Licence",
          subtitle: 'Alberta Standard Taxi / Livery',
          status: DriverCredentialStatus.expired,
          expiryText: 'Expired Oct 24, 2024',
          idNumber: '•••• 8291',
        ),
        DriverCredentialModel(
          id: 'cred_permit_valid',
          title: 'City Taxi Permit',
          subtitle: 'City of Lethbridge',
          status: DriverCredentialStatus.valid,
          expiryText: 'Expires Jan 15, 2026 • City of Lethbridge',
        ),
        DriverCredentialModel(
          id: 'cred_cvip_review',
          title: 'Annual CVIP Inspection',
          subtitle: 'Fleet Safety Unit',
          status: DriverCredentialStatus.inReview,
          expiryText: 'Submitted yesterday • Fleet Safety Unit',
        ),
        DriverCredentialModel(
          id: 'cred_insurance_valid',
          title: 'Fleet Policy #440-912',
          subtitle: 'Intact Commercial',
          status: DriverCredentialStatus.valid,
          expiryText: 'Expires Nov 30, 2025 • Intact Commercial',
        ),
      ],
      status: DriverProfileStatus.credentialExpiredLocked,
    );
  }

  static DriverProfileData expiringSoonPreset() {
    return const DriverProfileData(
      fullName: 'Marcus Vance',
      email: 'marcus.vance@bridgecitycabs.ca',
      phone: '+1 (403) 555-0182',
      licenseNumber: 'AB-DL-829104-M',
      gender: 'Male',
      rating: 4.9,
      reviewCount: 94,
      todayEarnings: 41.77,
      todayTips: 0.00,
      todayRides: 1,
      todayKm: 10.0,
      isOnline: true,
      isVerifiedFleet: true,
      assignedVehicle: DriverAssignedVehicle(
        makeModel: 'Toyota Camry Hybrid (2021)',
        unitNumber: 'Unit #42',
        plateNumber: 'BCC-9482',
        vehicleClass: 'Sedan • Medium',
        inspectionLabel: 'City Inspected • Lethbridge Fleet Municipal Permit',
        isGpsLinked: true,
      ),
      credentials: [
        DriverCredentialModel(
          id: 'cred_dl_approved',
          title: "Driver's licence",
          subtitle: 'Alberta Standard Livery',
          status: DriverCredentialStatus.approved,
          expiryText: 'Expires 14 Mar 2027 • AB',
        ),
        DriverCredentialModel(
          id: 'cred_reg_approved',
          title: 'Vehicle registration',
          subtitle: 'Commercial Taxi',
          status: DriverCredentialStatus.approved,
          expiryText: 'Expires 31 May 2025 • Fleet',
        ),
        DriverCredentialModel(
          id: 'cred_ins_expiring',
          title: 'Vehicle insurance',
          subtitle: 'Standard Commercial Pink Card',
          status: DriverCredentialStatus.expiringSoon,
          expiryText: 'Expires in 12 days (Nov 15, 2024)',
          policyNumber: '#LC-9940128',
          issueDate: '15 Nov 2023',
          expirationDate: '15 Nov 2024',
          isInspectionShielded: true,
        ),
        DriverCredentialModel(
          id: 'cred_permit_approved',
          title: 'Taxi or chauffeur permit',
          subtitle: 'Lethbridge Bylaw 5834',
          status: DriverCredentialStatus.approved,
          expiryText: 'Lethbridge Bylaw 5834 • Verified',
        ),
      ],
      status: DriverProfileStatus.expiringSoonInspection,
    );
  }

  static DriverProfileData offlinePartnerPreset() {
    return const DriverProfileData(
      fullName: 'Marcus Vance',
      email: 'marcus.vance@bridgecitycabs.ca',
      phone: '+1 (403) 555-0182',
      licenseNumber: 'Alberta Class 4 (Commercial Taxi)',
      gender: 'Male',
      rating: null,
      reviewCount: 0,
      todayEarnings: 0.00,
      todayTips: 0.00,
      todayRides: 0,
      todayKm: 0.0,
      isOnline: false,
      isVerifiedFleet: true,
      assignedVehicle: DriverAssignedVehicle(
        makeModel: 'Toyota Camry Hybrid (2021)',
        unitNumber: 'BCC Fleet Unit #14',
        plateNumber: 'BCC-9482',
        vehicleClass: 'Sedan • Medium',
        inspectionLabel: 'INSPECTED',
        isGpsLinked: false,
      ),
      credentials: [],
      status: DriverProfileStatus.offlineSyncAlert,
    );
  }
}
