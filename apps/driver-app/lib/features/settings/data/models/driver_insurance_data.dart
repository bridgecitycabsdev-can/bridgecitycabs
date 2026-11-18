import 'package:equatable/equatable.dart';

class CoverageBenefitItem extends Equatable {
  final String title;
  final String description;

  const CoverageBenefitItem({
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [title, description];
}

class RequiredDocumentItem extends Equatable {
  final String title;
  final String subtitle;
  final bool isVerified;

  const RequiredDocumentItem({
    required this.title,
    required this.subtitle,
    this.isVerified = true,
  });

  @override
  List<Object?> get props => [title, subtitle, isVerified];
}

class CollisionStepItem extends Equatable {
  final int stepNumber;
  final String title;
  final String description;

  const CollisionStepItem({
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [stepNumber, title, description];
}

class DriverInsuranceData extends Equatable {
  final String policyNumber;
  final String statusLabel;
  final String underwritingCompany;
  final String fleetSyncStatus;
  final List<CoverageBenefitItem> benefits;
  final List<RequiredDocumentItem> requiredDocuments;
  final List<CollisionStepItem> collisionSteps;

  const DriverInsuranceData({
    this.policyNumber = 'AB-LCC-9821',
    this.statusLabel = 'ACTIVE POLICY',
    this.underwritingCompany =
        'Underwritten by Intact Fleet Solutions for Bridge City Cabs Ltd.',
    this.fleetSyncStatus = 'Lethbridge Fleet Sync: Operational',
    this.benefits = const [
      CoverageBenefitItem(
        title: '\$5,000,000 Third-Party Liability',
        description:
            'Active protection in effect from trip acceptance through passenger egress across southern Alberta.',
      ),
      CoverageBenefitItem(
        title: 'Collision & Passenger Property Damage',
        description:
            'Covers physical vehicular impact damages and certified luggage while on active dispatch.',
      ),
      CoverageBenefitItem(
        title: 'Comprehensive Roadside Assistance',
        description:
            'Dedicated 24/7 towing, tire support, and battery jump across Lethbridge, Highway 3, and Highway 4 corridor.',
      ),
    ],
    this.requiredDocuments = const [
      RequiredDocumentItem(
        title: 'Alberta Class 4 Commercial...',
        subtitle: 'With valid commercial pink slip rider',
        isVerified: true,
      ),
      RequiredDocumentItem(
        title: 'Annual CVIP Mechanical C...',
        subtitle: 'Signed by Alberta Transportation certifier',
        isVerified: true,
      ),
      RequiredDocumentItem(
        title: 'City of Lethbridge Livery P...',
        subtitle: 'Annual decal affixed to front windshield',
        isVerified: true,
      ),
    ],
    this.collisionSteps = const [
      CollisionStepItem(
        stepNumber: 1,
        title: 'Secure Safety & Hazard Lights',
        description:
            'Shift to Park, trigger hazard flashers, verify passenger status, and reposition away from oncoming traffic.',
      ),
      CollisionStepItem(
        stepNumber: 2,
        title: 'Call 911 If Medical Care Needed',
        description:
            'Request Lethbridge Police Service (LPS) dispatch for any injuries or major public roadway obstruction.',
      ),
      CollisionStepItem(
        stepNumber: 3,
        title: 'Capture Photos & Third-Party Info',
        description:
            'Photograph vehicle positions, license plates, intersection road conditions, and witness details.',
      ),
      CollisionStepItem(
        stepNumber: 4,
        title: 'Submit Dispatch Claim Within 24h',
        description:
            'File directly via 24/7 Driver Support hotline or Bridge City fleet terminal on 3rd Avenue S.',
      ),
    ],
  });

  @override
  List<Object?> get props => [
    policyNumber,
    statusLabel,
    underwritingCompany,
    fleetSyncStatus,
    benefits,
    requiredDocuments,
    collisionSteps,
  ];
}
