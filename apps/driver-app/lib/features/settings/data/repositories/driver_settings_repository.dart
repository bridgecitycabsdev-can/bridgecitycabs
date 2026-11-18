import '../models/driver_insurance_data.dart';
import '../models/driver_navigation_settings.dart';
import '../models/driver_notification_settings.dart';
import '../models/driver_settings_config.dart';
import '../models/driver_theme_settings.dart';

abstract class DriverSettingsRepository {
  Future<DriverNotificationSettings> fetchNotificationSettings();
  Future<void> saveNotificationSettings(DriverNotificationSettings settings);

  Future<DriverNavigationSettings> fetchNavigationSettings();
  Future<void> saveNavigationSettings(DriverNavigationSettings settings);

  Future<DriverThemeSettings> fetchThemeSettings();
  Future<void> saveThemeSettings(DriverThemeSettings settings);

  Future<DriverInsuranceData> fetchInsuranceData();
  Future<void> downloadInsurancePdf();

  Future<void> logOut();
}

class FakeDriverSettingsRepository implements DriverSettingsRepository {
  final Duration latency;

  FakeDriverSettingsRepository({
    this.latency = const Duration(milliseconds: 100),
  });

  @override
  Future<DriverNotificationSettings> fetchNotificationSettings() async {
    await Future.delayed(latency);
    return DriverSettingsConfig.defaultNotifications;
  }

  @override
  Future<void> saveNotificationSettings(
      DriverNotificationSettings settings) async {
    await Future.delayed(latency);
  }

  @override
  Future<DriverNavigationSettings> fetchNavigationSettings() async {
    await Future.delayed(latency);
    return DriverSettingsConfig.defaultNavigation;
  }

  @override
  Future<void> saveNavigationSettings(
      DriverNavigationSettings settings) async {
    await Future.delayed(latency);
  }

  @override
  Future<DriverThemeSettings> fetchThemeSettings() async {
    await Future.delayed(latency);
    return DriverSettingsConfig.defaultTheme;
  }

  @override
  Future<void> saveThemeSettings(DriverThemeSettings settings) async {
    await Future.delayed(latency);
  }

  @override
  Future<DriverInsuranceData> fetchInsuranceData() async {
    await Future.delayed(latency);
    return DriverSettingsConfig.defaultInsurance;
  }

  @override
  Future<void> downloadInsurancePdf() async {
    await Future.delayed(latency);
  }

  @override
  Future<void> logOut() async {
    await Future.delayed(latency);
  }
}
