import 'package:flutter/material.dart';
import '../../data/models/driver_profile_tab.dart';

class DriverProfileTabBar extends StatelessWidget {
  final DriverProfileTab activeTab;
  final List<DriverProfileTab> availableTabs;
  final bool hasDocumentAlert;
  final ValueChanged<DriverProfileTab> onTabChanged;

  const DriverProfileTabBar({
    super.key,
    required this.activeTab,
    required this.availableTabs,
    this.hasDocumentAlert = false,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: availableTabs.map((tab) {
          final isSelected = tab == activeTab;
          final isDocuments = tab == DriverProfileTab.documents;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFB71C1C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab == DriverProfileTab.info
                          ? Icons.badge_outlined
                          : tab == DriverProfileTab.documents
                              ? Icons.description_outlined
                              : Icons.timeline,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (isDocuments && hasDocumentAlert) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
