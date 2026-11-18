import 'package:equatable/equatable.dart';

import '../data/models/driver_delete_safeguard_block.dart';
import '../data/models/driver_delete_status.dart';

abstract class DriverDeleteAccountEvent extends Equatable {
  const DriverDeleteAccountEvent();

  @override
  List<Object?> get props => [];
}

class DriverDeleteStarted extends DriverDeleteAccountEvent {
  const DriverDeleteStarted();
}

class DriverDeleteSwitchView extends DriverDeleteAccountEvent {
  final DriverDeleteStatus status;
  const DriverDeleteSwitchView(this.status);

  @override
  List<Object?> get props => [status];
}

class DriverDeleteSelectSafeguardBlock extends DriverDeleteAccountEvent {
  final DriverDeleteSafeguardBlockType blockType;
  const DriverDeleteSelectSafeguardBlock(this.blockType);

  @override
  List<Object?> get props => [blockType];
}

class DriverDeleteToggleTestHold extends DriverDeleteAccountEvent {
  const DriverDeleteToggleTestHold();
}

class DriverDeleteProceedToConfirmation extends DriverDeleteAccountEvent {
  const DriverDeleteProceedToConfirmation();
}

class DriverDeleteCancelRequested extends DriverDeleteAccountEvent {
  const DriverDeleteCancelRequested();
}

class DriverDeleteRestoreAccount extends DriverDeleteAccountEvent {
  const DriverDeleteRestoreAccount();
}

class DriverDeleteGoToActiveTrip extends DriverDeleteAccountEvent {
  const DriverDeleteGoToActiveTrip();
}

class DriverDeleteTriggerSos extends DriverDeleteAccountEvent {
  const DriverDeleteTriggerSos();
}

class DriverDeleteCompleteSignout extends DriverDeleteAccountEvent {
  const DriverDeleteCompleteSignout();
}

class DriverDeleteClearToast extends DriverDeleteAccountEvent {
  const DriverDeleteClearToast();
}
