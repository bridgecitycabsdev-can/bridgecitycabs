import 'package:equatable/equatable.dart';
import '../data/models/driver_register_step2_data.dart';
import '../data/models/driver_register_step2_status.dart';
import '../data/models/driver_vehicle_class.dart';

abstract class DriverRegisterStep2Event extends Equatable {
  const DriverRegisterStep2Event();

  @override
  List<Object?> get props => [];
}

class DriverRegisterStep2Started extends DriverRegisterStep2Event {
  final DriverRegisterStep2Data? initialData;
  final DriverRegisterStep2Status initialStatus;

  const DriverRegisterStep2Started({
    this.initialData,
    this.initialStatus = DriverRegisterStep2Status.initial,
  });

  @override
  List<Object?> get props => [initialData, initialStatus];
}

class DriverRegisterVehicleClassSelected extends DriverRegisterStep2Event {
  final DriverVehicleClass vehicleClass;

  const DriverRegisterVehicleClassSelected(this.vehicleClass);

  @override
  List<Object?> get props => [vehicleClass];
}

class DriverRegisterMakeChanged extends DriverRegisterStep2Event {
  final String make;

  const DriverRegisterMakeChanged(this.make);

  @override
  List<Object?> get props => [make];
}

class DriverRegisterModelChanged extends DriverRegisterStep2Event {
  final String model;

  const DriverRegisterModelChanged(this.model);

  @override
  List<Object?> get props => [model];
}

class DriverRegisterYearPickerOpened extends DriverRegisterStep2Event {
  const DriverRegisterYearPickerOpened();
}

class DriverRegisterYearPickerDismissed extends DriverRegisterStep2Event {
  const DriverRegisterYearPickerDismissed();
}

class DriverRegisterYearSelected extends DriverRegisterStep2Event {
  final int year;

  const DriverRegisterYearSelected(this.year);

  @override
  List<Object?> get props => [year];
}

class DriverRegisterColourChanged extends DriverRegisterStep2Event {
  final String colour;

  const DriverRegisterColourChanged(this.colour);

  @override
  List<Object?> get props => [colour];
}

class DriverRegisterPlateChanged extends DriverRegisterStep2Event {
  final String plateNumber;

  const DriverRegisterPlateChanged(this.plateNumber);

  @override
  List<Object?> get props => [plateNumber];
}

class DriverRegisterVanOnlyToggled extends DriverRegisterStep2Event {
  final bool enabled;

  const DriverRegisterVanOnlyToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class DriverRegisterFemaleDriverToggled extends DriverRegisterStep2Event {
  final bool enabled;

  const DriverRegisterFemaleDriverToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class DriverRegisterStep2Submitted extends DriverRegisterStep2Event {
  const DriverRegisterStep2Submitted();
}

class DriverRegisterStep2StateSwitched extends DriverRegisterStep2Event {
  final DriverRegisterStep2Status status;

  const DriverRegisterStep2StateSwitched(this.status);

  @override
  List<Object?> get props => [status];
}
