import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_flag_ride_bloc.dart';
import '../../bloc/driver_flag_ride_event.dart';
import '../../bloc/driver_flag_ride_state.dart';
import '../../data/models/driver_flag_edge_state.dart';

class DriverFlagEdgeStatesView extends StatelessWidget {
  const DriverFlagEdgeStatesView({
    super.key,
    required this.state,
  });

  final DriverFlagRideState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBylawComplianceHeader(),
          const SizedBox(height: 14),
          _buildCategoryFilterChips(context),
          const SizedBox(height: 16),
          _buildEdgeStateCard(context, state.selectedEdgeState),
        ],
      ),
    );
  }

  Widget _buildBylawComplianceHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8D5D5)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'CITY OF LETHBRIDGE BYLAW 6141 COMPLIANT • Fleet Unit #42',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A2021),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DriverFlagEdgeCategory.values.map((category) {
          final isSelected = state.selectedEdgeCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                category.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF4A4A4A),
                ),
              ),
              selectedColor: const Color(0xFF8B181B),
              backgroundColor: const Color(0xFFF1EFEF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF8B181B) : const Color(0xFFD6D1D1),
                ),
              ),
              showCheckmark: false,
              onSelected: (_) {
                context.read<DriverFlagRideBloc>().add(
                      DriverFlagSelectEdgeCategoryEvent(category),
                    );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEdgeStateCard(
    BuildContext context,
    DriverFlagEdgeState edgeState,
  ) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5DFDF)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B181B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    edgeState.tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  edgeState.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8C8282),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              edgeState.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              edgeState.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6565),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            _buildStateSpecificContent(context, edgeState),
          ],
        ),
      ),
    );
  }

  Widget _buildStateSpecificContent(
    BuildContext context,
    DriverFlagEdgeState edgeState,
  ) {
    switch (edgeState) {
      case DriverFlagEdgeState.telemetryFault:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF0CBCB)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_off, color: Color(0xFF8B181B), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Satellites detected: 0 / 12 required. Lethbridge Coulee signal lock failed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B181B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<DriverFlagRideBloc>().add(
                        const DriverFlagTriggerEdgeResolutionEvent('open_settings'),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B181B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.settings, size: 18),
                label: const Text(
                  'Open device settings →',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );

      case DriverFlagEdgeState.routeConflict:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Booking: University of Lethbridge Student Union',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ETA 6 min • Pickup passenger Alex M. before accepting street hails.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B6565)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  context.read<DriverFlagRideBloc>().add(
                        const DriverFlagTriggerEdgeResolutionEvent('return_nav'),
                      );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E1E1E),
                  side: const BorderSide(color: Color(0xFF1E1E1E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Return to active navigation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );

      case DriverFlagEdgeState.authorization:
        return SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () {
              context.read<DriverFlagRideBloc>().add(
                    const DriverFlagTriggerEdgeResolutionEvent('go_online'),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B181B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Go Online to Enable Flag Rides',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );

      case DriverFlagEdgeState.initializingMeter:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.speed, color: Color(0xFFB78103), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Drop Flag Tariff Rate: \$4.10 Flat Base',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7D5700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4A4A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                label: const Text('Initializing meter & GPS...'),
              ),
            ),
          ],
        );

      case DriverFlagEdgeState.telemetryTimeout:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF3C4C4)),
              ),
              child: const Text(
                'Cellular connection timed out near River Valley coulees. (ERR_DISPATCH_TIMEOUT_504)',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B181B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  context.read<DriverFlagRideBloc>().add(
                        const DriverFlagRetryTelemetryEvent(),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B181B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );

      case DriverFlagEdgeState.fareResolution:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE3DFDF)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_top, size: 18, color: Color(0xFF8B181B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '14m 22s / 7.82 km • \$2.05/km + \$0.70/min wait',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<DriverFlagRideBloc>().add(
                        const DriverFlagTriggerEdgeResolutionEvent('refresh_calc'),
                      );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B181B),
                  side: const BorderSide(color: Color(0xFF8B181B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Refresh calculation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );

      case DriverFlagEdgeState.localBlackoutMode:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'In-Cab Vault Storage HASH #BC-LETH-88319-OFF',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Offline ride recorded to encrypted local storage. Will auto-sync when cellular coverage returns.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<DriverFlagRideBloc>().add(
                              const DriverFlagTriggerEdgeResolutionEvent('hold_meter'),
                            );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF333333),
                        side: const BorderSide(color: Color(0xFFB0A8A8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Hold Meter',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<DriverFlagRideBloc>().add(
                              const DriverFlagTriggerEdgeResolutionEvent('end_offline'),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B181B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'End Offline Ride',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}
