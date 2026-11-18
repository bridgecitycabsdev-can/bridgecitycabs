import 'package:equatable/equatable.dart';
import 'driver_vehicle_class.dart';

class DriverRegisterStep2Data extends Equatable {
  static const int minimumVehicleYear = 2014;

  final DriverVehicleClass? vehicleClass;
  final String make;
  final String model;
  final int? year;
  final String colour;
  final String plateNumber;
  final bool suitableForVanOnly;
  final bool femaleDriverOnly;

  const DriverRegisterStep2Data({
    this.vehicleClass,
    this.make = '',
    this.model = '',
    this.year,
    this.colour = '',
    this.plateNumber = '',
    this.suitableForVanOnly = false,
    this.femaleDriverOnly = false,
  });

  bool get isVehicleClassSelected => vehicleClass != null;
  bool get isMakeValid => make.trim().isNotEmpty;
  bool get isModelValid => model.trim().isNotEmpty;
  bool get isYearValid => year != null && year! >= minimumVehicleYear;

  bool get isPlateValid {
    final clean = plateNumber.replaceAll(RegExp(r'[\s-]'), '');
    return clean.length >= 6;
  }

  bool get isFormValid =>
      isVehicleClassSelected &&
      isMakeValid &&
      isModelValid &&
      isYearValid &&
      isPlateValid;

  DriverRegisterStep2Data copyWith({
    DriverVehicleClass? vehicleClass,
    String? make,
    String? model,
    int? year,
    String? colour,
    String? plateNumber,
    bool? suitableForVanOnly,
    bool? femaleDriverOnly,
  }) {
    return DriverRegisterStep2Data(
      vehicleClass: vehicleClass ?? this.vehicleClass,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      colour: colour ?? this.colour,
      plateNumber: plateNumber ?? this.plateNumber,
      suitableForVanOnly: suitableForVanOnly ?? this.suitableForVanOnly,
      femaleDriverOnly: femaleDriverOnly ?? this.femaleDriverOnly,
    );
  }

  @override
  List<Object?> get props => [
        vehicleClass,
        make,
        model,
        year,
        colour,
        plateNumber,
        suitableForVanOnly,
        femaleDriverOnly,
      ];
}
