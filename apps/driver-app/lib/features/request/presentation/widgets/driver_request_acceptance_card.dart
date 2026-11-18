import 'package:flutter/material.dart';

class DriverRequestAcceptanceCard extends StatelessWidget {
  final int acceptanceRate;
  final String acceptanceTier;
  final String adviceText;
  final bool isScheduled;

  const DriverRequestAcceptanceCard({
    super.key,
    required this.acceptanceRate,
    required this.acceptanceTier,
    required this.adviceText,
    this.isScheduled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular progress ring or icon
          if (!isScheduled)
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: acceptanceRate / 100.0,
                    strokeWidth: 3.5,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFA000),
                    ),
                  ),
                  Text(
                    '$acceptanceRate%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up,
                size: 20,
                color: Color(0xFFC62828),
              ),
            ),
          const SizedBox(width: 12),
          // Information Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Acceptance rate: $acceptanceRate%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (acceptanceTier.isNotEmpty && !isScheduled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          acceptanceTier,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  adviceText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (isScheduled)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.info_outline, size: 16, color: Colors.black45),
            ),
        ],
      ),
    );
  }
}
