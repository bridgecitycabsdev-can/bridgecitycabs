import 'package:flutter/material.dart';
import '../../data/models/quick_search_shortcut.dart';

class PlaceInputCard extends StatelessWidget {
  final String pickupAddress;
  final TextEditingController controller;
  final bool isSearching;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final VoidCallback onSwap;
  final List<QuickSearchShortcut> shortcuts;
  final ValueChanged<String> onShortcutTap;

  const PlaceInputCard({
    super.key,
    required this.pickupAddress,
    required this.controller,
    required this.isSearching,
    required this.onQueryChanged,
    required this.onClear,
    required this.onSwap,
    required this.shortcuts,
    required this.onShortcutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Inner card holding Pickup and Destination fields
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              children: [
                // Pickup row
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PICKUP',
                            style: TextStyle(
                              color: Color(0xFF880E14),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pickupAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_vert_rounded, color: Color(0xFF6B7280), size: 20),
                      onPressed: onSwap,
                    ),
                  ],
                ),

                // Connector vertical line
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 2,
                      height: 14,
                      color: const Color(0xFFD1D5DB),
                    ),
                  ),
                ),

                // Destination row (Highlighted in Deep Red border)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFB71C1C), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB71C1C),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Where to?',
                              style: TextStyle(
                                color: Color(0xFF880E14),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextField(
                              controller: controller,
                              onChanged: onQueryChanged,
                              autofocus: false,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 4),
                                border: InputBorder.none,
                                hintText: 'Where to?',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSearching)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFB71C1C),
                          ),
                        )
                      else if (controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: onClear,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5E7EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Shortcut pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: shortcuts.map((shortcut) {
                final isHighlight = shortcut.isHighlighted;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onShortcutTap(shortcut.id),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isHighlight ? const Color(0xFFFFEBEE) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isHighlight ? const Color(0xFFFFCDD2) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            shortcut.icon,
                            size: 15,
                            color: isHighlight ? const Color(0xFFB71C1C) : const Color(0xFF4B5563),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            shortcut.label,
                            style: TextStyle(
                              color: isHighlight ? const Color(0xFF880E14) : const Color(0xFF374151),
                              fontSize: 12.5,
                              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
