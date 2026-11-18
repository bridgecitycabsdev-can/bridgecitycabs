import 'package:equatable/equatable.dart';
import '../data/models/driver_insurance_data.dart';
import '../data/models/driver_navigation_settings.dart';
import '../data/models/driver_notification_settings.dart';
import '../data/models/driver_settings_config.dart';
import '../data/models/driver_settings_status.dart';
import '../data/models/driver_theme_settings.dart';

class DriverSettingsState extends Equatable {
  final DriverSettingsStatus status;
  final DriverIdentityData driver;
  final DriverNotificationSettings notifications;
  final DriverNavigationSettings navigation;
  final DriverThemeSettings theme;
  final DriverInsuranceData insurance;
  final int insuranceTabIndex;
  final bool isActionLoading;
  final String? feedbackMessage;
  final bool shouldNavigateToLogin;

  const DriverSettingsState({
    required this.status,
    this.driver = DriverSettingsConfig.defaultDriver,
    this.notifications = DriverSettingsConfig.defaultNotifications,
    this.navigation = DriverSettingsConfig.defaultNavigation,
    this.theme = DriverSettingsConfig.defaultTheme,
    this.insurance = DriverSettingsConfig.defaultInsurance,
    this.insuranceTabIndex = 0,
    this.isActionLoading = false,
    this.feedbackMessage,
    this.shouldNavigateToLogin = false,
  });

  factory DriverSettingsState.initial() {
    return const DriverSettingsState(
      status: DriverSettingsStatus.hub,
      driver: DriverSettingsConfig.defaultDriver,
      notifications: DriverSettingsConfig.defaultNotifications,
      navigation: DriverSettingsConfig.defaultNavigation,
      theme: DriverSettingsConfig.defaultTheme,
      insurance: DriverSettingsConfig.defaultInsurance,
      insuranceTabIndex: 0,
      isActionLoading: false,
      feedbackMessage: null,
      shouldNavigateToLogin: false,
    );
  }

  DriverSettingsState copyWith({
    DriverSettingsStatus? status,
    DriverIdentityData? driver,
    DriverNotificationSettings? notifications,
    DriverNavigationSettings? navigation,
    DriverThemeSettings? theme,
    DriverInsuranceData? insurance,
    int? insuranceTabIndex,
    bool? isActionLoading,
    String? feedbackMessage,
    bool? shouldNavigateToLogin,
  }) {
    return DriverSettingsState(
      status: status ?? this.status,
      driver: driver ?? this.driver,
      notifications: notifications ?? this.notifications,
      navigation: navigation ?? this.navigation,
      theme: theme ?? this.theme,
      insurance: insurance ?? this.insurance,
      insuranceTabIndex: insuranceTabIndex ?? this.insuranceTabIndex,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      feedbackMessage: feedbackMessage,
      shouldNavigateToLogin:
          shouldNavigateToLogin ?? this.shouldNavigateToLogin,
    );
  }

  bool get isHub => status == DriverSettingsStatus.hub;
  bool get isNotifications => status == DriverSettingsStatus.notifications;
  bool get isNavigation => status == DriverSettingsStatus.navigation;
  bool get isTheme => status == DriverSettingsStatus.theme;
  bool get isInsurance => status == DriverSettingsStatus.insurance;
  bool get isFaqs => status == DriverSettingsStatus.faqs;
  bool get isTerms => status == DriverSettingsStatus.terms;

  @override
  List<Object?> get props => [
    status,
    driver,
    notifications,
    navigation,
    theme,
    insurance,
    insuranceTabIndex,
    isActionLoading,
    feedbackMessage,
    shouldNavigateToLogin,
  ];
}
