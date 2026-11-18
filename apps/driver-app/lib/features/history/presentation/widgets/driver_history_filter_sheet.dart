import 'package:flutter/material.dart';
import '../../data/models/driver_trip_filter_period.dart';

class DriverHistoryFilterSheet extends StatelessWidget {
  final DriverTripFilterPeriod selectedPeriod;
  final String customStartDate;
  final String customEndDate;
  final bool isCustomExpanded;
  final ValueChanged<DriverTripFilterPeriod> onPeriodSelected;
  final ValueChanged<String> onStartDateChanged;
  final ValueChanged<String> onEndDateChanged;
  final VoidCallback onApply;
  final VoidCallback onClose;

  const DriverHistoryFilterSheet({
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

          // Period Options List
          _buildPeriodTile(
            period: DriverTripFilterPeriod.today,
            trailingIcon: Icons.calendar_today_outlined,
          ),
          _buildPeriodTile(
            period: DriverTripFilterPeriod.thisWeek,
            badgeText: 'ACTIVE',
            trailingIcon: Icons.calendar_today_outlined,
          ),
          _buildPeriodTile(
            period: DriverTripFilterPeriod.thisMonth,
            trailingIcon: Icons.calendar_today_outlined,
          ),
          _buildPeriodTile(
            period: DriverTripFilterPeriod.lastMonth,
            trailingIcon: Icons.history_rounded,
          ),
          _buildPeriodTile(
            period: DriverTripFilterPeriod.customRange,
            trailingIcon: isCustomExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
          ),

          // Custom Date Range Configuration Box
          if (isCustomExpanded ||
              selectedPeriod == DriverTripFilterPeriod.customRange) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF7F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF5E6E6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONFIGURE FILTER RANGE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B2B2B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateInputBox(
                          label: 'START DATE',
                          dateString: customStartDate,
                          onTap: () => onStartDateChanged('10 Jun 2024'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDateInputBox(
                          label: 'END DATE',
                          dateString: customEndDate,
                          onTap: () => onEndDateChanged('24 Jun 2024'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: Color(0xFF2E7D32),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '14 days selected (historical ledger)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Apply period filter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
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

  Widget _buildPeriodTile({
    required DriverTripFilterPeriod period,
    String? badgeText,
    IconData? trailingIcon,
  }) {
    final isSelected = selectedPeriod == period;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF7F7) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFB71C1C) : const Color(0xFFEEEEEE),
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
                          ? const Color(0xFFB71C1C)
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
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            period.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFFB71C1C)
                                  : const Color(0xFF212121),
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB71C1C),
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
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        period.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing icon
                if (trailingIcon != null)
                  Icon(
                    trailingIcon,
                    size: 18,
                    color: isSelected
                        ? const Color(0xFFB71C1C)
                        : const Color(0xFF9E9E9E),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInputBox({
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.flight_takeoff_rounded,
                  size: 12,
                  color: Color(0xFF8B2B2B),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF8B2B2B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateString,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF757575),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
