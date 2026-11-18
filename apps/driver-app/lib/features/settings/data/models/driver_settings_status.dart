enum DriverSettingsStatus {
  hub,
  notifications,
  navigation,
  theme,
  insurance,
  faqs,
  terms,
}

extension DriverSettingsStatusX on DriverSettingsStatus {
  String get label {
    switch (this) {
      case DriverSettingsStatus.hub:
        return '1. Settings Hub';
      case DriverSettingsStatus.notifications:
        return '2. Notifications';
      case DriverSettingsStatus.navigation:
        return '3. Navigation GPS';
      case DriverSettingsStatus.theme:
        return '4. Theme & Ergonomics';
      case DriverSettingsStatus.insurance:
        return '5. Insurance & Legal';
      case DriverSettingsStatus.faqs:
        return '6. FAQs';
      case DriverSettingsStatus.terms:
        return '7. Terms & Conditions';
    }
  }
}
