import 'package:flutter/material.dart';
import '../../data/models/driver_earnings_period.dart';

class DriverEarningsFilterSheet extends StatelessWidget {
  final DriverEarningsPeriod selectedPeriod;
  final String customStartDate;
  final String customEndDate;
  final bool isCustomExpanded;
  final ValueChanged<DriverEarningsPeriod> onPeriodSelected;
  final ValueChanged<String> onStartDateChanged;
  final ValueChanged<String> onEndDateChanged;
  final VoidCallback onApply;
  final VoidCallback onClose;

  const DriverEarningsFilterSheet({
    super.key,
    required this.selectedPeriod,
    required this.customStartDate,
    required this.customEndDate,
    required this.isCustomExpanded,
    required this.onPeriodSelected,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onApply,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earnings period',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Select statement view or custom dates',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF616161),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Period Options
          _buildPeriodOption(
            period: DriverEarningsPeriod.today,
            amountText: '\$41.77',
          ),
          _buildPeriodOption(
            period: DriverEarningsPeriod.thisWeek,
            amountText: '\$53.93',
            badgeText: 'ACTIVE',
          ),
          _buildPeriodOption(
            period: DriverEarningsPeriod.thisMonth,
            amountText: '\$1,248.50',
          ),
          _buildPeriodOption(
            period: DriverEarningsPeriod.lastMonth,
            amountText: '\$2,840.10',
          ),
          _buildPeriodOption(
            period: DriverEarningsPeriod.customRange,
            amountText: '',
          ),

          // Custom Date Range Expansion
          if (isCustomExpanded ||
              selectedPeriod == DriverEarningsPeriod.customRange) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerBox(
                    label: 'START DATE',
                    dateString: customStartDate,
                    onTap: () => onStartDateChanged('10 Jun 2024'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePickerBox(
                    label: 'END DATE',
                    dateString: customEndDate,
                    onTap: () => onEndDateChanged('24 Jun 2024'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(
                  Icons.date_range_rounded,
                  size: 14,
                  color: Color(0xFF757575),
                ),
                SizedBox(width: 6),
                Text(
                  '14 days selected',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
              label: const Text(
                'Apply period filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPeriodOption({
    required DriverEarningsPeriod period,
    required String amountText,
    String? badgeText,
  }) {
    final isSelected = selectedPeriod == period;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF5F5) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFD32F2F) : const Color(0xFFEEEEEE),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onPeriodSelected(period),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFBDBDBD),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Label
                Text(
                  period.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(width: 8),

                // Optional badge
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                const Spacer(),

                // Amount
                if (amountText.isNotEmpty)
                  Text(
                    amountText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF424242),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerBox({
    required String label,
    required String dateString,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF424242),
                ),
                const SizedBox(width: 6),
                Text(
                  dateString,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
