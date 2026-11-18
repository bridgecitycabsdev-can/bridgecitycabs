import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_otp_bloc.dart';
import '../bloc/driver_otp_event.dart';
import '../bloc/driver_otp_state.dart';
import '../data/models/driver_otp_config.dart';
import '../data/models/driver_otp_status.dart';
import 'widgets/driver_otp_banners.dart';
import 'widgets/driver_otp_boxes.dart';
import 'widgets/driver_otp_header.dart';
import 'widgets/driver_otp_keypad.dart';
import 'widgets/driver_otp_qa_matrix_bar.dart';
import 'widgets/driver_routing_pathway_card.dart';

class DriverOtpPage extends StatelessWidget {
  final String? phone;
  final DriverOtpStatus? initialStatus;
  final bool showQaToolbar;

  const DriverOtpPage({
    super.key,
    this.phone,
    this.initialStatus,
    this.showQaToolbar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = DriverOtpBloc();
        bloc.add(DriverOtpStarted(
          phone: phone,
          initialStatus: initialStatus ?? DriverOtpStatus.initial,
        ));
        return bloc;
      },
      child: DriverOtpView(showQaToolbar: showQaToolbar),
    );
  }
}

class DriverOtpView extends StatelessWidget {
  final bool showQaToolbar;

  const DriverOtpView({
    super.key,
    required this.showQaToolbar,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverOtpBloc, DriverOtpState>(
      listenWhen: (previous, current) =>
          previous.targetRoute != current.targetRoute ||
          previous.feedbackMessage != current.feedbackMessage,
      listener: (context, state) {
        if (state.feedbackMessage != null &&
            state.feedbackMessage != DriverOtpConfig.otpSentSuccess) {
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

        if (state.targetRoute != null) {
          context.go(state.targetRoute!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // QA Matrix bar for 1-click state switching
                  if (showQaToolbar) ...[
                    DriverOtpQaMatrixBar(
                      currentStatus: state.status,
                      onSelectStatus: (status) {
                        context
                            .read<DriverOtpBloc>()
                            .add(DriverOtpStateSwitched(status));
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Header with Back button, title, profile avatar & cab logo
                  DriverOtpHeader(
                    status: state.status,
                    maskedPhone: state.maskedPhone,
                    onBack: () => context.pop(),
                  ),
                  const SizedBox(height: 20),

                  // 6-digit OTP Box row
                  DriverOtpBoxes(
                    status: state.status,
                    code: state.code,
                  ),
                  const SizedBox(height: 14),

                  // Dynamic Banners
                  if (state.status == DriverOtpStatus.incorrect) ...[
                    const DriverIncorrectBanner(),
                    const SizedBox(height: 10),
                  ] else if (state.status == DriverOtpStatus.expired) ...[
                    DriverExpiredCard(
                      onRequestNewCode: () {
                        context
                            .read<DriverOtpBloc>()
                            .add(const DriverOtpResendTapped());
                      },
                    ),
                    const SizedBox(height: 14),
                  ] else if (state.status == DriverOtpStatus.submitting) ...[
                    const DriverAuthenticatingNotice(),
                    const SizedBox(height: 10),
                  ],

                  // Resend text / Countdown timer
                  if (state.status != DriverOtpStatus.expired) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "${DriverOtpConfig.resendPrompt} ",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        if (state.resendCooldownSeconds > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Resend in ${state.formattedCooldown}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<DriverOtpBloc>()
                                  .add(const DriverOtpResendTapped());
                            },
                            child: const Text(
                              DriverOtpConfig.resendAction,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // "OTP sent successfully" toast badge for fresh entry
                  if (state.status == DriverOtpStatus.initial &&
                      state.code.isEmpty) ...[
                    const DriverOtpSentSuccessPill(),
                    const SizedBox(height: 14),
                  ],

                  // Verify Code Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state.canSubmit
                          ? () {
                              context
                                  .read<DriverOtpBloc>()
                                  .add(const DriverOtpSubmitted());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.canSubmit
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFFE5E7EB),
                        disabledBackgroundColor: state.isSubmitting
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFFE5E7EB),
                        foregroundColor: state.canSubmit
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                        elevation: state.canSubmit ? 2 : 0,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  DriverOtpConfig.verifyingButtonText,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : state.isExpired
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      size: 18,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      DriverOtpConfig.lockedVerifyButtonText,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DriverOtpConfig.verifyButtonText,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: state.canSubmit
                                            ? Colors.white
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: state.canSubmit
                                          ? Colors.white
                                          : const Color(0xFF9CA3AF),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Custom On-Screen Keypad
                  DriverOtpKeypad(
                    onDigitPressed: (digit) {
                      context
                          .read<DriverOtpBloc>()
                          .add(DriverOtpDigitPressed(digit));
                    },
                    onBackspace: () {
                      context
                          .read<DriverOtpBloc>()
                          .add(const DriverOtpBackspacePressed());
                    },
                    onClear: () {
                      context
                          .read<DriverOtpBloc>()
                          .add(const DriverOtpClearPressed());
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bottom Driver Routing Pathways Preview
                  DriverRoutingPathwayCard(
                    status: state.status,
                    selectedPathway: state.selectedPathway,
                    onSelectPathway: (pathway) {
                      context
                          .read<DriverOtpBloc>()
                          .add(DriverOtpPathwaySelected(pathway));
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
