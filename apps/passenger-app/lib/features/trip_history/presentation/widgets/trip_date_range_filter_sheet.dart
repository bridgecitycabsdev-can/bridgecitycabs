import 'package:flutter/material.dart';

class TripDateRangeFilterSheet extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final void Function(DateTime start, DateTime end) onApplyRange;
  final VoidCallback onReset;
  final VoidCallback onClose;

  const TripDateRangeFilterSheet({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.onApplyRange,
    required this.onReset,
    required this.onClose,
  });

  @override
  State<TripDateRangeFilterSheet> createState() => _TripDateRangeFilterSheetState();
}

class _TripDateRangeFilterSheetState extends State<TripDateRangeFilterSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedQuickRange = 'Custom';

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;
  }

  int get _dayCount => _endDate.difference(_startDate).inDays + 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Row with Title & Close (X)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select date range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Filter completed trips in Southern Alberta',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF4B5563),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick range filter chips
          Row(
            children: [
              _buildQuickChip('Last 7 days', () {
                setState(() {
                  _selectedQuickRange = 'Last 7 days';
                  _startDate = DateTime(2026, 8, 16);
                  _endDate = DateTime(2026, 8, 22);
                });
              }),
              const SizedBox(width: 8),
              _buildQuickChip('This month', () {
                setState(() {
                  _selectedQuickRange = 'This month';
                  _startDate = DateTime(2026, 8, 1);
                  _endDate = DateTime(2026, 8, 31);
                });
              }),
              const SizedBox(width: 8),
              _buildQuickChip('Custom', () {
                setState(() {
                  _selectedQuickRange = 'Custom';
                  _startDate = DateTime(2026, 8, 15);
                  _endDate = DateTime(2026, 8, 22);
                });
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Calendar Month Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'August 2026',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  _buildNavArrow(Icons.chevron_left, () {}),
                  const SizedBox(width: 8),
                  _buildNavArrow(Icons.chevron_right, () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Days of week header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeekdayText('S'),
              _WeekdayText('M'),
              _WeekdayText('T'),
              _WeekdayText('W'),
              _WeekdayText('T'),
              _WeekdayText('F'),
              _WeekdayText('S'),
            ],
          ),
          const SizedBox(height: 8),

          // Calendar Month Days Grid (August 2026: 15-22 selected)
          _buildCalendarGrid(),
          const SizedBox(height: 16),

          // Selected Range Pill Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_startDate.day} Aug ${_startDate.year} – ${_endDate.day} Aug ${_endDate.year}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_dayCount days',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Apply range button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => widget.onApplyRange(_startDate, _endDate),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Apply range',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Reset button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _startDate = DateTime(2026, 8, 22);
                  _endDate = DateTime(2026, 8, 22);
                  _selectedQuickRange = 'Today';
                });
                widget.onReset();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4B5563),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    final isSelected = _selectedQuickRange == label;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildNavArrow(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF4B5563)),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // 5 rows of 7 days
    final weeks = [
      [26, 27, 28, 29, 30, 31, 1],
      [2, 3, 4, 5, 6, 7, 8],
      [9, 10, 11, 12, 13, 14, 15],
      [16, 17, 18, 19, 20, 21, 22],
      [23, 24, 25, 26, 27, 28, 29],
      [30, 31, 1, 2, 3, 4, 5],
    ];

    return Column(
      children: weeks.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final week = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.asMap().entries.map((dayEntry) {
              final colIndex = dayEntry.key;
              final dayNum = dayEntry.value;

              final isFaded = (rowIndex == 0 && colIndex < 6) || (rowIndex == 5 && colIndex > 1);
              final isStart = rowIndex == 2 && colIndex == 6; // Aug 15
              final isEnd = rowIndex == 3 && colIndex == 6;   // Aug 22
              final isInRange = rowIndex == 3 && colIndex < 6; // Aug 16-21

              if (isStart || isEnd) {
                return Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }

              if (isInRange) {
                return Container(
                  width: 34,
                  height: 34,
                  color: const Color(0xFFFEF2F2),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      color: isFaded ? const Color(0xFFD1D5DB) : const Color(0xFF1F2937),
                      fontWeight: isFaded ? FontWeight.w400 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekdayText extends StatelessWidget {
  final String letter;
  const _WeekdayText(this.letter);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
