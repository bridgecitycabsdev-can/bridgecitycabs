import 'driver_insurance_data.dart';
import 'driver_navigation_settings.dart';
import 'driver_notification_settings.dart';
import 'driver_theme_settings.dart';

class DriverIdentityData {
  final String driverName;
  final String unitNumber;
  final String statusText;
  final String city;
  final String shiftTime;

  const DriverIdentityData({
    this.driverName = 'Marcus Vance',
    this.unitNumber = 'UNIT #42',
    this.statusText = 'AVAILABLE',
    this.city = 'Lethbridge, AB',
    this.shiftTime = 'Shift: 4h 12m',
  });
}

class DriverSettingsConfig {
  static const DriverIdentityData defaultDriver = DriverIdentityData();
  static const DriverNotificationSettings defaultNotifications =
      DriverNotificationSettings();
  static const DriverNavigationSettings defaultNavigation =
      DriverNavigationSettings();
  static const DriverThemeSettings defaultTheme = DriverThemeSettings();
  static const DriverInsuranceData defaultInsurance = DriverInsuranceData();

  static const String appVersion =
      'Version 1.0.32 (Build 402) • Lethbridge Fleet Unit #42';
  static const String regulationNotice =
      'City of Lethbridge Taxi Commission Regulated';
}
