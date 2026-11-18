import 'package:flutter/material.dart';
import '../../data/models/delete_account_config.dart';
import '../../data/models/delete_account_model.dart';

class SecurityVerificationCard extends StatelessWidget {
  final LeavingReason selectedReason;
  final String feedbackText;
  final bool isAcknowledged;
  final String otpCode;
  final String formattedCountdown;
  final ValueChanged<LeavingReason> onReasonSelected;
  final ValueChanged<String> onFeedbackChanged;
  final ValueChanged<bool> onAcknowledgmentToggled;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onResendOtp;
  final VoidCallback onDeleteAccount;
  final VoidCallback onCancelAndKeep;

  const SecurityVerificationCard({
    super.key,
    required this.selectedReason,
    required this.feedbackText,
    required this.isAcknowledged,
    required this.otpCode,
    required this.formattedCountdown,
    required this.onReasonSelected,
    required this.onFeedbackChanged,
    required this.onAcknowledgmentToggled,
    required this.onOtpChanged,
    required this.onResendOtp,
    required this.onDeleteAccount,
    required this.onCancelAndKeep,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 2 of 2 Stepper
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'STEP 2 OF 2 • FINAL AUTHORIZATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFDC2626),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Heading & Subtitle
          const Text(
            DeleteAccountConfig.confirmDeletionTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            DeleteAccountConfig.confirmDeletionSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Why are you leaving section
          const Text(
            'Why are you leaving? (optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),

          // Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LeavingReason.values.map((reason) {
              final isSelected = selectedReason == reason;
              return GestureDetector(
                onTap: () => onReasonSelected(reason),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFEE2E2) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFCA5A5) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check, size: 14, color: Color(0xFF991B1B)),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        reason.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF991B1B) : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Feedback Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              onChanged: onFeedbackChanged,
              maxLines: 2,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Your feedback helps us improve Southern Alberta transit...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Acknowledgment Checkbox Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isAcknowledged,
                  activeColor: const Color(0xFFDC2626),
                  onChanged: (val) => onAcknowledgmentToggled(val ?? false),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    DeleteAccountConfig.acknowledgmentText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F1D1D),
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Security Authorization / OTP Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_outline, color: Color(0xFF991B1B), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Security Authorization',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {},
                      child: const Text(
                        'Toggle OTP demo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll send a 6-digit confirmation code via SMS to ${DeleteAccountConfig.phoneMasked} to verify account ownership.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),

                // 6-digit OTP Box
                _buildOtpBoxes(),
                const SizedBox(height: 12),

                // Resend Timer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text(
                          'Resend code in $formattedCountdown',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: onResendOtp,
                      child: const Text(
                        'Use email instead',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Primary: Delete my account button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isAcknowledged ? onDeleteAccount : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                'Delete my account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Secondary: Cancel and keep account
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onCancelAndKeep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: const Color(0xFF1F2937),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Cancel and keep account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Footer
          const Center(
            child: Text(
              '🛡 Bridge City Cabs Identity Protection • 2FA Verification',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOtpBoxes() {
    // 6 boxes: e.g. [4] [8] [2] [ | ] [ • ] [ • ]
    final digits = otpCode.split('');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final hasDigit = index < digits.length;
        final isCurrent = index == digits.length;

        return Container(
          width: 44,
          height: 48,
          decoration: BoxDecoration(
            color: isCurrent ? Colors.white : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFF991B1B)
                  : (hasDigit ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6)),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Center(
            child: hasDigit
                ? Text(
                    digits[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  )
                : (isCurrent
                    ? Container(
                        width: 2,
                        height: 20,
                        color: const Color(0xFF991B1B),
                      )
                    : Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD1D5DB),
                          shape: BoxShape.circle,
                        ),
                      )),
          ),
        );
      }),
    );
  }
}
