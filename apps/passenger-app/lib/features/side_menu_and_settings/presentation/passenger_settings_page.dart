import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/settings_repository.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/settings_event.dart';
import 'bloc/settings_state.dart';
import 'widgets/side_menu_app_bar.dart';
import 'widgets/preferences_alerts_section.dart';
import 'widgets/help_legal_section.dart';
import 'widgets/frequently_asked_questions_section.dart';
import 'widgets/about_bridge_city_card.dart';
import 'widgets/contact_support_and_logout_card.dart';

class PassengerSettingsPage extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onProfileTapped;
  final ValueChanged<String>? onNavigate;

  const PassengerSettingsPage({
    super.key,
    this.onBack,
    this.onProfileTapped,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(
        repository: SettingsRepositoryImpl(),
      )..add(const SettingsStarted()),
      child: SettingsView(
        onBack: onBack,
        onProfileTapped: onProfileTapped,
        onNavigate: onNavigate,
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onProfileTapped;
  final ValueChanged<String>? onNavigate;

  const SettingsView({
    super.key,
    this.onBack,
    this.onProfileTapped,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF1F2937),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: SideMenuAppBar(
            title: 'Settings',
            onBack: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            onProfileTapped: () {
              if (onProfileTapped != null) {
                onProfileTapped!();
              } else {
                onNavigate?.call('profile');
              }
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preferences & Alerts (Push toggle + Yellow system warning)
                PreferencesAlertsSection(
                  pushNotificationsEnabled: state.pushNotificationsEnabled,
                  showSystemWarningAlert: state.showSystemWarningAlert,
                  onPushToggle: (value) {
                    context.read<SettingsBloc>().add(SettingsPushToggleChanged(value));
                  },
                  onOpenSystemSettings: () {
                    context.read<SettingsBloc>().add(const SettingsOpenSystemSettingsTapped());
                  },
                ),
                const SizedBox(height: 16),

                // Help & Legal
                HelpLegalSection(
                  onTileTapped: (id) {
                    context.read<SettingsBloc>().add(SettingsNavigationTapped(id));
                    onNavigate?.call(id);
                  },
                ),
                const SizedBox(height: 16),

                // Frequently Asked Questions (with Search, Filter chips, and Metered Rate Box)
                FrequentlyAskedQuestionsSection(
                  searchQuery: state.searchQuery,
                  selectedCategory: state.selectedCategory,
                  faqs: state.filteredFaqs,
                  expandedFaqIds: state.expandedFaqIds,
                  onSearchChanged: (query) {
                    context.read<SettingsBloc>().add(SettingsSearchChanged(query));
                  },
                  onCategorySelected: (cat) {
                    context.read<SettingsBloc>().add(SettingsCategorySelected(cat));
                  },
                  onFaqToggled: (faqId) {
                    context.read<SettingsBloc>().add(SettingsFaqItemToggled(faqId));
                  },
                ),
                const SizedBox(height: 16),

                // About Bridge City Cabs (Address, Phone, Web)
                const AboutBridgeCityCard(),
                const SizedBox(height: 20),

                // Contact support, Logout, Version footer
                ContactSupportAndLogoutCard(
                  onContactSupport: () {
                    context.read<SettingsBloc>().add(const SettingsContactSupportTapped());
                    onNavigate?.call('support');
                  },
                  onLogout: () {
                    context.read<SettingsBloc>().add(const SettingsLogoutTapped());
                  },
                  versionText: 'Version 1.0.19 (Build 240) • Made in Alberta',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
