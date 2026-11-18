import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/models/profile_config.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../widgets/lethbridge_dispatch_info_card.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/settings_preferences_section.dart';
import '../widgets/settings_profile_header.dart';
import 'privacy_policy_page.dart';

class SettingsPage extends StatelessWidget {
  final ProfileRepository? repository;
  final UserProfile? initialUser;

  const SettingsPage({
    super.key,
    this.repository,
    this.initialUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = repository ??
            MockProfileRepository(
              initialUser: initialUser ?? ProfileConfig.settingsProfile,
            );
        return ProfileBloc(repository: repo)
          ..add(ProfileStarted(
            initialProfile: initialUser ?? ProfileConfig.settingsProfile,
          ));
      },
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  void _showEditProfileDialog(BuildContext context, UserProfile user) {
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(
                    ProfileSaveEditedProfile(
                      fullName: nameController.text,
                      email: emailController.text,
                    ),
                  );
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF881337),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (state.isLoggedOut) {
          context.go('/phone');
        }
      },
      builder: (context, state) {
        final bloc = context.read<ProfileBloc>();
        final user = state.user;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: ProfileAppBar(
            title: 'Settings',
            onBack: () => Navigator.of(context).maybePop(),
            onCarTapped: () => context.go('/home'),
            onProfileTapped: () => context.push('/profile'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  SettingsProfileHeader(
                    user: user,
                    onEdit: () => _showEditProfileDialog(context, user),
                  ),
                  SettingsPreferencesSection(
                    notificationsEnabled: state.isNotificationsEnabled,
                    onNotificationToggle: (enabled) =>
                        bloc.add(ProfileNotificationToggleTapped(enabled)),
                    onFaq: () => bloc.add(const ProfileOpenFaqTapped()),
                    onTerms: () => bloc.add(const ProfileOpenTermsTapped()),
                    onPrivacyPolicy: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: const PrivacyPolicyPage(),
                        ),
                      ),
                    ),
                    onBecomeDriver: () =>
                        bloc.add(const ProfileBecomeDriverTapped()),
                    onAbout: () => bloc.add(const ProfileAboutTapped()),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => context.push('/delete-account'),
                        child: const Text('Delete account'),
                      ),
                    ),
                  ),

                  // Solid Red Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: state.status == ProfileStatus.loggingOut
                            ? null
                            : () => bloc.add(const ProfileLogoutTapped()),
                        icon: const Icon(
                          Icons.logout,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          state.status == ProfileStatus.loggingOut
                              ? 'Logging out...'
                              : 'Log out',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB91C1C),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    ),
                  ),

                  LethbridgeDispatchInfoCard(
                    onCallRegionalDispatch: () =>
                        bloc.add(const ProfileCallRegionalDispatchTapped()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
