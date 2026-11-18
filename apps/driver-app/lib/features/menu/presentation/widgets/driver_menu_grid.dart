import 'package:flutter/material.dart';
import '../../data/models/driver_menu_item.dart';

class DriverMenuGrid extends StatelessWidget {
  final List<DriverMenuItemState> items;
  final ValueChanged<DriverMenuItemId> onItemSelected;

  const DriverMenuGrid({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) => _buildCard(context, item)).toList(),
    );
  }

  Widget _buildCard(BuildContext context, DriverMenuItemState item) {
    final iconData = switch (item.id) {
      DriverMenuItemId.profile => Icons.person_outline,
      DriverMenuItemId.earnings => Icons.account_balance_wallet_outlined,
      DriverMenuItemId.history => Icons.history,
      DriverMenuItemId.reviews => Icons.star_border,
      DriverMenuItemId.settings => Icons.settings_outlined,
      DriverMenuItemId.flagRide => Icons.outlined_flag,
    };

    final isSelected = item.isSelected;
    final isLocked = item.isLocked;

    final bgColor = isLocked
        ? const Color(0xFFF7F7F7)
        : isSelected
            ? const Color(0xFFFFF2F2)
            : const Color(0xFFF9F9FB);

    final borderColor = isSelected
        ? const Color(0xFFFFCDD2)
        : const Color(0xFFEEEEEE);

    return InkWell(
      onTap: () => onItemSelected(item.id),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            // Centered content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.black12
                          : isSelected
                              ? const Color(0xFFC62828)
                              : const Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      size: 20,
                      color: isLocked
                          ? Colors.black38
                          : isSelected
                              ? Colors.white
                              : const Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.id.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isLocked
                          ? Colors.black38
                          : isSelected
                              ? const Color(0xFFB71C1C)
                              : Colors.black87,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC62828),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),

            // Top-right notification dot or lock
            if (item.hasNotificationBadge)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD32F2F),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            if (isLocked)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: Colors.black38,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
