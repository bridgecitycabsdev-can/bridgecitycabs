import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/repositories/profile_repository.dart';
import '../widgets/privacy_data_policy_card.dart';
import '../widgets/profile_app_bar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final ProfileRepository? repository;

  const PrivacyPolicyPage({
    super.key,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<ProfileBloc>();
      return const _PrivacyPolicyView();
    } catch (_) {
      return BlocProvider(
        create: (context) => ProfileBloc(
          repository: repository ?? MockProfileRepository(),
        )..add(const ProfileStarted()),
        child: const _PrivacyPolicyView(),
      );
    }
  }
}

class _PrivacyPolicyView extends StatelessWidget {
  const _PrivacyPolicyView();

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
      },
      builder: (context, state) {
        final bloc = context.read<ProfileBloc>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: ProfileAppBar(
            title: 'Privacy And Data',
            onBack: () => Navigator.of(context).maybePop(),
            onCarTapped: () => context.go('/home'),
            onProfileTapped: () => context.push('/profile'),
          ),
          body: SafeArea(
            child: PrivacyDataPolicyCard(
              onReadPrivacyPolicy: () =>
                  bloc.add(const ProfileOpenPrivacyTapped()),
              onReadTerms: () => bloc.add(const ProfileOpenTermsTapped()),
            ),
          ),
        );
      },
    );
  }
}
