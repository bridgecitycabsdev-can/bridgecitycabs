import 'package:flutter/material.dart';

class PastTripAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onProfileTapped;
  final VoidCallback? onToggleMode;
  final bool isInspectorMode;

  const PastTripAppBar({
    super.key,
    required this.title,
    required this.onBack,
    this.onProfileTapped,
    this.onToggleMode,
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
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
          letterSpacing: -0.2,
        ),
      ),
      actions: [
        if (onToggleMode != null)
          IconButton(
            tooltip: isInspectorMode
                ? 'Switch to Metered View'
                : 'Switch to QA Scenario View',
            icon: Icon(
              isInspectorMode ? Icons.receipt_long : Icons.bug_report_outlined,
              size: 20,
              color: const Color(0xFF991B1B),
            ),
            onPressed: onToggleMode,
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
