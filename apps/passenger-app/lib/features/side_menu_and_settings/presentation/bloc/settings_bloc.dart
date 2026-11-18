import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(const SettingsState()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsPushToggleChanged>(_onPushToggleChanged);
    on<SettingsOpenSystemSettingsTapped>(_onOpenSystemSettingsTapped);
    on<SettingsSearchChanged>(_onSearchChanged);
    on<SettingsCategorySelected>(_onCategorySelected);
    on<SettingsFaqItemToggled>(_onFaqItemToggled);
    on<SettingsContactSupportTapped>(_onContactSupportTapped);
    on<SettingsLogoutTapped>(_onLogoutTapped);
    on<SettingsNavigationTapped>(_onNavigationTapped);
  }

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    final push = await repository.getPushNotificationsEnabled();
    final systemDisabled = await repository.isSystemNotificationsDisabled();
    final faqs = await repository.getFaqs();

    emit(state.copyWith(
      pushNotificationsEnabled: push,
      systemNotificationsDisabled: systemDisabled,
      faqs: faqs,
    ));
  }

  Future<void> _onPushToggleChanged(
    SettingsPushToggleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setPushNotificationsEnabled(event.enabled);
    emit(state.copyWith(
      pushNotificationsEnabled: event.enabled,
      feedbackMessage: () =>
          'Push notifications ${event.enabled ? 'enabled' : 'disabled'}',
    ));
  }

  void _onOpenSystemSettingsTapped(
    SettingsOpenSystemSettingsTapped event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening device notification settings...',
    ));
  }

  Future<void> _onSearchChanged(
    SettingsSearchChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final faqs = await repository.getFaqs(
      query: event.query,
      category: state.selectedCategory,
    );
    emit(state.copyWith(
      searchQuery: event.query,
      faqs: faqs,
    ));
  }

  Future<void> _onCategorySelected(
    SettingsCategorySelected event,
    Emitter<SettingsState> emit,
  ) async {
    final faqs = await repository.getFaqs(
      query: state.searchQuery,
      category: event.category,
    );
    emit(state.copyWith(
      selectedCategory: event.category,
      faqs: faqs,
    ));
  }

  void _onFaqItemToggled(
    SettingsFaqItemToggled event,
    Emitter<SettingsState> emit,
  ) {
    final nextExpanded = Set<String>.from(state.expandedFaqIds);
    if (nextExpanded.contains(event.faqId)) {
      nextExpanded.remove(event.faqId);
    } else {
      nextExpanded.add(event.faqId);
    }
    emit(state.copyWith(expandedFaqIds: nextExpanded));
  }

  void _onContactSupportTapped(
    SettingsContactSupportTapped event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      navigationTarget: () => '/support',
      feedbackMessage: () => 'Connecting to 24/7 Lethbridge dispatch support...',
    ));
  }

  void _onLogoutTapped(
    SettingsLogoutTapped event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      navigationTarget: () => '/phone',
      feedbackMessage: () => 'Logged out successfully',
    ));
  }

  void _onNavigationTapped(
    SettingsNavigationTapped event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      navigationTarget: () => event.route,
    ));
  }
}
