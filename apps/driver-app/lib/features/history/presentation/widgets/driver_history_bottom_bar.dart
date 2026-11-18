import 'package:flutter/material.dart';

class DriverHistoryBottomBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onIndexChanged;

  const DriverHistoryBottomBar({
    super.key,
    this.activeIndex = 2, // 2 is History
    this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            index: 0,
            icon: Icons.local_taxi_outlined,
            activeIcon: Icons.local_taxi,
            label: 'Dispatch',
          ),
          _buildItem(
            index: 1,
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            label: 'Earnings',
          ),
          _buildItem(
            index: 2,
            icon: Icons.history_rounded,
            activeIcon: Icons.history_rounded,
            label: 'History',
          ),
          _buildItem(
            index: 3,
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person,
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = activeIndex == index;

    return InkWell(
      onTap: () => onIndexChanged?.call(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? const Color(0xFFC62828) : const Color(0xFF757575),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFFC62828) : const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
