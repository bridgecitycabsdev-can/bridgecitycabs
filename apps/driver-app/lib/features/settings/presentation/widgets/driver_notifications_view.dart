import 'package:flutter/material.dart';
import '../../data/models/driver_notification_settings.dart';

class DriverNotificationsView extends StatelessWidget {
  final DriverNotificationSettings settings;
  final Function(String key, bool value) onToggleAlert;
  final ValueChanged<DriverDispatchChime> onSelectChime;
  final VoidCallback onSimulateChime;

  const DriverNotificationsView({
    super.key,
    required this.settings,
    required this.onToggleAlert,
    required this.onSelectChime,
    required this.onSimulateChime,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Notifications are off Alert Banner
          if (!settings.isPermissionGranted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFECC0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        color: Color(0xFF8D6E63),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Notifications are off',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enable notification permissions to never miss incoming trip requests and urgent Lethbridge dispatch updates.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5D4037),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4037),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Open settings',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),

          // DISPATCH & TRIP ALERTS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DISPATCH & TRIP ALERTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${settings.activeAlertsCount} of 4 Active',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
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
            child: Column(
              children: [
                _buildAlertTile(
                  icon: Icons.directions_car_outlined,
                  title: 'Ride requests',
                  subtitle: 'Sounds and alerts for new requests',
                  isActive: settings.rideRequestsAlert,
                  onChanged: (val) => onToggleAlert('rideRequests', val),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                _buildAlertTile(
                  icon: Icons.alt_route_rounded,
                  title: 'Trip updates',
                  subtitle: 'Status changes and passenger cancellation notices',
                  isActive: settings.tripUpdatesAlert,
                  onChanged: (val) => onToggleAlert('tripUpdates', val),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                _buildAlertTile(
                  icon: Icons.payments_outlined,
                  title: 'Earnings and statements',
                  subtitle: 'Weekly direct deposits and shift payout summaries',
                  isActive: settings.earningsStatementsAlert,
                  onChanged: (val) => onToggleAlert('earningsStatements', val),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                _buildAlertTile(
                  icon: Icons.campaign_outlined,
                  title: 'Promotions & announcements',
                  subtitle: 'High-demand zone surge alerts and fleet news',
                  isActive: settings.promotionsAlert,
                  onChanged: (val) => onToggleAlert('promotions', val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SOUND & HAPTICS
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SOUND & HAPTICS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.volume_up_outlined, size: 14, color: Color(0xFF2E7D32)),
                  SizedBox(width: 4),
                  Text(
                    'Cockpit Mode',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Request sound',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Chime',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose chime for incoming dispatch offers across Bridge City',
                  style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 14),

                ...DriverDispatchChime.values.map((chime) {
                  final isSelected = settings.selectedChime == chime;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFF5F5) : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFC62828) : const Color(0xFFEEEEEE),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => onSelectChime(chime),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                            color: isSelected ? const Color(0xFFC62828) : const Color(0xFFBDBDBD),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chime.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: const Color(0xFF1E1E1E),
                                  ),
                                ),
                                Text(
                                  chime.subtitle,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.play_circle_outline, color: Color(0xFF616161), size: 22),
                            onPressed: onSimulateChime,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),

                // Vibration pattern
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.vibration_rounded, size: 18, color: Color(0xFF424242)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vibration pattern',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          ),
                          Text(
                            'Vibrate device continuously during countdown',
                            style: TextStyle(fontSize: 11, color: Color(0xFF757575)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        settings.vibrationPattern ? Icons.check_circle : Icons.cancel_outlined,
                        color: settings.vibrationPattern ? const Color(0xFFC62828) : const Color(0xFFBDBDBD),
                      ),
                      onPressed: () => onToggleAlert('vibration', !settings.vibrationPattern),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // In-cab Priority Audio Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF616161)),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In-cab priority audio',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Audible alerts will play through device speakers even if phone volume is on low during online shifts, ensuring dispatch compliance throughout Lethbridge.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF616161), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Simulate Dispatch Chime Button
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onSimulateChime,
              icon: const Icon(Icons.volume_up, color: Colors.white, size: 18),
              label: const Text(
                'Simulate Dispatch Chime',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAlertTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFC62828), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 1),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              isActive ? Icons.check_circle_rounded : Icons.cancel_outlined,
              color: isActive ? const Color(0xFFC62828) : const Color(0xFFBDBDBD),
              size: 22,
            ),
            onPressed: () => onChanged(!isActive),
          ),
        ],
      ),
    );
  }
}
