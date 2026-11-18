import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../data/models/auth_config.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_info_card.dart';
import '../widgets/cooldown_banner.dart';
import '../widgets/help_dispatch_card.dart';
import '../widgets/phone_input_field.dart';

/// Entry widget providing the passenger authentication experience with [AuthBloc].
class LoginPage extends StatelessWidget {
  final AuthRepository? repository;

  const LoginPage({
    super.key,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        repository: repository ?? AuthRepositoryImpl(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthCodeSentSuccess && state.targetRoute != null) {
          context.go(state.targetRoute!);
        }
      },
      builder: (context, state) {
        final isRateLimited = state is AuthRateLimited;
        final isSubmitting = state is AuthSubmitting;
        final isValid = state is AuthPhoneValid;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Screen 2: Top Cooldown Banner if rate limited
                    if (isRateLimited && state.cooldown != null) ...[
                      CooldownBanner(cooldown: state.cooldown!),
                      const SizedBox(height: 24),
                    ],

                    // Main Branding Header & "Login" Title
                    AuthHeader(
                      subtitleOverride: isRateLimited
                          ? 'LETHBRIDGE • SOUTHERN ALBERTA'
                          : null,
                    ),
                    const SizedBox(height: 28),

                    // Phone Number Input Field supporting all 5 states
                    PhoneInputField(
                      controller: _phoneController,
                      status: state.status,
                      onChanged: (val) {
                        context.read<AuthBloc>().add(AuthPhoneChanged(val));
                      },
                      onSubmitted: () {
                        context.read<AuthBloc>().add(const AuthSubmitRequested());
                      },
                    ),
                    const SizedBox(height: 18),

                    // Contextual Cards: Help card if rate limited, or info cards
                    if (isRateLimited) ...[
                      HelpDispatchCard(
                        onHelp: () {
                          context.read<AuthBloc>().add(const AuthHelpTapped());
                        },
                      ),
                    ] else ...[
                      AuthInfoCard(status: state.status),
                    ],
                    const SizedBox(height: 28),

                    // Primary Action Button (Continue / Sending code...)
                    _buildContinueButton(context, state),

                    // Screen 4: "Entered wrong number? Edit" prompt
                    if (isSubmitting) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '${AuthConfig.editWrongNumber} ',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthEditPhoneTapped());
                            },
                            child: const Text(
                              AuthConfig.editText,
                              style: TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Footer with Terms, Privacy Policy & Regional coverage
                    AuthFooter(isServingDetailed: isRateLimited),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton(BuildContext context, AuthState state) {
    final isSubmitting = state is AuthSubmitting;
    final canSubmit = state.canSubmit;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canSubmit
            ? () {
                context.read<AuthBloc>().add(const AuthSubmitRequested());
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit || isSubmitting
              ? const Color(0xFFB71C1C)
              : const Color(0xFFE5E7EB),
          elevation: canSubmit ? 3 : 0,
          shadowColor: const Color(0xFFB71C1C).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
        ),
        child: isSubmitting
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
                    AuthConfig.sendingCodeButton,
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
                    AuthConfig.continueButton,
                    style: TextStyle(
                      color: canSubmit ? Colors.white : const Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
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
