import 'package:equatable/equatable.dart';

enum DriverRoutingPathwayType {
  approvedDriver,
  docsInReview,
  newNumber,
}

class DriverRoutingPathway extends Equatable {
  final DriverRoutingPathwayType type;
  final String label;
  final String destinationText;
  final String routePath;

  const DriverRoutingPathway({
    required this.type,
    required this.label,
    required this.destinationText,
    required this.routePath,
  });

  static const List<DriverRoutingPathway> pathways = [
    DriverRoutingPathway(
      type: DriverRoutingPathwayType.approvedDriver,
      label: 'Approved Driver',
      destinationText: 'Driver Home',
      routePath: '/home',
    ),
    DriverRoutingPathway(
      type: DriverRoutingPathwayType.docsInReview,
      label: 'Docs in Review',
      destinationText: 'Pending Approval',
      routePath: '/pending-approval',
    ),
    DriverRoutingPathway(
      type: DriverRoutingPathwayType.newNumber,
      label: 'New Number',
      destinationText: 'Register Step 1',
      routePath: '/onboarding',
    ),
  ];

  @override
  List<Object?> get props => [type, label, destinationText, routePath];
}
