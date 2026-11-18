import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/settings/settings.dart';

void main() {
  group('DriverSettingsBloc Tests', () {
    late FakeDriverSettingsRepository repository;
    late DriverSettingsBloc bloc;

    setUp(() {
      repository = FakeDriverSettingsRepository(
        latency: const Duration(milliseconds: 10),
      );
      bloc = DriverSettingsBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to hub with Marcus Vance and Unit #42', () {
      expect(bloc.state.status, DriverSettingsStatus.hub);
      expect(bloc.state.isHub, isTrue);
      expect(bloc.state.driver.driverName, 'Marcus Vance');
      expect(bloc.state.driver.unitNumber, 'UNIT #42');
      expect(bloc.state.driver.statusText, 'AVAILABLE');
      expect(bloc.state.navigation.provider, DriverNavProvider.googleMaps);
      expect(bloc.state.theme.mode, DriverThemeMode.light);
      expect(bloc.state.notifications.activeAlertsCount, 3);
    });

    test('Section navigation transitions to target and back to hub', () {
      bloc.add(const DriverSettingsSectionNavigated(DriverSettingsStatus.notifications));
      expect(bloc.state.status, DriverSettingsStatus.notifications);
      expect(bloc.state.isNotifications, isTrue);

      bloc.add(const DriverSettingsBackToHubPressed());
      expect(bloc.state.status, DriverSettingsStatus.hub);
      expect(bloc.state.isHub, isTrue);
    });

    test('Toggling notification alerts updates settings state', () {
      bloc.add(const DriverSettingsNotificationAlertToggled(
        alertKey: 'promotions',
        value: true,
      ));
      expect(bloc.state.notifications.promotionsAlert, isTrue);
      expect(bloc.state.notifications.activeAlertsCount, 4);
    });

    test('Selecting chime updates selectedChime and simulation triggers feedback', () {
      bloc.add(const DriverSettingsChimeSelected(DriverDispatchChime.lethbridgePulse));
      expect(bloc.state.notifications.selectedChime, DriverDispatchChime.lethbridgePulse);

      bloc.add(const DriverSettingsSimulateChimePressed());
      expect(bloc.state.feedbackMessage, contains('Playing simulated chime: Lethbridge Pulse'));
    });

    test('Navigation provider selection and saving preferences updates state', () async {
      bloc.add(const DriverSettingsNavProviderSelected(DriverNavProvider.waze));
      expect(bloc.state.navigation.provider, DriverNavProvider.waze);

      bloc.add(const DriverSettingsNavSaved());
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.status, DriverSettingsStatus.hub);
      expect(bloc.state.feedbackMessage, contains('Saved navigation preference: Waze'));
    });

    test('Theme mode selection and applying theme updates state', () async {
      bloc.add(const DriverSettingsThemeSelected(DriverThemeMode.dark));
      expect(bloc.state.theme.mode, DriverThemeMode.dark);

      bloc.add(const DriverSettingsThemeApplied());
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.status, DriverSettingsStatus.hub);
      expect(bloc.state.feedbackMessage, contains('Applied interface theme: Dark'));
    });

    test('Insurance tab switching and downloading certificate', () async {
      bloc.add(const DriverSettingsInsuranceTabSwitched(1));
      expect(bloc.state.insuranceTabIndex, 1);

      bloc.add(const DriverSettingsDownloadPdfPressed());
      expect(bloc.state.feedbackMessage, contains('Downloading insurance certificate AB-LCC-9821'));
    });

    test('Log out sets shouldNavigateToLogin', () async {
      bloc.add(const DriverSettingsLogOutPressed());
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.shouldNavigateToLogin, isTrue);
      expect(bloc.state.feedbackMessage, contains('Logged out successfully'));
    });

    test('State forced switches properly between all preset screens', () {
      bloc.add(const DriverSettingsStateForced(DriverSettingsStatus.hub));
      expect(bloc.state.status, DriverSettingsStatus.hub);

      bloc.add(const DriverSettingsStateForced(DriverSettingsStatus.notifications));
      expect(bloc.state.status, DriverSettingsStatus.notifications);

      bloc.add(const DriverSettingsStateForced(DriverSettingsStatus.navigation));
      expect(bloc.state.status, DriverSettingsStatus.navigation);

      bloc.add(const DriverSettingsStateForced(DriverSettingsStatus.theme));
      expect(bloc.state.status, DriverSettingsStatus.theme);

      bloc.add(const DriverSettingsStateForced(DriverSettingsStatus.insurance));
      expect(bloc.state.status, DriverSettingsStatus.insurance);
    });
  });
}
