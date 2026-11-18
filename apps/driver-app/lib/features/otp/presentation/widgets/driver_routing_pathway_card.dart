import 'package:flutter/material.dart';
import '../../data/models/driver_otp_config.dart';
import '../../data/models/driver_otp_status.dart';
import '../../data/models/driver_routing_pathway.dart';

class DriverRoutingPathwayCard extends StatelessWidget {
  final DriverOtpStatus status;
  final DriverRoutingPathwayType selectedPathway;
  final ValueChanged<DriverRoutingPathway> onSelectPathway;

  const DriverRoutingPathwayCard({
    super.key,
    required this.status,
    required this.selectedPathway,
    required this.onSelectPathway,
  });

  @override
  Widget build(BuildContext context) {
    String headerTitle;
    if (status == DriverOtpStatus.incorrect) {
      headerTitle = DriverOtpConfig.routingPreviewsHeader;
    } else if (status == DriverOtpStatus.expired) {
      headerTitle = DriverOtpConfig.routingOutcomesHeader;
    } else if (status == DriverOtpStatus.submitting) {
      headerTitle = DriverOtpConfig.resolutionPathwaysHeader;
    } else if (status == DriverOtpStatus.initial) {
      headerTitle = DriverOtpConfig.authenticationRoutesHeader;
    } else {
      headerTitle = DriverOtpConfig.routingFlowHeader;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF4B5563),
                ),
              ),
              const Icon(
                Icons.alt_route_rounded,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3 Pathway Rows
          ...DriverRoutingPathway.pathways.map((pathway) {
            final isSelected = pathway.type == selectedPathway;
            Color rowBg;
            Color textColor;
            Color dotColor;

            switch (pathway.type) {
              case DriverRoutingPathwayType.approvedDriver:
                rowBg = const Color(0xFFDCFCE7);
                textColor = const Color(0xFF15803D);
                dotColor = const Color(0xFF16A34A);
                break;
              case DriverRoutingPathwayType.docsInReview:
                rowBg = const Color(0xFFFEE2E2);
                textColor = const Color(0xFFB91C1C);
                dotColor = const Color(0xFFDC2626);
                break;
              case DriverRoutingPathwayType.newNumber:
                rowBg = const Color(0xFFF3F4F6);
                textColor = const Color(0xFF4B5563);
                dotColor = const Color(0xFF9CA3AF);
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onSelectPathway(pathway),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: rowBg,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: textColor.withOpacity(0.4), width: 1.2)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: dotColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pathway.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            pathway.destinationText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: textColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
