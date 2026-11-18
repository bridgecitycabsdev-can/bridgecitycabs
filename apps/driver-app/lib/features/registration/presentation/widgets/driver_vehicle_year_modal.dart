import 'package:flutter/material.dart';

class DriverVehicleYearModal extends StatelessWidget {
  final int selectedYear;
  final ValueChanged<int> onYearSelected;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const DriverVehicleYearModal({
    super.key,
    required this.selectedYear,
    required this.onYearSelected,
    required this.onConfirm,
    required this.onDismiss,
  });

  static const List<Map<String, dynamic>> yearOptions = [
    {'year': 2024, 'label': 'Latest'},
    {'year': 2023, 'label': 'Recent'},
    {'year': 2022, 'label': 'Standard'},
    {'year': 2021, 'label': 'Eligible'},
    {'year': 2020, 'label': 'Eligible'},
    {'year': 2019, 'label': 'Eligible'},
    {'year': 2018, 'label': 'Eligible'},
    {'year': 2017, 'label': 'Eligible'},
    {'year': 2016, 'label': 'Eligible'},
    {'year': 2015, 'label': 'Eligible'},
    {'year': 2014, 'label': 'Min. Limit'},
    {'year': 2013, 'label': 'Bylaw Ineligible'},
    {'year': 2008, 'label': 'Too Old'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text('🚗', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'Select Vehicle year',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              TextButton(
                key: const ValueKey('driver_year_modal_done_button'),
                onPressed: onConfirm,
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Qualification notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vehicles must be model year 2014 or newer to qualify for Bridge City Cabs in Lethbridge.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1B5E20),
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Scrollable year list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: yearOptions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final item = yearOptions[index];
                final year = item['year'] as int;
                final tagLabel = item['label'] as String;
                final isSelected = year == selectedYear;
                final isEligible = year >= 2014;

                return InkWell(
                  key: ValueKey('driver_year_option_$year'),
                  onTap: () => onYearSelected(year),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$year',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFFC62828)
                                    : (isEligible
                                        ? const Color(0xFF1F2937)
                                        : const Color(0xFF9CA3AF)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFC62828)
                                    : (isEligible
                                        ? const Color(0xFFF3F4F6)
                                        : const Color(0xFFFFEBEE)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isSelected ? 'SELECTED' : tagLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : (isEligible
                                          ? const Color(0xFF4B5563)
                                          : const Color(0xFFD32F2F)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Color(0xFFC62828),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              key: const ValueKey('driver_confirm_year_button'),
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                '✔ Confirm Year ($selectedYear)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Cancel button
          TextButton(
            key: const ValueKey('driver_cancel_year_button'),
            onPressed: onDismiss,
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
