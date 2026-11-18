import 'package:flutter/material.dart';

enum DriverDocumentType {
  driversLicence,
  vehicleRegistration,
  vehicleInsurance,
  taxiChauffeurPermit;

  String get title {
    switch (this) {
      case DriverDocumentType.driversLicence:
        return "Driver's licence";
      case DriverDocumentType.vehicleRegistration:
        return 'Vehicle registration';
      case DriverDocumentType.vehicleInsurance:
        return 'Vehicle insurance';
      case DriverDocumentType.taxiChauffeurPermit:
        return 'Taxi or chauffeur permit';
    }
  }

  String get subtitle {
    switch (this) {
      case DriverDocumentType.driversLicence:
        return 'Front and back · Required';
      case DriverDocumentType.vehicleRegistration:
        return 'Current year · Required';
      case DriverDocumentType.vehicleInsurance:
        return 'Must show plate & valid · Required';
      case DriverDocumentType.taxiChauffeurPermit:
        return 'City of Lethbridge (Optional)';
    }
  }

  String get complianceSpecification {
    switch (this) {
      case DriverDocumentType.driversLicence:
        return 'Class 1, 2, or 4 Alberta';
      case DriverDocumentType.vehicleRegistration:
        return 'Active commercial or personal';
      case DriverDocumentType.vehicleInsurance:
        return 'Alberta standard pink card';
      case DriverDocumentType.taxiChauffeurPermit:
        return 'City dispatch permit · Optional';
    }
  }

  bool get isRequired => this != DriverDocumentType.taxiChauffeurPermit;

  IconData get icon {
    switch (this) {
      case DriverDocumentType.driversLicence:
        return Icons.badge_outlined;
      case DriverDocumentType.vehicleRegistration:
        return Icons.directions_car_outlined;
      case DriverDocumentType.vehicleInsurance:
        return Icons.shield_outlined;
      case DriverDocumentType.taxiChauffeurPermit:
        return Icons.local_taxi_outlined;
    }
  }
}
