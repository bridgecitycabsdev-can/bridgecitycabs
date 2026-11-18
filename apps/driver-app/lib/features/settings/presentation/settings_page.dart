import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/driver_settings_status.dart';
import '../../data/repositories/driver_settings_repository.dart';
import '../bloc/driver_settings_bloc.dart';
import '../bloc/driver_settings_event.dart';
import '../bloc/driver_settings_state.dart';
import 'widgets/driver_insurance_view.dart';
import 'widgets/driver_navigation_view.dart';
import 'widgets/driver_notifications_view.dart';
import 'widgets/driver_settings_hub_view.dart';
import 'widgets/driver_settings_qa_bar.dart';
import 'widgets/driver_theme_view.dart';

class DriverSettingsPage extends StatelessWidget {
  final DriverSettingsStatus initialStatus;
  final DriverSettingsRepository? repository;

  const DriverSettingsPage({
    super.key,
    this.initialStatus = DriverSettingsStatus.hub,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverSettingsBloc>(
      create: (_) => DriverSettingsBloc(
        repository: repository ?? FakeDriverSettingsRepository(),
      )..add(DriverSettingsStarted(initialStatus: initialStatus)),
      child: const _DriverSettingsContent(),
    );
  }
}

class _DriverSettingsContent extends StatelessWidget {
  const _DriverSettingsContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverSettingsBloc, DriverSettingsState>(
      listenWhen: (prev, curr) =>
          prev.feedbackMessage != curr.feedbackMessage &&
          curr.feedbackMessage != null,
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF222831),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state.shouldNavigateToLogin && context.mounted) {
          context.go('/phone');
        }
      },
      builder: (context, state) {
        final bloc = context.read<DriverSettingsBloc>();

        Widget body;
        if (state.isNotifications) {
          body = DriverNotificationsView(
            settings: state.notifications,
            onToggleAlert: (key, val) => bloc.add(
              DriverSettingsNotificationAlertToggled(
                alertKey: key,
                value: val,
              ),
            ),
            onSelectChime: (chime) =>
                bloc.add(DriverSettingsChimeSelected(chime)),
            onSimulateChime: () =>
                bloc.add(const DriverSettingsSimulateChimePressed()),
          );
        } else if (state.isNavigation) {
          body = DriverNavigationView(
            settings: state.navigation,
            onSelectProvider: (provider) =>
                bloc.add(DriverSettingsNavProviderSelected(provider)),
            onToggleSwitch: (key, val) => bloc.add(
              DriverSettingsNavSwitchToggled(keyName: key, value: val),
            ),
            onSave: () => bloc.add(const DriverSettingsNavSaved()),
          );
        } else if (state.isTheme) {
          body = DriverThemeView(
            settings: state.theme,
            onSelectMode: (mode) =>
                bloc.add(DriverSettingsThemeSelected(mode)),
            onToggleSwitch: (key, val) => bloc.add(
              DriverSettingsThemeSwitchToggled(keyName: key, value: val),
            ),
            onApplyTheme: () =>
                bloc.add(const DriverSettingsThemeApplied()),
          );
        } else if (state.isInsurance || state.isFaqs || state.isTerms) {
          body = DriverInsuranceView(
            insurance: state.insurance,
            activeTabIndex: state.insuranceTabIndex,
            onTabSwitched: (tab) =>
                bloc.add(DriverSettingsInsuranceTabSwitched(tab)),
            onContactDispatch: () {},
            onDownloadPdf: () =>
                bloc.add(const DriverSettingsDownloadPdfPressed()),
          );
        } else {
          body = DriverSettingsHubView(
            driver: state.driver,
            navProvider: state.navigation.provider,
            themeMode: state.theme.mode,
            onNavigate: (target) =>
                bloc.add(DriverSettingsSectionNavigated(target)),
            onLogOut: () => bloc.add(const DriverSettingsLogOutPressed()),
          );
        }

        return Column(
          children: [
            // Top QA Switcher Bar
            DriverSettingsQABar(
              currentStatus: state.status,
              onStatusSelected: (status) =>
                  bloc.add(DriverSettingsStateForced(status)),
            ),

            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0xFFFBF8F8),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1E1E1E),
                    ),
                    onPressed: () {
                      if (!state.isHub) {
                        bloc.add(const DriverSettingsBackToHubPressed());
                      } else if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  title: const Text(
                    'Driver Settings Hub',
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: GestureDetector(
                        onTap: () {
                          if (context.mounted) {
                            context.go('/profile');
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B0000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                body: body,
              ),
            ),
          ],
        );
      },
    );
  }
}
