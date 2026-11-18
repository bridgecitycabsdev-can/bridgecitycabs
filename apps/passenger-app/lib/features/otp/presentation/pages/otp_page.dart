import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/otp_bloc.dart';
import '../bloc/otp_event.dart';
import '../bloc/otp_state.dart';
import '../../data/models/otp_config.dart';
import '../../data/repositories/otp_repository.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/otp_boxes_input.dart';
import '../widgets/otp_error_banner.dart';
import '../widgets/otp_expired_card.dart';
import '../widgets/otp_header.dart';
import '../widgets/otp_resend_section.dart';
import '../widgets/otp_sync_card.dart';

/// Entry screen providing the complete OTP verification experience with [OtpBloc].
class OtpPage extends StatelessWidget {
  final String phone;
  final OtpRepository? repository;

  const OtpPage({
    super.key,
    required this.phone,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpBloc(
        repository: repository ?? OtpRepositoryImpl(),
        initialPhone: phone,
      ),
      child: const _OtpView(),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state.targetRoute != null) {
          context.go(state.targetRoute!);
        }
      },
      builder: (context, state) {
        final isVerifying = state is OtpVerifyingState;
        final isExpired = state is OtpExpiredState;
        final isError = state is OtpErrorState;
        final canSubmit = state.canSubmit;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    // Top App Bar + Branding Header
                    OtpHeader(
                      maskedPhone: state.maskedPhone,
                      showEditPhone: state is OtpInitialState,
                      onBack: () {
                        context
                            .read<OtpBloc>()
                            .add(const OtpEditPhoneTapped());
                      },
                      onEditPhone: () {
                        context
                            .read<OtpBloc>()
                            .add(const OtpEditPhoneTapped());
                      },
                    ),
                    const SizedBox(height: 20),

                    // 6 OTP Digit Boxes
                    OtpBoxesInput(
                      code: state.code,
                      status: state.status,
                    ),
                    const SizedBox(height: 16),

                    // Error Banner (Screen 1)
                    if (isError && state.errorMessage != null) ...[
                      OtpErrorBanner(errorMessage: state.errorMessage!),
                      const SizedBox(height: 12),
                    ],

                    // Expired Alert & Resend Card (Screen 5)
                    if (isExpired) ...[
                      OtpExpiredCardSection(
                        onResend: () {
                          context
                              .read<OtpBloc>()
                              .add(const OtpResendRequested());
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Sync & Transit Channel Security Card (Screen 4)
                    if (isVerifying) ...[
                      const OtpSyncCard(),
                      const SizedBox(height: 14),
                    ],

                    // Resend Prompt, Countdown Timer, or Success Toast
                    OtpResendSection(
                      state: state,
                      onResend: () {
                        context
                            .read<OtpBloc>()
                            .add(const OtpResendRequested());
                      },
                    ),
                    const SizedBox(height: 18),

                    // Primary Action Button (Verify code → / Verifying code...)
                    _buildVerifyButton(context, state),
                    const SizedBox(height: 18),

                    // Custom In-App Numeric Keypad
                    NumericKeypad(
                      isEnabled: !isVerifying && !isExpired,
                      onDigitPressed: (digit) {
                        context
                            .read<OtpBloc>()
                            .add(OtpDigitEntered(digit));
                      },
                      onDeletePressed: () {
                        context
                            .read<OtpBloc>()
                            .add(const OtpDigitDeleted());
                      },
                    ),
                    const SizedBox(height: 16),

                    // Security footer (Screen 2)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Color(0xFFB71C1C),
                          size: 13,
                        ),
                        SizedBox(width: 6),
                        Text(
                          OtpConfig.encryptedNotice,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerifyButton(BuildContext context, OtpState state) {
    final isVerifying = state is OtpVerifyingState;
    final canSubmit = state.canSubmit;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canSubmit
            ? () {
                context.read<OtpBloc>().add(const OtpSubmitRequested());
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit || isVerifying
              ? const Color(0xFFB71C1C)
              : const Color(0xFFE5E7EB),
          elevation: canSubmit ? 3 : 0,
          shadowColor: const Color(0xFFB71C1C).withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: isVerifying
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    OtpConfig.verifyingButton,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    OtpConfig.verifyButton,
                    style: TextStyle(
                      color: canSubmit ? Colors.white : const Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: canSubmit ? Colors.white : const Color(0xFF9CA3AF),
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }
}
