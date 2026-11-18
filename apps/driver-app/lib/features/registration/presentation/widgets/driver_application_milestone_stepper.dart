import 'package:flutter/material.dart';
import '../../data/models/driver_application_milestone.dart';

class DriverApplicationMilestoneStepper extends StatelessWidget {
  final List<DriverApplicationMilestone> milestones;

  const DriverApplicationMilestoneStepper({
    super.key,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(milestones.length, (index) {
        final item = milestones[index];
        final isLast = index == milestones.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Node & Vertical Connector Line
            Column(
              children: [
                _buildNodeIcon(item.status),
                if (!isLast)
                  Container(
                    width: 2,
                    height: item.tags.isNotEmpty ? 70 : 45,
                    color: item.status.isCompleted
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE5E7EB),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Right Milestone Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: item.status.isRejected ||
                                      item.status.isActionRequired
                                  ? const Color(0xFF991B1B)
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        if (item.badgeText != null)
                          _buildBadge(item.badgeText!, item.status)
                        else if (item.timestamp != null)
                          Text(
                            item.timestamp!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.status.isActionRequired ||
                                item.status.isRejected
                            ? const Color(0xFFB71C1C)
                            : const Color(0xFF6B7280),
                      ),
                    ),

                    // Tags row (e.g. Class 4 License, Vulnerable Sector, City Inspection)
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.tags.map((tag) {
                          final isRefresh = tag.contains('Inspection');
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isRefresh
                                  ? const Color(0xFFFFEBEE)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isRefresh ? Icons.sync : Icons.check,
                                  size: 11,
                                  color: isRefresh
                                      ? const Color(0xFFC62828)
                                      : const Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isRefresh
                                        ? const Color(0xFFC62828)
                                        : const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNodeIcon(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF2E7D32),
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        );

      case MilestoneStatus.inProgress:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFEBEE),
            border: Border.all(color: const Color(0xFFC62828), width: 2),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFC62828),
              ),
            ),
          ),
        );

      case MilestoneStatus.actionRequired:
      case MilestoneStatus.rejected:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFC62828),
          ),
          child: Icon(
            status.isRejected ? Icons.close : Icons.priority_high,
            size: 14,
            color: Colors.white,
          ),
        );

      case MilestoneStatus.locked:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF3F4F6),
          ),
          child: const Icon(Icons.lock_outline,
              size: 12, color: Color(0xFF9CA3AF)),
        );

      case MilestoneStatus.pending:
      default:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE5E7EB),
          ),
        );
    }
  }

  Widget _buildBadge(String badgeText, MilestoneStatus status) {
    final isGreen =
        status.isCompleted || badgeText.contains('Passed') || badgeText.contains('Ready');
    final isRed = status.isInProgress ||
        status.isActionRequired ||
        status.isRejected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isGreen
            ? const Color(0xFFE8F5E9)
            : (isRed ? const Color(0xFFFFEBEE) : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isGreen
              ? const Color(0xFF1B5E20)
              : (isRed ? const Color(0xFFB71C1C) : const Color(0xFF4B5563)),
        ),
      ),
    );
  }
}
