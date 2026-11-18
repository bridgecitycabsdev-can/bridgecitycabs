import 'package:flutter/material.dart';
import '../../data/models/trip_receipt_config.dart';

class ReceiptHeader extends StatelessWidget {
  final VoidCallback onDone;

  const ReceiptHeader({
    super.key,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFECEF),
            Color(0xFFFFF7F8),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar with Done button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 4),
                child: TextButton(
                  onPressed: onDone,
                  child: const Text(
                    TripReceiptConfig.doneButton,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Checkmark Badge
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF00A86B),
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Title
            const Text(
              TripReceiptConfig.tripCompletedTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F1F1F),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            const Text(
              TripReceiptConfig.tripCompletedSubtitle,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
