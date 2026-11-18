import 'package:equatable/equatable.dart';

class DriverAssignedVehicle extends Equatable {
  final String makeModel;
  final String unitNumber;
  final String plateNumber;
  final String vehicleClass;
  final String inspectionLabel;
  final bool isGpsLinked;

  const DriverAssignedVehicle({
    this.makeModel = 'White Toyota Camry Hybrid (2021)',
    this.unitNumber = 'Unit #42',
    this.plateNumber = 'AB BCC-9482',
    this.vehicleClass = 'Sedan • Medium',
    this.inspectionLabel =
        'City Inspected • Lethbridge Fleet Municipal Permit',
    this.isGpsLinked = true,
  });

  DriverAssignedVehicle copyWith({
    String? makeModel,
    String? unitNumber,
    String? plateNumber,
    String? vehicleClass,
    String? inspectionLabel,
    bool? isGpsLinked,
  }) {
    return DriverAssignedVehicle(
      makeModel: makeModel ?? this.makeModel,
      unitNumber: unitNumber ?? this.unitNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleClass: vehicleClass ?? this.vehicleClass,
      inspectionLabel: inspectionLabel ?? this.inspectionLabel,
      isGpsLinked: isGpsLinked ?? this.isGpsLinked,
    );
  }

  @override
  List<Object?> get props => [
    makeModel,
    unitNumber,
    plateNumber,
    vehicleClass,
    inspectionLabel,
    isGpsLinked,
  ];
}
