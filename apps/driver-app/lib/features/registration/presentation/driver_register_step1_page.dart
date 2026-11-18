import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_register_step1_bloc.dart';
import '../bloc/driver_register_step1_event.dart';
import '../bloc/driver_register_step1_state.dart';
import '../data/models/driver_register_config.dart';
import '../data/models/driver_register_step1_data.dart';
import '../data/models/driver_register_step1_status.dart';
import 'widgets/driver_register_gender_selector.dart';
import 'widgets/driver_register_photo_modal.dart';
import 'widgets/driver_register_photo_picker.dart';
import 'widgets/driver_register_qa_matrix_bar.dart';
import 'widgets/driver_register_regulatory_card.dart';
import 'widgets/driver_register_step_indicator.dart';
import 'widgets/driver_register_text_field.dart';

class DriverRegisterStep1Page extends StatelessWidget {
  final DriverRegisterStep1Status? initialStatus;
  final bool showQaToolbar;

  const DriverRegisterStep1Page({
    super.key,
    this.initialStatus,
    this.showQaToolbar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = DriverRegisterStep1Bloc();
        bloc.add(DriverRegisterStep1Started(
          initialStatus: initialStatus ?? DriverRegisterStep1Status.initial,
        ));
        return bloc;
      },
      child: DriverRegisterStep1View(showQaToolbar: showQaToolbar),
    );
  }
}

class DriverRegisterStep1View extends StatelessWidget {
  final bool showQaToolbar;

  const DriverRegisterStep1View({
    super.key,
    required this.showQaToolbar,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverRegisterStep1Bloc, DriverRegisterStep1State>(
      listenWhen: (previous, current) =>
          previous.feedbackMessage != current.feedbackMessage ||
          previous.status != current.status,
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1F2937),
            ),
          );
        }

        if (state.status == DriverRegisterStep1Status.success) {
          // Transition to Step 2 (Vehicle Details)
          // Can route to /register-step-2 or /home for now
        }
      },
      builder: (context, state) {
        final data = state.data;
        final isValid = state.status == DriverRegisterStep1Status.valid;
        final isInvalid = state.status == DriverRegisterStep1Status.invalid;
        final isInitial = state.status == DriverRegisterStep1Status.initial;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                }
              },
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF111827),
                size: 22,
              ),
            ),
            title: const Text(
              DriverRegisterConfig.screenTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF991B1B),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QA Matrix bar for 1-click state switching
                      if (showQaToolbar) ...[
                        DriverRegisterQaMatrixBar(
                          currentStatus: state.status,
                          onSelectStatus: (status) {
                            context
                                .read<DriverRegisterStep1Bloc>()
                                .add(DriverRegisterStateSwitched(status));
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 4-Segment Step Indicator
                      DriverRegisterStepIndicator(status: state.status),
                      const SizedBox(height: 18),

                      // Profile Photo Picker
                      Center(
                        child: DriverRegisterPhotoPicker(
                          hasPhoto: data.hasPhoto,
                          photoUrl: data.photoUrl,
                          photoError: state.photoError,
                          onTap: () {
                            context
                                .read<DriverRegisterStep1Bloc>()
                                .add(const DriverRegisterPhotoModalOpened());
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // First & Last Name
                      if (isValid || isInvalid) ...[
                        Row(
                          children: [
                            Expanded(
                              child: DriverRegisterTextField(
                                label: DriverRegisterConfig.firstNameLabel,
                                icon: Icons.badge_outlined,
                                value: data.firstName,
                                hintText: DriverRegisterConfig.firstNameLabel,
                                isValid: data.isFirstNameValid,
                                onChanged: (val) {
                                  context
                                      .read<DriverRegisterStep1Bloc>()
                                      .add(DriverRegisterFirstNameChanged(val));
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DriverRegisterTextField(
                                label: DriverRegisterConfig.lastNameLabel,
                                icon: Icons.person_outline_rounded,
                                value: data.lastName,
                                hintText: DriverRegisterConfig.lastNameLabel,
                                isValid: data.isLastNameValid,
                                onChanged: (val) {
                                  context
                                      .read<DriverRegisterStep1Bloc>()
                                      .add(DriverRegisterLastNameChanged(val));
                                },
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        DriverRegisterTextField(
                          icon: Icons.badge_outlined,
                          value: data.firstName,
                          hintText: DriverRegisterConfig.firstNameLabel,
                          isValid: data.isFirstNameValid,
                          onChanged: (val) {
                            context
                                .read<DriverRegisterStep1Bloc>()
                                .add(DriverRegisterFirstNameChanged(val));
                          },
                        ),
                        const SizedBox(height: 12),
                        DriverRegisterTextField(
                          icon: Icons.person_outline_rounded,
                          value: data.lastName,
                          hintText: DriverRegisterConfig.lastNameLabel,
                          isValid: data.isLastNameValid,
                          onChanged: (val) {
                            context
                                .read<DriverRegisterStep1Bloc>()
                                .add(DriverRegisterLastNameChanged(val));
                          },
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Email address
                      DriverRegisterTextField(
                        label: (isValid || isInvalid)
                            ? DriverRegisterConfig.emailLabel
                            : null,
                        tagText: isInvalid && state.emailError != null
                            ? DriverRegisterConfig.invalidSyntaxError
                            : null,
                        tagColor: const Color(0xFFDC2626),
                        icon: Icons.mail_outline_rounded,
                        value: data.email,
                        hintText: DriverRegisterConfig.emailPlaceholder,
                        errorText: state.emailError,
                        isValid: data.isEmailValid,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) {
                          context
                              .read<DriverRegisterStep1Bloc>()
                              .add(DriverRegisterEmailChanged(val));
                        },
                      ),
                      const SizedBox(height: 12),

                      // Phone number (SMS verified)
                      DriverRegisterTextField(
                        label: (isValid || isInvalid)
                            ? DriverRegisterConfig.phoneLabel
                            : null,
                        tagText: isInvalid
                            ? DriverRegisterConfig.smsVerifiedBadge
                            : null,
                        tagColor: const Color(0xFF059669),
                        icon: Icons.phone_rounded,
                        value: data.phone,
                        hintText: data.phone,
                        isReadOnly: true,
                        customSuffix: isValid
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline_rounded,
                                        size: 12, color: Color(0xFF059669)),
                                    SizedBox(width: 4),
                                    Text(
                                      DriverRegisterConfig.verifiedBadge,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF047857),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Color(0xFF059669),
                                size: 18,
                              ),
                      ),
                      if (isInitial) ...[
                        const SizedBox(height: 6),
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 13,
                                color: Color(0xFF059669),
                              ),
                              SizedBox(width: 5),
                              Text(
                                DriverRegisterConfig.verifiedViaSms,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Alberta licence number
                      DriverRegisterTextField(
                        label: (isValid || isInvalid)
                            ? DriverRegisterConfig.licenceLabel
                            : null,
                        tagText: isValid
                            ? DriverRegisterConfig.licenceClassTag
                            : null,
                        icon: Icons.credit_card_rounded,
                        value: data.driverLicenceNumber,
                        hintText: isInvalid
                            ? 'e.g. 123456-789'
                            : DriverRegisterConfig.licencePlaceholder,
                        errorText: state.licenceError,
                        isValid: data.isLicenceValid,
                        onChanged: (val) {
                          context
                              .read<DriverRegisterStep1Bloc>()
                              .add(DriverRegisterLicenceChanged(val));
                        },
                      ),
                      const SizedBox(height: 12),

                      // Postal code
                      DriverRegisterTextField(
                        label: (isValid || isInvalid)
                            ? DriverRegisterConfig.postalCodeLabel
                            : null,
                        icon: Icons.location_on_outlined,
                        value: data.postalCode,
                        hintText: DriverRegisterConfig.postalCodePlaceholder,
                        errorText: state.postalCodeError,
                        isValid: data.isPostalCodeValid,
                        onChanged: (val) {
                          context
                              .read<DriverRegisterStep1Bloc>()
                              .add(DriverRegisterPostalCodeChanged(val));
                        },
                      ),
                      const SizedBox(height: 18),

                      // Gender selector
                      DriverRegisterGenderSelector(
                        selectedGender: data.gender,
                        status: state.status,
                        onSelectGender: (gender) {
                          context
                              .read<DriverRegisterStep1Bloc>()
                              .add(DriverRegisterGenderSelected(gender));
                        },
                      ),
                      const SizedBox(height: 18),

                      // Regulatory Notice Card
                      DriverRegisterRegulatoryCard(status: state.status),
                      const SizedBox(height: 18),

                      // General Error Banner (Image 3)
                      if (state.generalAlertMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFDC2626),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.generalAlertMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Primary Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<DriverRegisterStep1Bloc>()
                                .add(const DriverRegisterSubmitted());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValid
                                ? const Color(0xFFC91A25)
                                : const Color(0xFFE5E7EB),
                            disabledBackgroundColor: const Color(0xFFE5E7EB),
                            foregroundColor: isValid
                                ? Colors.white
                                : const Color(0xFF9CA3AF),
                            elevation: isValid ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: state.isSubmitting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Saving details...',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isValid
                                          ? DriverRegisterConfig
                                              .nextVehicleDetailsButtonText
                                          : (isInvalid
                                              ? DriverRegisterConfig
                                                  .continueToVehicleInfoButtonText
                                              : DriverRegisterConfig
                                                  .nextStepButtonText),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isValid
                                            ? Colors.white
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: isValid
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Sheet Overlay for Profile Photo (Image 4)
              if (state.isPhotoModalOpen) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      context
                          .read<DriverRegisterStep1Bloc>()
                          .add(const DriverRegisterPhotoModalDismissed());
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DriverRegisterPhotoModal(
                    onTakePhoto: () {
                      context
                          .read<DriverRegisterStep1Bloc>()
                          .add(const DriverRegisterPhotoPicked('camera'));
                    },
                    onChooseGallery: () {
                      context
                          .read<DriverRegisterStep1Bloc>()
                          .add(const DriverRegisterPhotoPicked('gallery'));
                    },
                    onCancel: () {
                      context
                          .read<DriverRegisterStep1Bloc>()
                          .add(const DriverRegisterPhotoModalDismissed());
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
