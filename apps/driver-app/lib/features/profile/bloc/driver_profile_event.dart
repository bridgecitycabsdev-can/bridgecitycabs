import 'package:equatable/equatable.dart';
import '../data/models/driver_credential_model.dart';
import '../data/models/driver_profile_status.dart';
import '../data/models/driver_profile_tab.dart';

abstract class DriverProfileEvent extends Equatable {
  const DriverProfileEvent();

  @override
  List<Object?> get props => [];
}

class DriverProfileStarted extends DriverProfileEvent {
  final DriverProfileStatus initialStatus;
  final DriverProfileTab initialTab;

  const DriverProfileStarted({
    this.initialStatus = DriverProfileStatus.activeOnline,
    this.initialTab = DriverProfileTab.info,
  });

  @override
  List<Object?> get props => [initialStatus, initialTab];
}

class DriverProfileTabChanged extends DriverProfileEvent {
  final DriverProfileTab tab;

  const DriverProfileTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class DriverProfileCredentialTapped extends DriverProfileEvent {
  final DriverCredentialModel credential;

  const DriverProfileCredentialTapped(this.credential);

  @override
  List<Object?> get props => [credential];
}

class DriverProfileInspectionDismissed extends DriverProfileEvent {
  const DriverProfileInspectionDismissed();
}

class DriverProfileUploadRequested extends DriverProfileEvent {
  final String credentialId;

  const DriverProfileUploadRequested(this.credentialId);

  @override
  List<Object?> get props => [credentialId];
}

class DriverProfileSyncRetryPressed extends DriverProfileEvent {
  const DriverProfileSyncRetryPressed();
}

class DriverProfileContactSupportPressed extends DriverProfileEvent {
  const DriverProfileContactSupportPressed();
}

class DriverProfileStateForced extends DriverProfileEvent {
  final DriverProfileStatus status;

  const DriverProfileStateForced(this.status);

  @override
  List<Object?> get props => [status];
}
