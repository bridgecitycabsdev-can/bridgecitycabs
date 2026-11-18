import 'package:flutter/material.dart';
import '../../data/models/past_trip_detail_model.dart';

class QaScenarioInspectorBar extends StatelessWidget {
  final PastTripQaScenario selectedScenario;
  final ValueChanged<PastTripQaScenario> onScenarioSelected;

  const QaScenarioInspectorBar({
    super.key,
    required this.selectedScenario,
    required this.onScenarioSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeIndex = selectedScenario.index + 1;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.circle, size: 7, color: Color(0xFFDC2626)),
                    SizedBox(width: 6),
                    Text(
                      'QA SCENARIO INSPECTOR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$activeIndex / 9 Active',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: PastTripQaScenario.values.map((sc) {
                final isSelected = sc == selectedScenario;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(sc.chipLabel),
                    selected: isSelected,
                    onSelected: (_) => onScenarioSelected(sc),
                    selectedColor: const Color(0xFF1F2937),
                    backgroundColor: const Color(0xFFF3F4F6),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
        ],
      ),
    );
  }
}
