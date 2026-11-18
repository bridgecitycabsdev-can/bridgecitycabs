import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_auth_bloc.dart';
import '../bloc/driver_auth_event.dart';
import '../bloc/driver_auth_state.dart';
import '../data/models/driver_auth_config.dart';
import '../data/models/driver_auth_status.dart';
import 'widgets/driver_auth_footer.dart';
import 'widgets/driver_auth_header.dart';
import 'widgets/driver_auth_info_card.dart';
import 'widgets/driver_auth_qa_matrix_bar.dart';
import 'widgets/driver_dispatch_help_card.dart';
import 'widgets/driver_lockout_banner.dart';
import 'widgets/driver_phone_input_field.dart';
import 'widgets/driver_unregistered_banner.dart';

class DriverLoginPage extends StatelessWidget {
  final DriverAuthStatus? initialStatus;
  final bool showQaToolbar;

  const DriverLoginPage({
    super.key,
    this.initialStatus,
    this.showQaToolbar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = DriverAuthBloc();
        if (initialStatus != null &&
            initialStatus != DriverAuthStatus.initial) {
          bloc.add(DriverAuthStateSwitched(initialStatus!));
        }
        return bloc;
      },
      child: DriverLoginView(showQaToolbar: showQaToolbar),
    );
  }
}

class DriverLoginView extends StatelessWidget {
  final bool showQaToolbar;

  const DriverLoginView({
    super.key,
    required this.showQaToolbar,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverAuthBloc, DriverAuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.feedbackMessage != current.feedbackMessage,
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

        if (state.status == DriverAuthStatus.codeSent) {
          context.go(
            '/code?phone=${Uri.encodeComponent(state.digitsOnly.isEmpty ? '4035550192' : state.digitsOnly)}',
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Subtle top right crimson ambient circle background
              Positioned(
                top: -90,
                right: -90,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFEE2E2).withOpacity(0.45),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      // QA Matrix toolbar
                      if (showQaToolbar) ...[
                        DriverAuthQaMatrixBar(
                          currentStatus: state.status,
                          onSelectStatus: (status) {
                            context
                                .read<DriverAuthBloc>()
                                .add(DriverAuthStateSwitched(status));
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Top Warning Banner for Unregistered State
                      if (state.status == DriverAuthStatus.unregistered) ...[
                        DriverUnregisteredBanner(
                          onRegisterDriver: () {
                            context
                                .read<DriverAuthBloc>()
                                .add(const DriverAuthBecomeDriverTapped());
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Top Lockout Warning Banner
                      if (state.status == DriverAuthStatus.locked) ...[
                        DriverLockoutBanner(
                          formattedRemainingTime: state.formattedLockoutTime,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Brand Header & Greetings
                      DriverAuthHeader(status: state.status),
                      const SizedBox(height: 24),

                      // Phone Input Field with flag, area code, validation & clear icons
                      DriverPhoneInputField(
                        status: state.status,
                        formattedPhone: state.formattedPhone,
                        onPhoneChanged: (val) {
                          context
                              .read<DriverAuthBloc>()
                              .add(DriverAuthPhoneChanged(val));
                        },
                        onClear: () {
                          context
                              .read<DriverAuthBloc>()
                              .add(const DriverAuthPhoneCleared());
                        },
                        onNotYourNumber: () {
                          context
                              .read<DriverAuthBloc>()
                              .add(const DriverAuthNotYourNumberTapped());
                        },
                      ),
                      const SizedBox(height: 18),

                      // Dynamic Info Card or Dispatch Radio Assistance
                      if (state.status == DriverAuthStatus.locked)
                        const DriverDispatchHelpCard()
                      else
                        DriverAuthInfoCard(info: state.fleetInfo),
                      const SizedBox(height: 24),

                      // Primary Action Button (Continue / Sending code... / Locked)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: state.canContinue && !state.isSubmitting
                              ? () {
                                  context
                                      .read<DriverAuthBloc>()
                                      .add(const DriverAuthSubmitted());
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.canContinue
                                ? const Color(0xFFC91A25)
                                : const Color(0xFFE5E7EB),
                            disabledBackgroundColor: state.isSubmitting
                                ? const Color(0xFFC91A25)
                                : const Color(0xFFE5E7EB),
                            foregroundColor: state.canContinue
                                ? Colors.white
                                : const Color(0xFF9CA3AF),
                            elevation: state.canContinue ? 2 : 0,
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
                                      DriverAuthConfig.sendingCodeButtonText,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : state.status == DriverAuthStatus.locked
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.lock_outline_rounded,
                                          size: 18,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          DriverAuthConfig.lockedButtonText,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DriverAuthConfig.continueButtonText,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: state.canContinue
                                                ? Colors.white
                                                : const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                        if (state.status !=
                                            DriverAuthStatus.initial) ...[
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                            color: state.canContinue
                                                ? Colors.white
                                                : const Color(0xFF9CA3AF),
                                          ),
                                        ],
                                      ],
                                    ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer with Become a Driver & City of Lethbridge bylaws
                      DriverAuthFooter(
                        status: state.status,
                        onBecomeDriver: () {
                          context
                              .read<DriverAuthBloc>()
                              .add(const DriverAuthBecomeDriverTapped());
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
