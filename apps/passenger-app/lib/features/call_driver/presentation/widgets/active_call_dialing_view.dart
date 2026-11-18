import 'package:flutter/material.dart';
import '../../data/models/call_driver_config.dart';
import '../../data/models/call_driver_model.dart';

class ActiveCallDialingView extends StatelessWidget {
  final DriverCallDetails driver;
  final CallPhase phase;
  final String statusTitle;
  final String statusSubtitle;
  final bool isMuted;
  final bool isKeypadOpen;
  final bool isSpeakerOn;
  final ValueChanged<CallPhase> onPhaseChanged;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleKeypad;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onCancelCall;

  const ActiveCallDialingView({
    super.key,
    required this.driver,
    required this.phase,
    required this.statusTitle,
    required this.statusSubtitle,
    required this.isMuted,
    required this.isKeypadOpen,
    required this.isSpeakerOn,
    required this.onPhaseChanged,
    required this.onToggleMute,
    required this.onToggleKeypad,
    required this.onToggleSpeaker,
    required this.onCancelCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Top QA Phase Switcher Bar
            _buildQaPhaseBar(),
            const SizedBox(height: 16),

            // Header Pill: Bridge City Cabs Secure Voice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_taxi, color: Color(0xFFDC2626), size: 16),
                  SizedBox(width: 8),
                  Text(
                    CallDriverConfig.secureVoiceHeader,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Sub-badge: End-to-End Masked Relay
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF991B1B), size: 12),
                  SizedBox(width: 6),
                  Text(
                    CallDriverConfig.endToEndRelay,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Concentric Pulsing Ripples & Driver Avatar
            _buildAvatarWithRipples(),
            const SizedBox(height: 32),

            // Title & Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    statusTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusSubtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Red progress wave / line
                  Container(
                    width: 140,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: phase == CallPhase.connected ? 140 : 80,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Call Controls: Mute, Keypad, Speaker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: isMuted ? Icons.mic_off : Icons.mic_none,
                  label: 'Mute',
                  isActive: isMuted,
                  onTap: onToggleMute,
                ),
                const SizedBox(width: 32),
                _buildControlButton(
                  icon: Icons.dialpad,
                  label: 'Keypad',
                  isActive: isKeypadOpen,
                  onTap: onToggleKeypad,
                ),
                const SizedBox(width: 32),
                _buildControlButton(
                  icon: Icons.volume_up,
                  label: 'Speaker',
                  isActive: isSpeakerOn,
                  onTap: onToggleSpeaker,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Cancel Call / End Call Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onCancelCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: phase == CallPhase.connected
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFF3F4F6),
                    foregroundColor: phase == CallPhase.connected
                        ? Colors.white
                        : const Color(0xFF1F2937),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(
                    phase == CallPhase.connected ? 'End Call' : 'Cancel Call',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy statement
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: Color(0xFF6B7280)),
                  SizedBox(width: 6),
                  Text(
                    CallDriverConfig.privacyFooterText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQaPhaseBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildPhaseChip('● 1. Connecting', CallPhase.connecting),
            const SizedBox(width: 8),
            _buildPhaseChip('2. Ringing', CallPhase.ringing),
            const SizedBox(width: 8),
            _buildPhaseChip('3. Connected', CallPhase.connected),
            const SizedBox(width: 8),
            _buildPhaseChip('4. Ended', CallPhase.ended),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseChip(String label, CallPhase targetPhase) {
    final isSelected = phase == targetPhase;
    return GestureDetector(
      onTap: () => onPhaseChanged(targetPhase),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB91C1C) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF374151),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithRipples() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outermost soft ring
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFEE2E2).withOpacity(0.4),
          ),
        ),
        // Middle ring
        Container(
          width: 155,
          height: 155,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFEE2E2),
          ),
        ),
        // Inner avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD1D5DB),
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const ClipOval(
                child: Icon(Icons.person, size: 70, color: Color(0xFF4B5563)),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF1F2937),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFDC2626) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF1F2937),
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFFDC2626) : const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}
