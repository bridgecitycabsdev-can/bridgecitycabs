import 'package:flutter/material.dart';

enum DriverVehicleClass {
  compact,
  medium,
  big,
  premium;

  String get title {
    switch (this) {
      case DriverVehicleClass.compact:
        return 'Compact';
      case DriverVehicleClass.medium:
        return 'Medium';
      case DriverVehicleClass.big:
        return 'Big';
      case DriverVehicleClass.premium:
        return 'Premium';
    }
  }

  String get subtitle {
    switch (this) {
      case DriverVehicleClass.compact:
        return 'Up to 3 seats';
      case DriverVehicleClass.medium:
        return 'Sedan / CUV';
      case DriverVehicleClass.big:
        return 'Minivan / 6+';
      case DriverVehicleClass.premium:
        return 'Executive';
    }
  }

  IconData get icon {
    switch (this) {
      case DriverVehicleClass.compact:
        return Icons.directions_car_outlined;
      case DriverVehicleClass.medium:
        return Icons.directions_car_rounded;
      case DriverVehicleClass.big:
        return Icons.airport_shuttle_rounded;
      case DriverVehicleClass.premium:
        return Icons.star_border_rounded;
    }
  }

  String get infoDescription {
    switch (this) {
      case DriverVehicleClass.compact:
        return 'Compact: Economical vehicles for up to 3 passengers.';
      case DriverVehicleClass.medium:
        return 'Medium: Standard sedans and small SUVs for up to 4 passengers with carry-on luggage.';
      case DriverVehicleClass.big:
        return 'Big: Minivans and large SUVs for 6+ passengers with luggage.';
      case DriverVehicleClass.premium:
        return 'Premium: High-end executive black sedans with luxury interior.';
    }
  }
}
