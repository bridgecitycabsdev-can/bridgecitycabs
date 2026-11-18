import 'package:flutter/material.dart';
import '../../data/models/driver_theme_settings.dart';

class DriverThemeView extends StatelessWidget {
  final DriverThemeSettings settings;
  final ValueChanged<DriverThemeMode> onSelectMode;
  final Function(String key, bool value) onToggleSwitch;
  final VoidCallback onApplyTheme;

  const DriverThemeView({
    super.key,
    required this.settings,
    required this.onSelectMode,
    required this.onToggleSwitch,
    required this.onApplyTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose your preferred interface appearance for daytime shifts and night driving across Lethbridge.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF616161),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // 3 Visual Theme Cards
          Row(
            children: [
              Expanded(
                child: _buildThemeCard(
                  mode: DriverThemeMode.light,
                  title: 'Light',
                  subtitle: 'Day cockpit',
                  mockBg: const Color(0xFFFFFFFF),
                  mockAccent: const Color(0xFFC62828),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildThemeCard(
                  mode: DriverThemeMode.dark,
                  title: 'Dark',
                  subtitle: 'Night shift',
                  mockBg: const Color(0xFF1E1E1E),
                  mockAccent: const Color(0xFFC62828),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildThemeCard(
                  mode: DriverThemeMode.system,
                  title: 'System',
                  subtitle: 'Auto-synced',
                  isSplit: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Independent Map HUD Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.wb_twilight_rounded, size: 20, color: Color(0xFFC62828)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Independent Map HUD',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'The GPS home map retains its dedicated day and night toggle on the driver dash. This setting formats dispatch orders, ride meter sheets, and weekly payouts.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF616161), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // DISPLAY ERGONOMICS (SHIFT CONTROLS)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Display Ergonomics',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              Text(
                'SHIFT CONTROLS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC62828), letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),

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
                  icon: Icons.battery_charging_full_rounded,
                  title: 'Auto-dim on low battery',
                  subtitle: 'Protects cab tablet below 20% power',
                  value: settings.autoDimLowBattery,
                  onChanged: (val) => onToggleSwitch('autoDim', val),
                ),
                const Divider(height: 24, color: Color(0xFFEEEEEE)),
                _buildSwitchRow(
                  icon: Icons.stay_current_portrait_rounded,
                  title: 'Keep screen awake while online',
                  subtitle: 'Prevents phone sleep during live dispatch',
                  value: settings.keepScreenAwakeWhileOnline,
                  onChanged: (val) => onToggleSwitch('keepAwake', val),
                ),
                const Divider(height: 24, color: Color(0xFFEEEEEE)),
                _buildSwitchRow(
                  icon: Icons.text_fields_rounded,
                  title: 'Large font accessibility',
                  subtitle: 'Maximizes fare readout distances',
                  value: settings.largeFontAccessibility,
                  onChanged: (val) => onToggleSwitch('largeFont', val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Apply Theme Button
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onApplyTheme,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              label: const Text(
                'Apply Theme',
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

  Widget _buildThemeCard({
    required DriverThemeMode mode,
    required String title,
    required String subtitle,
    Color mockBg = Colors.white,
    Color mockAccent = const Color(0xFFC62828),
    bool isSplit = false,
  }) {
    final isSelected = settings.mode == mode;

    return InkWell(
      onTap: () => onSelectMode(mode),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFC62828) : const Color(0xFFEEEEEE),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            // Preview Mock Frame
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: mockBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Stack(
                children: [
                  if (isSplit)
                    Row(
                      children: [
                        Expanded(child: Container(color: Colors.white)),
                        Expanded(child: Container(color: const Color(0xFF1E1E1E))),
                      ],
                    ),
                  Center(
                    child: Icon(
                      mode == DriverThemeMode.light
                          ? Icons.local_taxi_rounded
                          : mode == DriverThemeMode.dark
                              ? Icons.nightlight_round
                              : Icons.brightness_auto,
                      color: mode == DriverThemeMode.dark ? const Color(0xFFC62828) : const Color(0xFFB71C1C),
                      size: 24,
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC62828),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFFC62828) : const Color(0xFF1E1E1E),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
            ),
          ],
        ),
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
        Icon(icon, size: 20, color: const Color(0xFF616161)),
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
