import 'package:flutter/material.dart';

class SearchingHeaderBar extends StatelessWidget {
  final String title;
  final VoidCallback onRecenter;
  final VoidCallback onSafety;
  final bool showSafety;

  const SearchingHeaderBar({
    super.key,
    required this.title,
    required this.onRecenter,
    required this.onSafety,
    this.showSafety = true,
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
            Row(
              children: [
                if (showSafety) ...[
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
                      tooltip: 'Safety toolkit',
                    ),
                  ),
                  const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }
}
