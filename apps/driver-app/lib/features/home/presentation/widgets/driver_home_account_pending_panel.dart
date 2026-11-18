import 'package:flutter/material.dart';
import '../../data/models/driver_home_config.dart';
import '../../data/models/driver_shift_mode.dart';
import '../../data/models/driver_verification_item.dart';
import 'driver_home_shift_toggle.dart';

class DriverHomeAccountPendingPanel extends StatelessWidget {
  final List<DriverVerificationItem> verificationItems;
  final VoidCallback onViewDocuments;
  final VoidCallback onCheckApplicationStatus;
  final VoidCallback onContactSupport;

  const DriverHomeAccountPendingPanel({
    super.key,
    required this.verificationItems,
    required this.onViewDocuments,
    required this.onCheckApplicationStatus,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Review Alert Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC62828),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          DriverHomeConfig.documentsUnderReviewTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          DriverHomeConfig.documentsUnderReviewDesc,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  key: const ValueKey('driver_view_documents_button'),
                  onPressed: onViewDocuments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF991B1B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        DriverHomeConfig.viewDocumentsButton,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 12, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Title & Pending Review Tag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  DriverHomeConfig.accountPendingTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  DriverHomeConfig.accountPendingSubtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.access_time, size: 12, color: Color(0xFFC62828)),
                  SizedBox(width: 4),
                  Text(
                    DriverHomeConfig.pendingReviewTag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC62828),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Locked Dispatch Toggle
        const DriverHomeShiftToggle(
          shiftMode: DriverShiftMode.locked,
          isLocked: true,
          lockedCustomText: DriverHomeConfig.dispatchLockedTag,
        ),
        const SizedBox(height: 16),

        // Verification Checklist Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              DriverHomeConfig.verificationChecklistTitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              DriverHomeConfig.verificationRatio,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Checklist Items
        for (final item in verificationItems) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                _buildChecklistIcon(item.status),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildChecklistBadge(item.status, item.tagText),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),

        // Operations desk notice
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline, size: 14, color: Color(0xFF6B7280)),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                DriverHomeConfig.verificationDeskNotice,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Large Check Application Status Button
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            key: const ValueKey('driver_check_status_button'),
            onPressed: onCheckApplicationStatus,
            icon: const Icon(Icons.assignment_outlined,
                size: 18, color: Color(0xFFC62828)),
            label: const Text(
              '${DriverHomeConfig.checkApplicationStatus} ➔',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC62828),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFFFF5F5),
              side: const BorderSide(color: Color(0xFFFFCDD2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Contact Support Footer Link
        Center(
          child: InkWell(
            onTap: onContactSupport,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.phone_outlined, size: 14, color: Color(0xFF4B5563)),
                SizedBox(width: 6),
                Text(
                  DriverHomeConfig.contactCitySupport,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistIcon(VerificationItemStatus status) {
    switch (status) {
      case VerificationItemStatus.verified:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.check, size: 18, color: Color(0xFF16A34A)),
        );

      case VerificationItemStatus.underReview:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.hourglass_empty,
              size: 16, color: Color(0xFFC62828)),
        );

      case VerificationItemStatus.pending:
      default:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.update, size: 16, color: Color(0xFF9CA3AF)),
        );
    }
  }

  Widget _buildChecklistBadge(VerificationItemStatus status, String text) {
    Color bg;
    Color fg;

    switch (status) {
      case VerificationItemStatus.verified:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case VerificationItemStatus.underReview:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        break;
      case VerificationItemStatus.pending:
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
