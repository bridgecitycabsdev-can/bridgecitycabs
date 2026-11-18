import 'package:flutter/material.dart';
import '../../data/models/driver_navigation_settings.dart';

class DriverNavigationView extends StatelessWidget {
  final DriverNavigationSettings settings;
  final ValueChanged<DriverNavProvider> onSelectProvider;
  final Function(String key, bool value) onToggleSwitch;
  final VoidCallback onSave;

  const DriverNavigationView({
    super.key,
    required this.settings,
    required this.onSelectProvider,
    required this.onToggleSwitch,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fleet GPS Profile Banner
          Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF37474F), Color(0xFF546E7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_car_rounded, color: Color(0xFFFFCDD2), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'FLEET GPS\nPROFILE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
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
                      Text(
                        settings.fleetGpsStatus,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Provider Header
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.explore_outlined, color: Color(0xFFC62828), size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Navigation Provider',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select the GPS app used when you tap "Start Route" or navigate to passenger pickup in Lethbridge.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Provider Cards
          ...DriverNavProvider.values.map((provider) {
            final isSelected = settings.provider == provider;
            final badge = provider.badgeText;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFC62828) : const Color(0xFFEEEEEE),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSelectProvider(provider),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            provider == DriverNavProvider.googleMaps
                                ? Icons.location_on_rounded
                                : provider == DriverNavProvider.appleMaps
                                    ? Icons.explore_rounded
                                    : Icons.navigation_rounded,
                            color: isSelected ? const Color(0xFFC62828) : const Color(0xFF616161),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    provider.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? const Color(0xFFC62828) : const Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  if (badge != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: badge == 'Recommended'
                                            ? const Color(0xFFC62828)
                                            : const Color(0xFFEEEEEE),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        badge,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: badge == 'Recommended' ? Colors.white : const Color(0xFF616161),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.subtitle,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF757575), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          color: isSelected ? const Color(0xFFC62828) : const Color(0xFFBDBDBD),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // GPS Ergonomics Switches
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              children: [
                _buildSwitchRow(
                  icon: Icons.volume_up_outlined,
                  title: 'In-app audio alerts',
                  subtitle: 'Hear dispatch updates while GPS speaks',
                  value: settings.inAppAudioAlerts,
                  onChanged: (val) => onToggleSwitch('inAppAudio', val),
                ),
                const Divider(height: 24, color: Color(0xFFEEEEEE)),
                _buildSwitchRow(
                  icon: Icons.refresh_rounded,
                  title: 'Auto-return upon arrival',
                  subtitle: 'Reopen meter once within 30m of pickup',
                  value: settings.autoReturnUponArrival,
                  onChanged: (val) => onToggleSwitch('autoReturn', val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Picture in Picture Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF616161)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Turn-by-turn directions will automatically open in the app you choose when dispatch navigation is initiated. You can switch back to Bridge City Cabs Driver with one tap from the picture-in-picture widget.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF616161), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Save Preference Button
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
              label: const Text(
                'Save preference',
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

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFC62828)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: const Color(0xFFC62828),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
