import 'package:flutter/material.dart';
import '../../data/models/cancel_ride_config.dart';
import '../../data/models/cancel_ride_models.dart';

class ConfirmCancelSheet extends StatelessWidget {
  final CancellationDetails details;
  final ValueChanged<String> onReasonSelected;
  final VoidCallback onKeepRide;
  final VoidCallback onConfirmCancel;

  const ConfirmCancelSheet({
    super.key,
    required this.details,
    required this.onReasonSelected,
    required this.onKeepRide,
    required this.onConfirmCancel,
  });

  void _showReasonPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Select cancellation reason',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...CancellationDetails.commonReasons.map((reason) {
                final isSelected = details.selectedReason == reason;
                return ListTile(
                  title: Text(reason),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFFC62828))
                      : null,
                  onTap: () {
                    onReasonSelected(reason);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Warning Badge
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFC62828),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title & Subtitle
              const Text(
                CancelRideConfig.cancelTitle,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                CancelRideConfig.cancelSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),

              // Policy Container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.info_outline,
                        color: Color(0xFF6B7280),
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        CancelRideConfig.policyCardText,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF4B5563),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reason Input / Picker Field
              InkWell(
                onTap: () => _showReasonPicker(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xFF6B7280),
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          details.selectedReason.isNotEmpty
                              ? details.selectedReason
                              : CancelRideConfig.reasonPlaceholder,
                          style: TextStyle(
                            fontSize: 13,
                            color: details.selectedReason.isNotEmpty
                                ? const Color(0xFF1F1F1F)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Primary Button (Keep ride)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onKeepRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    CancelRideConfig.keepRideButton,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary Button (Yes, cancel ride)
              TextButton(
                onPressed: onConfirmCancel,
                child: const Text(
                  CancelRideConfig.yesCancelRideButton,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
