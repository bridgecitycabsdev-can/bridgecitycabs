import 'package:flutter/material.dart';

class ChooseRideAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback? onProfileTapped;
  final VoidCallback? onToggleInspector;
  final bool isInspectorMode;

  const ChooseRideAppBar({
    super.key,
    required this.onBack,
    this.onProfileTapped,
    this.onToggleInspector,
    this.isInspectorMode = false,
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
        'Ride Selection',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
          letterSpacing: -0.2,
        ),
      ),
      actions: [
        if (onToggleInspector != null)
          IconButton(
            tooltip: isInspectorMode
                ? 'Switch to Passenger View'
                : 'Switch to QA Promo Inspector',
            icon: Icon(
              isInspectorMode ? Icons.directions_car : Icons.bug_report_outlined,
              size: 20,
              color: const Color(0xFF991B1B),
            ),
            onPressed: onToggleInspector,
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: onProfileTapped,
            borderRadius: BorderRadius.circular(20),
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
        ),
      ],
    );
  }
}
