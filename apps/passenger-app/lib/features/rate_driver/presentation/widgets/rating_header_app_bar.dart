import 'package:flutter/material.dart';

class RatingHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClose;
  final VoidCallback onSkip;
  final bool showSkip;
  final bool isSubmitting;

  const RatingHeaderAppBar({
    super.key,
    required this.onClose,
    required this.onSkip,
    this.showSkip = true,
    this.isSubmitting = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1E293B)),
            onPressed: onClose,
            tooltip: 'Close',
          ),
          centerTitle: true,
          title: const Text(
            'Rate Your Trip',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          actions: [
            if (showSkip)
              TextButton(
                onPressed: onSkip,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 4),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF991B1B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        if (isSubmitting)
          const LinearProgressIndicator(
            backgroundColor: Color(0xFFFEE2E2),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB91C1C)),
            minHeight: 3,
          )
        else
          const SizedBox(height: 3),
      ],
    );
  }
}
