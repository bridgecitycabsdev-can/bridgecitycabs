import 'package:equatable/equatable.dart';
import '../data/models/driver_register_step4_data.dart';
import '../data/models/driver_register_step4_status.dart';

abstract class DriverRegisterStep4Event extends Equatable {
  const DriverRegisterStep4Event();

  @override
  List<Object?> get props => [];
}

class DriverRegisterStep4Started extends DriverRegisterStep4Event {
  final DriverRegisterStep4Status initialStatus;
  final DriverRegisterStep4Data? initialData;

  const DriverRegisterStep4Started({
    this.initialStatus = DriverRegisterStep4Status.reviewing,
    this.initialData,
  });

  @override
  List<Object?> get props => [initialStatus, initialData];
}

class DriverRegisterStep4RefreshRequested extends DriverRegisterStep4Event {
  const DriverRegisterStep4RefreshRequested();
}

class DriverRegisterStep4ReconnectRequested extends DriverRegisterStep4Event {
  const DriverRegisterStep4ReconnectRequested();
}

class DriverRegisterStep4GoHomeRequested extends DriverRegisterStep4Event {
  const DriverRegisterStep4GoHomeRequested();
}

class DriverRegisterStep4FixDocumentsRequested extends DriverRegisterStep4Event {
  const DriverRegisterStep4FixDocumentsRequested();
}

class DriverRegisterStep4UpdateVehicleRequested
    extends DriverRegisterStep4Event {
  const DriverRegisterStep4UpdateVehicleRequested();
}

class DriverRegisterStep4ContactSupportRequested
    extends DriverRegisterStep4Event {
  const DriverRegisterStep4ContactSupportRequested();
}

class DriverRegisterStep4StateSwitched extends DriverRegisterStep4Event {
  final DriverRegisterStep4Status status;

  const DriverRegisterStep4StateSwitched(this.status);

  @override
  List<Object?> get props => [status];
}
