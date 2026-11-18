import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_notification_settings.dart';
import '../data/models/driver_settings_status.dart';
import '../data/repositories/driver_settings_repository.dart';
import 'driver_settings_event.dart';
import 'driver_settings_state.dart';

class DriverSettingsBloc
    extends Bloc<DriverSettingsEvent, DriverSettingsState> {
  final DriverSettingsRepository repository;

  DriverSettingsBloc({required this.repository})
      : super(DriverSettingsState.initial()) {
    on<DriverSettingsStarted>(_onStarted);
    on<DriverSettingsSectionNavigated>(_onSectionNavigated);
    on<DriverSettingsBackToHubPressed>(_onBackToHubPressed);
    on<DriverSettingsNotificationAlertToggled>(_onNotificationAlertToggled);
    on<DriverSettingsChimeSelected>(_onChimeSelected);
    on<DriverSettingsSimulateChimePressed>(_onSimulateChimePressed);
    on<DriverSettingsNavProviderSelected>(_onNavProviderSelected);
    on<DriverSettingsNavSwitchToggled>(_onNavSwitchToggled);
    on<DriverSettingsNavSaved>(_onNavSaved);
    on<DriverSettingsThemeSelected>(_onThemeSelected);
    on<DriverSettingsThemeSwitchToggled>(_onThemeSwitchToggled);
    on<DriverSettingsThemeApplied>(_onThemeApplied);
    on<DriverSettingsInsuranceTabSwitched>(_onInsuranceTabSwitched);
    on<DriverSettingsDownloadPdfPressed>(_onDownloadPdfPressed);
    on<DriverSettingsLogOutPressed>(_onLogOutPressed);
    on<DriverSettingsStateForced>(_onStateForced);
  }

  void _onStarted(
    DriverSettingsStarted event,
    Emitter<DriverSettingsState> emit,
  ) {
    add(DriverSettingsStateForced(event.initialStatus));
  }

  void _onSectionNavigated(
    DriverSettingsSectionNavigated event,
    Emitter<DriverSettingsState> emit,
  ) {
    emit(state.copyWith(status: event.target));
  }

  void _onBackToHubPressed(
    DriverSettingsBackToHubPressed event,
    Emitter<DriverSettingsState> emit,
  ) {
    emit(state.copyWith(status: DriverSettingsStatus.hub));
  }

  void _onNotificationAlertToggled(
    DriverSettingsNotificationAlertToggled event,
    Emitter<DriverSettingsState> emit,
  ) {
    DriverNotificationSettings updated = state.notifications;
    switch (event.alertKey) {
      case 'rideRequests':
        updated = updated.copyWith(rideRequestsAlert: event.value);
        break;
      case 'tripUpdates':
        updated = updated.copyWith(tripUpdatesAlert: event.value);
        break;
      case 'earningsStatements':
        updated = updated.copyWith(earningsStatementsAlert: event.value);
        break;
      case 'promotions':
        updated = updated.copyWith(promotionsAlert: event.value);
        break;
      case 'vibration':
        updated = updated.copyWith(vibrationPattern: event.value);
        break;
    }
    emit(state.copyWith(notifications: updated));
  }

  void _onChimeSelected(
    DriverSettingsChimeSelected event,
    Emitter<DriverSettingsState> emit,
  ) {
    emit(
      state.copyWith(
        notifications: state.notifications.copyWith(selectedChime: event.chime),
      ),
    );
  }

  void _onSimulateChimePressed(
    DriverSettingsSimulateChimePressed event,
    Emitter<DriverSettingsState> emit,
  ) {
    emit(
      state.copyWith(
        feedbackMessage:
            'Playing simulated chime: ${state.notifications.selectedChime.title}',
      ),
    );
  }

  void _onNavProviderSelected(
    DriverSettingsNavProviderSelected event,
    Emitter<DriverSettingsState> emit,
  ) {
    emit(
      state.copyWith(
        navigation: state.navigation.copyWith(provider: event.provider),
      ),
    );
  }

  void _onNavSwitchToggled(
    DriverSettingsNavSwitchToggled event,
    Emitter<DriverSettingsState> emit,
  ) {
    if (event.keyName == 'inAppAudio') {
      emit(
        state.copyWith(
          navigation:
              state.navigation.copyWith(inAppAudioAlerts: event.value),
        ),
      );
    } else if (event.keyName == 'autoReturn') {
      emit(
        state.copyWith(
          navigation:
              state.navigation.copyWith(autoReturnUponArrival: event.value),
        ),
      );
    }
  }

  Future<void> _onNavSaved(
    DriverSettingsNavSaved event,
    Emitter<DriverSettingsState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.saveNavigationSettings(state.navigation);
      emit(
        state.copyWith(
          isActionLoading: false,
          status: DriverSettingsStatus.hub,
          feedbackMessage:
              'Saved navigation preference: ${state.navigation.provider.name}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Failed to save navigation: $e',
        ),
      );
    }
  }

  void _onThemeSelected(
    DriverSettingsThemeSelected event,
    Emitter<DriverSettingsState> emit,
  ) {
    emit(state.copyWith(theme: state.theme.copyWith(mode: event.mode)));
  }

  void _onThemeSwitchToggled(
    DriverSettingsThemeSwitchToggled event,
    Emitter<DriverSettingsState> emit,
  ) {
    if (event.keyName == 'autoDim') {
      emit(
        state.copyWith(
          theme: state.theme.copyWith(autoDimLowBattery: event.value),
        ),
      );
    } else if (event.keyName == 'keepAwake') {
      emit(
        state.copyWith(
          theme: state.theme.copyWith(keepScreenAwakeWhileOnline: event.value),
        ),
      );
    } else if (event.keyName == 'largeFont') {
      emit(
        state.copyWith(
          theme: state.theme.copyWith(largeFontAccessibility: event.value),
        ),
      );
    }
  }

  Future<void> _onThemeApplied(
    DriverSettingsThemeApplied event,
    Emitter<DriverSettingsState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.saveThemeSettings(state.theme);
      emit(
        state.copyWith(
          isActionLoading: false,
          status: DriverSettingsStatus.hub,
          feedbackMessage:
              'Applied interface theme: ${state.theme.mode.title}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Failed to apply theme: $e',
        ),
      );
    }
  }

  void _onInsuranceTabSwitched(
    DriverSettingsInsuranceTabSwitched event,
    Emitter<DriverSettingsState> emit,
  ) {
    emit(state.copyWith(insuranceTabIndex: event.tabIndex));
  }

  Future<void> _onDownloadPdfPressed(
    DriverSettingsDownloadPdfPressed event,
    Emitter<DriverSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        feedbackMessage:
            'Downloading insurance certificate ${state.insurance.policyNumber} (PDF)...',
      ),
    );
  }

  Future<void> _onLogOutPressed(
    DriverSettingsLogOutPressed event,
    Emitter<DriverSettingsState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.logOut();
      emit(
        state.copyWith(
          isActionLoading: false,
          shouldNavigateToLogin: true,
          feedbackMessage: 'Logged out successfully from Lethbridge Fleet.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Failed to log out: $e',
        ),
      );
    }
  }

  void _onStateForced(
    DriverSettingsStateForced event,
    Emitter<DriverSettingsState> emit,
  ) {
    emit(state.copyWith(status: event.status, isActionLoading: false));
  }
}
