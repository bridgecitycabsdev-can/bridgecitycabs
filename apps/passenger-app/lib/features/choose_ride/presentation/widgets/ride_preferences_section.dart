import 'package:flutter/material.dart';
import '../../data/models/choose_ride_config.dart';
import '../../data/models/ride_preference.dart';

class RidePreferencesSection extends StatelessWidget {
  final RidePreference preference;
  final ValueChanged<bool> onVanOnlyChanged;
  final ValueChanged<bool> onLadyDriverChanged;

  const RidePreferencesSection({
    super.key,
    required this.preference,
    required this.onVanOnlyChanged,
    required this.onLadyDriverChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          // Van only toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.airport_shuttle_outlined,
                  color: Color(0xFF4B5563),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        ChooseRideConfig.vanOnlyTitle,
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ChooseRideConfig.vanOnlyDesc,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: preference.vanOnly,
                  activeColor: const Color(0xFFB71C1C),
                  onChanged: onVanOnlyChanged,
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 46, color: Color(0xFFE5E7EB)),

          // Lady driver only toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF4B5563),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            ChooseRideConfig.ladyDriverTitle,
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (preference.ladyDriverOnly) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                ChooseRideConfig.ladyDriverPreferred,
                                style: TextStyle(
                                  color: Color(0xFFB71C1C),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Text(
                        ChooseRideConfig.ladyDriverDesc,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: preference.ladyDriverOnly,
                  activeColor: const Color(0xFFB71C1C),
                  onChanged: onLadyDriverChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
