import 'package:flutter/material.dart';
import '../../data/models/choose_ride_qa_scenario.dart';

class DemoStateBar extends StatelessWidget {
  final ChooseRideDemoState selectedState;
  final ValueChanged<ChooseRideDemoState> onStateSelected;

  const DemoStateBar({
    super.key,
    required this.selectedState,
    required this.onStateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'DEMO STATE:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ChooseRideDemoState.values.map((st) {
                  final isSelected = st == selectedState;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(st.chipLabel),
                      selected: isSelected,
                      onSelected: (_) => onStateSelected(st),
                      selectedColor: const Color(0xFF1F2937),
                      backgroundColor: const Color(0xFFF3F4F6),
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF374151),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF1F2937)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
