import 'package:flutter/material.dart';
import '../../data/models/support_ticket_model.dart';

class SupportTabBar extends StatelessWidget {
  final SupportHubTab selectedTab;
  final int ticketCount;
  final ValueChanged<SupportHubTab> onTabSelected;

  const SupportTabBar({
    super.key,
    required this.selectedTab,
    required this.ticketCount,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: 'New report',
              isSelected: selectedTab == SupportHubTab.newReport,
              onTap: () => onTabSelected(SupportHubTab.newReport),
            ),
          ),
          Expanded(
            child: _TabButton(
              title: 'My tickets ($ticketCount)',
              isSelected: selectedTab == SupportHubTab.myTickets,
              onTap: () => onTabSelected(SupportHubTab.myTickets),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFFB91C1C) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
