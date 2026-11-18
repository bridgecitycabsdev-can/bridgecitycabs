import 'package:flutter/material.dart';
import '../../data/models/driver_insurance_data.dart';

class DriverInsuranceView extends StatelessWidget {
  final DriverInsuranceData insurance;
  final int activeTabIndex;
  final ValueChanged<int> onTabSwitched;
  final VoidCallback onContactDispatch;
  final VoidCallback onDownloadPdf;

  const DriverInsuranceView({
    super.key,
    required this.insurance,
    required this.activeTabIndex,
    required this.onTabSwitched,
    required this.onContactDispatch,
    required this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Segmented Tabs: Insurance, FAQs, Terms
          Row(
            children: [
              _buildSegmentTab(0, Icons.shield_outlined, 'Insurance'),
              const SizedBox(width: 8),
              _buildSegmentTab(1, Icons.help_outline_rounded, 'FAQs'),
              const SizedBox(width: 8),
              _buildSegmentTab(2, Icons.description_outlined, 'Terms'),
            ],
          ),
          const SizedBox(height: 14),

          // Fleet Sync Status Row
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  insurance.fleetSyncStatus,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF616161),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Skeleton',
                  style: TextStyle(fontSize: 10, color: Color(0xFF757575)),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Error',
                  style: TextStyle(fontSize: 10, color: Color(0xFF757575)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Active Policy Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Color(0xFFC62828),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              insurance.statusLabel,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            insurance.policyNumber,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Commercial Vehicle Insurance Policy',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insurance.underwritingCompany,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // WHAT'S COVERED DURING TRIPS
          const Row(
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF2E7D32)),
              SizedBox(width: 6),
              Text(
                "What's Covered During Trips",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...insurance.benefits.map((benefit) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_outlined,
                      color: Color(0xFF2E7D32),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          benefit.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          benefit.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF757575),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // REQUIRED IN-CAB DOCUMENTS
          Row(
            children: [
              const Icon(Icons.assignment_late_outlined, size: 16, color: Color(0xFFC62828)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Required In-Cab Documents',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'MANDATORY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'City of Lethbridge Bylaw 6141 requires every driver to present physical or authorized digital proof upon peace officer inspection:',
            style: TextStyle(fontSize: 11, color: Color(0xFF757575), height: 1.3),
          ),
          const SizedBox(height: 10),

          ...insurance.requiredDocuments.map((doc) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge_outlined, color: Color(0xFFC62828), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        Text(
                          doc.subtitle,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF2E7D32),
                    size: 18,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // COLLISION & INCIDENT PROTOCOL
          const Row(
            children: [
              Icon(Icons.car_crash_outlined, size: 16, color: Color(0xFFC62828)),
              SizedBox(width: 6),
              Text(
                'Collision & Incident Protocol',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...insurance.collisionSteps.map((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC62828),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${step.stepNumber}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF616161),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          // Contact Dispatch Button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onContactDispatch,
              icon: const Icon(Icons.phone_in_talk, color: Colors.white, size: 18),
              label: const Text(
                'Contact 24/7 Fleet Dispatch Support',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Download PDF Button
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onDownloadPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFFC62828), size: 18),
              label: const Text(
                'Download Insurance Certificate (PDF)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFCDD2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(int index, IconData icon, String label) {
    final isSelected = activeTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSwitched(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFEBEE) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFC62828) : const Color(0xFFEEEEEE),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFFC62828) : const Color(0xFF757575),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFFC62828) : const Color(0xFF424242),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
