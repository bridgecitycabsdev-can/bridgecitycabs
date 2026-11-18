import 'package:flutter/material.dart';
import '../../data/models/driver_register_config.dart';
import '../../data/models/driver_register_step1_status.dart';

class DriverRegisterRegulatoryCard extends StatelessWidget {
  final DriverRegisterStep1Status status;

  const DriverRegisterRegulatoryCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String? title;
    String description;

    if (status == DriverRegisterStep1Status.valid) {
      title = DriverRegisterConfig.privacyProtectedTitle;
      description = DriverRegisterConfig.privacyProtectedDesc;
    } else if (status == DriverRegisterStep1Status.invalid) {
      title = DriverRegisterConfig.identityAuditTitle;
      description = DriverRegisterConfig.identityAuditDesc;
    } else {
      title = null;
      description = DriverRegisterConfig.taxiCommissionNotice;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2).withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFB91C1C),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.shield_outlined,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7F1D1D),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
