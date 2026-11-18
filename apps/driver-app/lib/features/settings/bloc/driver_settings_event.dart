import 'package:equatable/equatable.dart';
import '../data/models/driver_navigation_settings.dart';
import '../data/models/driver_notification_settings.dart';
import '../data/models/driver_settings_status.dart';
import '../data/models/driver_theme_settings.dart';

abstract class DriverSettingsEvent extends Equatable {
  const DriverSettingsEvent();

  @override
  List<Object?> get props => [];
}

class DriverSettingsStarted extends DriverSettingsEvent {
  final DriverSettingsStatus initialStatus;

  const DriverSettingsStarted({
    this.initialStatus = DriverSettingsStatus.hub,
  });

  @override
  List<Object?> get props => [initialStatus];
}

class DriverSettingsSectionNavigated extends DriverSettingsEvent {
  final DriverSettingsStatus target;

  const DriverSettingsSectionNavigated(this.target);

  @override
  List<Object?> get props => [target];
}

class DriverSettingsBackToHubPressed extends DriverSettingsEvent {
  const DriverSettingsBackToHubPressed();
}

class DriverSettingsNotificationAlertToggled extends DriverSettingsEvent {
  final String alertKey;
  final bool value;

  const DriverSettingsNotificationAlertToggled({
    required this.alertKey,
    required this.value,
  });

  @override
  List<Object?> get props => [alertKey, value];
}

class DriverSettingsChimeSelected extends DriverSettingsEvent {
  final DriverDispatchChime chime;

  const DriverSettingsChimeSelected(this.chime);

  @override
  List<Object?> get props => [chime];
}

class DriverSettingsSimulateChimePressed extends DriverSettingsEvent {
  const DriverSettingsSimulateChimePressed();
}

class DriverSettingsNavProviderSelected extends DriverSettingsEvent {
  final DriverNavProvider provider;

  const DriverSettingsNavProviderSelected(this.provider);

  @override
  List<Object?> get props => [provider];
}

class DriverSettingsNavSwitchToggled extends DriverSettingsEvent {
  final String keyName;
  final bool value;

  const DriverSettingsNavSwitchToggled({
    required this.keyName,
    required this.value,
  });

  @override
  List<Object?> get props => [keyName, value];
}

class DriverSettingsNavSaved extends DriverSettingsEvent {
  const DriverSettingsNavSaved();
}

class DriverSettingsThemeSelected extends DriverSettingsEvent {
  final DriverThemeMode mode;

  const DriverSettingsThemeSelected(this.mode);

  @override
  List<Object?> get props => [mode];
}

class DriverSettingsThemeSwitchToggled extends DriverSettingsEvent {
  final String keyName;
  final bool value;

  const DriverSettingsThemeSwitchToggled({
    required this.keyName,
    required this.value,
  });

  @override
  List<Object?> get props => [keyName, value];
}

class DriverSettingsThemeApplied extends DriverSettingsEvent {
  const DriverSettingsThemeApplied();
}

class DriverSettingsInsuranceTabSwitched extends DriverSettingsEvent {
  final int tabIndex;

  const DriverSettingsInsuranceTabSwitched(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class DriverSettingsDownloadPdfPressed extends DriverSettingsEvent {
  const DriverSettingsDownloadPdfPressed();
}

class DriverSettingsLogOutPressed extends DriverSettingsEvent {
  const DriverSettingsLogOutPressed();
}

class DriverSettingsStateForced extends DriverSettingsEvent {
  final DriverSettingsStatus status;

  const DriverSettingsStateForced(this.status);

  @override
  List<Object?> get props => [status];
}
