import 'package:flutter/material.dart';
import '../../data/models/side_menu_model.dart';

class QaStatePreviewRigBar extends StatelessWidget {
  final QaSideMenuState currentState;
  final ValueChanged<QaSideMenuState> onStateChanged;

  const QaStatePreviewRigBar({
    super.key,
    required this.currentState,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1F2937),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'STATE PREVIEW RIG · BRIDGE CITY 390×844 Canvas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildRigChip(
                label: '1. Default',
                state: QaSideMenuState.defaultState,
              ),
              const SizedBox(width: 8),
              _buildRigChip(
                label: '2. Unread Badge',
                state: QaSideMenuState.unreadBadge,
              ),
              const SizedBox(width: 8),
              _buildRigChip(
                label: '3. Live Trip Active',
                state: QaSideMenuState.liveTripActive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRigChip({
    required String label,
    required QaSideMenuState state,
  }) {
    final isSelected = currentState == state;
    return GestureDetector(
      onTap: () => onStateChanged(state),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC2626) : const Color(0xFF374151),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFEF4444) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
