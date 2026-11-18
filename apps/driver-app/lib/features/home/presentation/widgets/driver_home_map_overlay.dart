import 'package:flutter/material.dart';
import '../../data/models/driver_home_metrics.dart';
import '../../data/models/driver_home_status.dart';
import '../../data/models/driver_surge_zone.dart';

class DriverHomeMapOverlay extends StatelessWidget {
  final DriverHomeStatus status;
  final DriverHomeMetrics metrics;
  final DriverSurgeZone surgeZone;
  final bool isDarkMode;
  final VoidCallback onMenuPressed;
  final VoidCallback onEarningsPressed;
  final VoidCallback onThemePressed;
  final VoidCallback onLocationTargetPressed;

  const DriverHomeMapOverlay({
    super.key,
    required this.status,
    required this.metrics,
    required this.surgeZone,
    required this.isDarkMode,
    required this.onMenuPressed,
    required this.onEarningsPressed,
    required this.onThemePressed,
    required this.onLocationTargetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode ? const Color(0xFF1E242B) : const Color(0xFFE8ECEF),
      child: Stack(
        children: [
          // Simulated Map Graphic & Grid Lines
          CustomPaint(
            size: Size.infinite,
            painter: _LethbridgeMapPainter(isDarkMode: isDarkMode),
          ),

          // Surge Zone Overlay on Map (State 2)
          if (status == DriverHomeStatus.onlineSearching)
            Positioned(
              top: 130,
              left: 100,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC62828).withOpacity(0.12),
                  border: Border.all(
                    color: const Color(0xFFC62828).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: const Text(
                      '1.3x Surge',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC62828),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Center Vehicle Pin based on Status
          Center(
            child: _buildCenterVehiclePin(),
          ),

          // Floating Location Pill (State 4 & 7)
          if (status == DriverHomeStatus.shiftAway)
            Positioned(
              top: 90,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 6, color: Color(0xFFC62828)),
                    SizedBox(width: 6),
                    Text(
                      'Downtown Lethbridge • 3 Ave S',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (status == DriverHomeStatus.accountPending)
            Positioned(
              top: 155,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 6, color: Color(0xFF9CA3AF)),
                      SizedBox(width: 6),
                      Text(
                        'UNIT 42 • INACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating Map Target / Recenter Button (Right)
          Positioned(
            right: 16,
            top: 230,
            child: InkWell(
              onTap: onLocationTargetPressed,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  status == DriverHomeStatus.locationOff
                      ? Icons.location_disabled
                      : Icons.my_location,
                  color: status == DriverHomeStatus.locationOff
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFFC62828),
                  size: 20,
                ),
              ),
            ),
          ),

          // Top Network Disconnected Alert Strip (State 5)
          if (status == DriverHomeStatus.networkOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: const Color(0xFFFFEBEE),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.wifi_off, size: 13, color: Color(0xFFC62828)),
                    SizedBox(width: 6),
                    Text(
                      'Signal paused • Auto-reconnecting GPS...',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top Floating Navigation Bar (Menu, Earnings, Theme)
          Positioned(
            top: status == DriverHomeStatus.networkOffline ? 36 : 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hamburger Menu Button
                _buildCircleButton(
                  keyString: 'driver_home_menu_button',
                  icon: Icons.menu,
                  onTap: onMenuPressed,
                ),

                // Today Earnings Pill Button
                InkWell(
                  key: const ValueKey('driver_home_earnings_pill'),
                  onTap: onEarningsPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (metrics.isEarningsLocked) ...[
                          const Icon(Icons.lock_outline,
                              size: 14, color: Color(0xFF4B5563)),
                          const SizedBox(width: 4),
                          const Text(
                            'Today \$0.00',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'TODAY ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            '\$${metrics.todayEarnings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.sync,
                              size: 14, color: Color(0xFF4B5563)),
                        ],
                      ],
                    ),
                  ),
                ),

                // Day / Night Toggle
                _buildCircleButton(
                  keyString: 'driver_home_theme_toggle',
                  icon: isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined,
                  onTap: onThemePressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required String keyString,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: ValueKey(keyString),
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1F2937), size: 20),
      ),
    );
  }

  Widget _buildCenterVehiclePin() {
    switch (status) {
      case DriverHomeStatus.offline:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Text(
                'Parked',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE5E7EB),
              ),
              child: const Icon(Icons.local_taxi,
                  color: Color(0xFF6B7280), size: 22),
            ),
          ],
        );

      case DriverHomeStatus.onlineSearching:
        return Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFEBEE),
            border: Border.all(color: const Color(0xFFC62828), width: 2),
          ),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFC62828),
              ),
              child: const Icon(Icons.local_taxi,
                  color: Colors.white, size: 20),
            ),
          ),
        );

      case DriverHomeStatus.locationOff:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFCDD2).withOpacity(0.4),
              ),
              child: Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.location_disabled,
                      color: Color(0xFFC62828), size: 20),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'SIGNAL LOST',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        );

      case DriverHomeStatus.shiftAway:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFC62828),
              ),
              child: const Icon(Icons.local_taxi,
                  color: Colors.white, size: 24),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFBBF24),
                ),
                child: const Icon(Icons.pause, size: 10, color: Colors.black),
              ),
            ),
          ],
        );

      case DriverHomeStatus.incomingOffer:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFEBEE).withOpacity(0.6),
                border: Border.all(color: const Color(0xFFC62828)),
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC62828),
                  ),
                  child: const Icon(Icons.local_taxi,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.volume_up, size: 12, color: Color(0xFFC62828)),
                    SizedBox(width: 2),
                    Text('ılı',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFC62828))),
                  ],
                ),
              ),
            ),
          ],
        );

      case DriverHomeStatus.accountPending:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE5E7EB),
              ),
              child: const Icon(Icons.local_taxi,
                  color: Color(0xFF6B7280), size: 22),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFC62828),
                ),
                child: const Icon(Icons.lock, size: 10, color: Colors.white),
              ),
            ),
          ],
        );

      case DriverHomeStatus.networkOffline:
      default:
        return Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE5E7EB),
          ),
          child: const Icon(Icons.local_taxi,
              color: Color(0xFF6B7280), size: 22),
        );
    }
  }
}

class _LethbridgeMapPainter extends CustomPainter {
  final bool isDarkMode;

  _LethbridgeMapPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final riverPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF26384A) : const Color(0xFFBFDBFE)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF2D3748) : const Color(0xFFCBD5E1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final hwyPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF4A5568) : const Color(0xFFFED7AA)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Draw Old Man River winding curve
    final riverPath = Path()
      ..moveTo(size.width * 0.35, 0)
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.2,
        size.width * 0.2,
        size.height * 0.4,
        size.width * 0.1,
        size.height * 0.6,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Draw Highway 3 & Crowsnest Hwy
    final hwyPath = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.32);
    canvas.drawPath(hwyPath, hwyPaint);

    // Draw Secondary street lines
    canvas.drawLine(
        Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.2), roadPaint);
    canvas.drawLine(
        Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.55, 0), Offset(size.width * 0.55, size.height), roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.8, 0), Offset(size.width * 0.8, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant _LethbridgeMapPainter oldDelegate) =>
      oldDelegate.isDarkMode != isDarkMode;
}
