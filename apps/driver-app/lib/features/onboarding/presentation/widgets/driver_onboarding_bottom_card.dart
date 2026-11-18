import 'package:flutter/material.dart';
import '../../data/models/driver_onboarding_step.dart';
import 'driver_onboarding_dots_indicator.dart';

class DriverOnboardingBottomCard extends StatelessWidget {
  final DriverOnboardingStepData stepData;
  final int totalSteps;
  final bool isSubmitting;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  const DriverOnboardingBottomCard({
    super.key,
    required this.stepData,
    required this.totalSteps,
    required this.isSubmitting,
    required this.onNext,
    required this.onGetStarted,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tag Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (stepData.step == DriverOnboardingStep.driveWithConfidence) ...[
                  const Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: Color(0xFF991B1B),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  stepData.categoryTag,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            stepData.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            stepData.description,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Action Section
          if (!stepData.isLastStep) ...[
            // Slide 1 & 2: Dots on left, Red Arrow FAB on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DriverOnboardingDotsIndicator(
                  totalCount: totalSteps,
                  currentIndex: stepData.index,
                ),
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC91A25),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC91A25).withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Slide 3 & 4: Dots on top, full width button, and login link
            DriverOnboardingDotsIndicator(
              totalCount: totalSteps,
              currentIndex: stepData.index,
            ),
            const SizedBox(height: 18),

            // Red Button: Get started ➔ OR Setting up dispatch...
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC91A25),
                  disabledBackgroundColor: const Color(0xFFC91A25),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Setting up dispatch...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Secondary Link: I already have an account
            Center(
              child: GestureDetector(
                onTap: onLogin,
                child: const Text(
                  'I already have an account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
