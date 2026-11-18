import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/profile_setup_bloc.dart';
import '../bloc/profile_setup_event.dart';
import '../bloc/profile_setup_state.dart';
import '../../data/models/canadian_postal_code.dart';
import '../../data/models/passenger_profile.dart';
import '../../data/models/profile_setup_config.dart';
import '../../data/repositories/profile_setup_repository.dart';
import '../widgets/gender_selector.dart';
import '../widgets/profile_form_field.dart';
import '../widgets/profile_photo_picker.dart';
import '../widgets/profile_readiness_card.dart';
import '../widgets/profile_step_progress_bar.dart';
import '../widgets/profile_top_error_banner.dart';

/// Entry page for the passenger account setup / profile completion flow.
class ProfileSetupPage extends StatelessWidget {
  final ProfileSetupRepository? repository;
  final PassengerProfile? initialProfile;

  const ProfileSetupPage({
    super.key,
    this.repository,
    this.initialProfile,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileSetupBloc(
        repository: repository ?? ProfileSetupRepositoryImpl(),
        initialProfile: initialProfile,
      )..add(ProfileSetupStarted(initialProfile: initialProfile)),
      child: const _ProfileSetupView(),
    );
  }
}

class _ProfileSetupView extends StatelessWidget {
  const _ProfileSetupView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileSetupBloc, ProfileSetupState>(
      listener: (context, state) {
        if (state.targetRoute != null) {
          context.go(state.targetRoute!);
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        final isValid = state.isValid;
        final isSubmitting = state.isSubmitting;
        final hasErrors = state.hasErrors && state.hasAttemptedSubmit;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar
                    _buildTopAppBar(context),
                    const SizedBox(height: 8),

                    // Validation Error Banner (Screen 3)
                    if (hasErrors) ...[
                      ProfileTopErrorBanner(errorCount: state.errorCount),
                      const SizedBox(height: 16),
                    ],

                    // Step Tracker: ONBOARDING • Step 2 of 3
                    const ProfileStepProgressBar(currentStep: 2, totalSteps: 3),
                    const SizedBox(height: 18),

                    // Headline & Intro
                    const Text(
                      ProfileSetupConfig.headline,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      ProfileSetupConfig.introNotice,
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile Photo Picker
                    ProfilePhotoPicker(
                      photoUrl: profile.photoUrl,
                      onTap: () {
                        // Toggle sample photo or pick from device
                        final sample = profile.hasPhoto
                            ? null
                            : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200';
                        context
                            .read<ProfileSetupBloc>()
                            .add(ProfilePhotoChanged(sample));
                      },
                    ),
                    const SizedBox(height: 22),

                    // First & Last Name Fields Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ProfileFormField(
                            label: '${ProfileSetupConfig.firstNameLabel} *',
                            initialValue: profile.firstName,
                            errorMessage: state.firstNameError,
                            isValid: profile.firstName.trim().isNotEmpty,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              context
                                  .read<ProfileSetupBloc>()
                                  .add(ProfileFirstNameChanged(val));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ProfileFormField(
                            label: '${ProfileSetupConfig.lastNameLabel} *',
                            placeholder: ProfileSetupConfig.lastNamePlaceholder,
                            initialValue: profile.lastName,
                            errorMessage: state.lastNameError,
                            statusTag: state.lastNameError != null
                                ? ProfileSetupConfig.requiredTag
                                : null,
                            statusTagColor: const Color(0xFFB71C1C),
                            isValid: profile.lastName.trim().isNotEmpty,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              context
                                  .read<ProfileSetupBloc>()
                                  .add(ProfileLastNameChanged(val));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Institutional or Personal Email Field
                    ProfileFormField(
                      label: '${ProfileSetupConfig.emailLabel} *',
                      placeholder: 'e.g. sarah.mitchell@uleth.ca',
                      initialValue: profile.email,
                      prefixIcon: Icons.mail_outline_rounded,
                      statusTag: profile.verifiedInstitutionTag,
                      statusTagColor: const Color(0xFF059669),
                      errorMessage: state.emailError,
                      isValid: RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
                          .hasMatch(profile.email.trim()),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        context
                            .read<ProfileSetupBloc>()
                            .add(ProfileEmailChanged(val));
                      },
                    ),
                    const SizedBox(height: 14),

                    // Home Postal Code Field (Canadian format e.g. T1K 4A8)
                    ProfileFormField(
                      label: '${ProfileSetupConfig.postalCodeLabel} *',
                      placeholder: ProfileSetupConfig.postalCodeExample,
                      initialValue: profile.postalCode,
                      prefixIcon: Icons.location_on_outlined,
                      statusTag: profile.neighborhoodTag,
                      statusTagColor: const Color(0xFF6B7280),
                      errorMessage: state.postalCodeError,
                      isValid: CanadianPostalCode.isValid(profile.postalCode),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (val) {
                        context
                            .read<ProfileSetupBloc>()
                            .add(ProfilePostalCodeChanged(val));
                      },
                    ),
                    const SizedBox(height: 14),

                    // Gender Identification Selector
                    GenderSelector(
                      selectedGender: profile.gender,
                      onGenderSelected: (gender) {
                        context
                            .read<ProfileSetupBloc>()
                            .add(ProfileGenderChanged(gender));
                      },
                    ),
                    const SizedBox(height: 20),

                    // Readiness Celebration Card (Screen 2)
                    if (isValid) ...[
                      const ProfileReadinessCard(),
                      const SizedBox(height: 20),
                    ],

                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                context
                                    .read<ProfileSetupBloc>()
                                    .add(const ProfileSubmitRequested());
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isValid
                              ? const Color(0xFFB71C1C)
                              : const Color(0xFFE5E7EB),
                          elevation: isValid ? 3 : 0,
                          shadowColor: const Color(0xFFB71C1C).withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isValid
                                        ? ProfileSetupConfig.continueToRideOptions
                                        : ProfileSetupConfig.continueButton,
                                    style: TextStyle(
                                      color: isValid
                                          ? Colors.white
                                          : const Color(0xFF9CA3AF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: isValid
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF),
                                    size: 18,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secondary "Skip for now" Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context
                              .read<ProfileSetupBloc>()
                              .add(const ProfileSkipRequested());
                        },
                        child: const Text(
                          ProfileSetupConfig.skipForNow,
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Security Footer Note
                    const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 12,
                          ),
                          SizedBox(width: 6),
                          Text(
                            ProfileSetupConfig.securityNote,
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => context.pop(),
        ),
        const Text(
          ProfileSetupConfig.appBarTitle,
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF880E14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
}
