import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/models/profile_config.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../widgets/account_credentials_card.dart';
import '../widgets/preferences_security_section.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_avatar_header.dart';
import 'privacy_policy_page.dart';

class ProfilePage extends StatelessWidget {
  final ProfileRepository? repository;
  final UserProfile? initialUser;

  const ProfilePage({
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
              initialUser: initialUser ?? ProfileConfig.defaultProfile,
            );
        return ProfileBloc(repository: repo)
          ..add(ProfileStarted(initialProfile: initialUser));
      },
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

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
          backgroundColor: Colors.white,
          appBar: ProfileAppBar(
            title: 'Profile',
            onBack: () => Navigator.of(context).maybePop(),
            onCarTapped: () => context.go('/home'),
            onProfileTapped: () {},
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  ProfileAvatarHeader(user: user),
                  AccountCredentialsCard(
                    user: user,
                    onContactSupport: () => context.push('/support'),
                  ),
                  PreferencesSecuritySection(
                    user: user,
                    onPaymentMethods: () => context.push('/payment-methods'),
                    onNotifications: () => context.push('/notifications'),
                    onPrivacyAndData: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: const PrivacyPolicyPage(),
                        ),
                      ),
                    ),
                  ),

                  // Soft Red Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: state.status == ProfileStatus.loggingOut
                            ? null
                            : () => bloc.add(const ProfileLogoutTapped()),
                        icon: const Icon(
                          Icons.logout,
                          size: 18,
                          color: Color(0xFF991B1B),
                        ),
                        label: Text(
                          state.status == ProfileStatus.loggingOut
                              ? 'Logging out...'
                              : 'Log out',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFE4E6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // App Version
                  const Text(
                    ProfileConfig.appVersion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
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
