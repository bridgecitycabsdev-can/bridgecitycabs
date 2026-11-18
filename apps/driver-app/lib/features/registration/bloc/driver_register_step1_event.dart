import 'package:equatable/equatable.dart';
import '../data/models/driver_register_step1_data.dart';
import '../data/models/driver_register_step1_status.dart';

abstract class DriverRegisterStep1Event extends Equatable {
  const DriverRegisterStep1Event();

  @override
  List<Object?> get props => [];
}

class DriverRegisterStep1Started extends DriverRegisterStep1Event {
  final DriverRegisterStep1Data? initialData;
  final DriverRegisterStep1Status initialStatus;

  const DriverRegisterStep1Started({
    this.initialData,
    this.initialStatus = DriverRegisterStep1Status.initial,
  });

  @override
  List<Object?> get props => [initialData, initialStatus];
}

class DriverRegisterPhotoModalOpened extends DriverRegisterStep1Event {
  const DriverRegisterPhotoModalOpened();
}

class DriverRegisterPhotoModalDismissed extends DriverRegisterStep1Event {
  const DriverRegisterPhotoModalDismissed();
}

class DriverRegisterPhotoPicked extends DriverRegisterStep1Event {
  final String source; // 'camera' or 'gallery'

  const DriverRegisterPhotoPicked(this.source);

  @override
  List<Object?> get props => [source];
}

class DriverRegisterFirstNameChanged extends DriverRegisterStep1Event {
  final String firstName;

  const DriverRegisterFirstNameChanged(this.firstName);

  @override
  List<Object?> get props => [firstName];
}

class DriverRegisterLastNameChanged extends DriverRegisterStep1Event {
  final String lastName;

  const DriverRegisterLastNameChanged(this.lastName);

  @override
  List<Object?> get props => [lastName];
}

class DriverRegisterEmailChanged extends DriverRegisterStep1Event {
  final String email;

  const DriverRegisterEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class DriverRegisterLicenceChanged extends DriverRegisterStep1Event {
  final String licenceNumber;

  const DriverRegisterLicenceChanged(this.licenceNumber);

  @override
  List<Object?> get props => [licenceNumber];
}

class DriverRegisterPostalCodeChanged extends DriverRegisterStep1Event {
  final String postalCode;

  const DriverRegisterPostalCodeChanged(this.postalCode);

  @override
  List<Object?> get props => [postalCode];
}

class DriverRegisterGenderSelected extends DriverRegisterStep1Event {
  final DriverGender gender;

  const DriverRegisterGenderSelected(this.gender);

  @override
  List<Object?> get props => [gender];
}

class DriverRegisterSubmitted extends DriverRegisterStep1Event {
  const DriverRegisterSubmitted();
}

class DriverRegisterStateSwitched extends DriverRegisterStep1Event {
  final DriverRegisterStep1Status status;

  const DriverRegisterStateSwitched(this.status);

  @override
  List<Object?> get props => [status];
}
