import 'package:flutter/material.dart';

class NoDriverHeaderBar extends StatelessWidget {
  final String title;
  final bool showBackArrow;
  final VoidCallback onBack;
  final VoidCallback onRecenter;

  const NoDriverHeaderBar({
    super.key,
    required this.title,
    this.showBackArrow = false,
    required this.onBack,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showBackArrow) ...[
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                shadowColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF1F1F1F),
                    size: 20,
                  ),
                  onPressed: onBack,
                  tooltip: 'Back',
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC62828),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              shadowColor: Colors.black26,
              child: IconButton(
                icon: const Icon(
                  Icons.my_location,
                  color: Color(0xFF1F1F1F),
                  size: 20,
                ),
                onPressed: onRecenter,
                tooltip: 'Recenter map',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
