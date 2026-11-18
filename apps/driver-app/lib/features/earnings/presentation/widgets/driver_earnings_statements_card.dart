import 'package:flutter/material.dart';
import '../../data/models/driver_payout_statement.dart';

class DriverEarningsStatementsCard extends StatelessWidget {
  final List<DriverPayoutStatement> statements;
  final ValueChanged<String> onStatementTap;
  final VoidCallback? onSeeAllTap;

  const DriverEarningsStatementsCard({
    super.key,
    required this.statements,
    required this.onStatementTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Statements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            GestureDetector(
              onTap: onSeeAllTap,
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Statements List
        ...statements.map((stmt) {
          final isPaid = stmt.statusLabel.toUpperCase() == 'PAID';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onStatementTap(stmt.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Status Icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFFC8E6C9)
                              : const Color(0xFFFFCDD2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPaid
                              ? Icons.verified_outlined
                              : Icons.hourglass_top_rounded,
                          color: isPaid
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Period & Trips
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stmt.periodLabel,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${stmt.tripCount} rides • Lethbridge...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Amount & Badge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${stmt.netPayout.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stmt.statusLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isPaid
                                    ? Colors.white
                                    : const Color(0xFF757575),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),

                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF9E9E9E),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
