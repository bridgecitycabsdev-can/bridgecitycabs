import 'package:flutter/material.dart';
import '../../data/models/profile_setup_config.dart';

/// Progress tracker header showing "ONBOARDING • Step 2 of 3"
/// and a 3-segmented progress bar with Segments 1 and 2 filled.
class ProfileStepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProfileStepProgressBar({
    super.key,
    this.currentStep = 2,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row: ONBOARDING on left, Step 2 of 3 on right
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ProfileSetupConfig.stepLabel,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              ProfileSetupConfig.stepCountText,
              style: TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 3-Segmented Progress Bar
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            return Expanded(
              child: Container(
                height: 4.5,
                margin: EdgeInsets.only(
                  right: index < totalSteps - 1 ? 6 : 0,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFB71C1C)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
