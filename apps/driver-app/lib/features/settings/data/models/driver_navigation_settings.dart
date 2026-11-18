import 'package:equatable/equatable.dart';

enum DriverNavProvider {
  googleMaps,
  appleMaps,
  waze,
}

extension DriverNavProviderX on DriverNavProvider {
  String get name {
    switch (this) {
      case DriverNavProvider.googleMaps:
        return 'Google Maps';
      case DriverNavProvider.appleMaps:
        return 'Apple Maps';
      case DriverNavProvider.waze:
        return 'Waze';
    }
  }

  String get subtitle {
    switch (this) {
      case DriverNavProvider.googleMaps:
        return 'Live traffic, coulee grade advisories & University Drive transit alerts';
      case DriverNavProvider.appleMaps:
        return 'Integrated iOS voice guidance & lockscreen route widget';
      case DriverNavProvider.waze:
        return 'Community speed trap, animal hazards & construction reports';
    }
  }

  String? get badgeText {
    switch (this) {
      case DriverNavProvider.googleMaps:
        return 'Recommended';
      case DriverNavProvider.appleMaps:
        return 'iOS Only';
      case DriverNavProvider.waze:
        return null;
    }
  }
}

class DriverNavigationSettings extends Equatable {
  final DriverNavProvider provider;
  final bool inAppAudioAlerts;
  final bool autoReturnUponArrival;
  final String fleetGpsStatus;

  const DriverNavigationSettings({
    this.provider = DriverNavProvider.googleMaps,
    this.inAppAudioAlerts = true,
    this.autoReturnUponArrival = true,
    this.fleetGpsStatus = 'Lethbridge Grid Ready',
  });

  DriverNavigationSettings copyWith({
    DriverNavProvider? provider,
    bool? inAppAudioAlerts,
    bool? autoReturnUponArrival,
    String? fleetGpsStatus,
  }) {
    return DriverNavigationSettings(
      provider: provider ?? this.provider,
      inAppAudioAlerts: inAppAudioAlerts ?? this.inAppAudioAlerts,
      autoReturnUponArrival:
          autoReturnUponArrival ?? this.autoReturnUponArrival,
      fleetGpsStatus: fleetGpsStatus ?? this.fleetGpsStatus,
    );
  }

  @override
  List<Object?> get props => [
    provider,
    inAppAudioAlerts,
    autoReturnUponArrival,
    fleetGpsStatus,
  ];
}
