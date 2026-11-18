import 'package:equatable/equatable.dart';

enum DriverThemeMode {
  light,
  dark,
  system,
}

extension DriverThemeModeX on DriverThemeMode {
  String get title {
    switch (this) {
      case DriverThemeMode.light:
        return 'Light';
      case DriverThemeMode.dark:
        return 'Dark';
      case DriverThemeMode.system:
        return 'System';
    }
  }

  String get subtitle {
    switch (this) {
      case DriverThemeMode.light:
        return 'Day cockpit';
      case DriverThemeMode.dark:
        return 'Night shift';
      case DriverThemeMode.system:
        return 'Auto-synced';
    }
  }
}

class DriverThemeSettings extends Equatable {
  final DriverThemeMode mode;
  final bool autoDimLowBattery;
  final bool keepScreenAwakeWhileOnline;
  final bool largeFontAccessibility;

  const DriverThemeSettings({
    this.mode = DriverThemeMode.light,
    this.autoDimLowBattery = true,
    this.keepScreenAwakeWhileOnline = true,
    this.largeFontAccessibility = false,
  });

  DriverThemeSettings copyWith({
    DriverThemeMode? mode,
    bool? autoDimLowBattery,
    bool? keepScreenAwakeWhileOnline,
    bool? largeFontAccessibility,
  }) {
    return DriverThemeSettings(
      mode: mode ?? this.mode,
      autoDimLowBattery: autoDimLowBattery ?? this.autoDimLowBattery,
      keepScreenAwakeWhileOnline:
          keepScreenAwakeWhileOnline ?? this.keepScreenAwakeWhileOnline,
      largeFontAccessibility:
          largeFontAccessibility ?? this.largeFontAccessibility,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    autoDimLowBattery,
    keepScreenAwakeWhileOnline,
    largeFontAccessibility,
  ];
}
