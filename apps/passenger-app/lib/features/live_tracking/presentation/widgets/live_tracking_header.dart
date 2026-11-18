import 'package:flutter/material.dart';

class LiveTrackingHeader extends StatelessWidget {
  final String pillText;
  final Color pillDotColor;
  final bool isSosTriggered;
  final VoidCallback onSafety;
  final VoidCallback onRecenter;

  const LiveTrackingHeader({
    super.key,
    required this.pillText,
    required this.pillDotColor,
    this.isSosTriggered = false,
    required this.onSafety,
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
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: pillDotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pillText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Stack(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 3,
                      shadowColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFFC62828),
                          size: 20,
                        ),
                        onPressed: onSafety,
                        tooltip: 'Safety Toolkit',
                      ),
                    ),
                    if (isSosTriggered)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC62828),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }
}
