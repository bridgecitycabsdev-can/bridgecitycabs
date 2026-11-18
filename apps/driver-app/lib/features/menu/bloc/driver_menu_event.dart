import 'package:equatable/equatable.dart';
import '../data/models/driver_menu_item.dart';
import '../data/models/driver_menu_status.dart';

abstract class DriverMenuEvent extends Equatable {
  const DriverMenuEvent();

  @override
  List<Object?> get props => [];
}

class DriverMenuStarted extends DriverMenuEvent {
  final DriverMenuStatus initialStatus;

  const DriverMenuStarted({
    this.initialStatus = DriverMenuStatus.online,
  });

  @override
  List<Object?> get props => [initialStatus];
}

class DriverMenuItemSelected extends DriverMenuEvent {
  final DriverMenuItemId itemId;

  const DriverMenuItemSelected(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class DriverMenuLogoutPressed extends DriverMenuEvent {
  const DriverMenuLogoutPressed();
}

class DriverMenuLogoutConfirmed extends DriverMenuEvent {
  const DriverMenuLogoutConfirmed();
}

class DriverMenuLogoutCancelled extends DriverMenuEvent {
  const DriverMenuLogoutCancelled();
}

class DriverMenuContactSupportPressed extends DriverMenuEvent {
  const DriverMenuContactSupportPressed();
}

class DriverMenuCallHubPressed extends DriverMenuEvent {
  const DriverMenuCallHubPressed();
}

class DriverMenuDrawerClosed extends DriverMenuEvent {
  const DriverMenuDrawerClosed();
}

class DriverMenuStateForced extends DriverMenuEvent {
  final DriverMenuStatus status;

  const DriverMenuStateForced(this.status);

  @override
  List<Object?> get props => [status];
}
