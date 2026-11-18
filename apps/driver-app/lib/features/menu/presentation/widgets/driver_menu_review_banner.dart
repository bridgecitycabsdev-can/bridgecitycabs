import 'package:flutter/material.dart';

class DriverMenuReviewBanner extends StatelessWidget {
  const DriverMenuReviewBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFA000),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.manage_search,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Account Under Review',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.circle, size: 6, color: Color(0xFFFFA000)),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Lethbridge Taxi Commission compliance verification in progress. Certain driver actions are restricted.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    height: 1.3,
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

class DriverMenuShiftLockedCard extends StatelessWidget {
  const DriverMenuShiftLockedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFCDD2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_clock,
                  size: 16,
                  color: Color(0xFFC62828),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHIFT LOCKED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB71C1C),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Verification Required',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.verified_user_outlined, size: 18, color: Colors.black45),
        ],
      ),
    );
  }
}
