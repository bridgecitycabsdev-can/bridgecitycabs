import 'package:flutter/material.dart';

class TripsListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onCalendarTapped;

  const TripsListAppBar({
    super.key,
    required this.onBack,
    required this.onCalendarTapped,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF111827),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
        onPressed: onBack,
      ),
      title: const Text(
        'Trips',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF111827),
            size: 20,
          ),
          onPressed: onCalendarTapped,
        ),
      ],
    );
  }
}
