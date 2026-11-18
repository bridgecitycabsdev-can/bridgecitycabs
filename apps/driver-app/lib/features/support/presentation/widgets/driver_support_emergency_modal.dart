import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_support_bloc.dart';
import '../../bloc/driver_support_event.dart';
import '../../bloc/driver_support_state.dart';
import '../../data/models/driver_support_status.dart';
import '../../data/models/driver_support_topic.dart';

class DriverSupportEmergencyModal extends StatelessWidget {
  final DriverSupportState state;

  const DriverSupportEmergencyModal({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD6D1D1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildTelemetryPill(),
          const SizedBox(height: 18),
          _buildShieldIcon(),
          const SizedBox(height: 16),
          const Text(
            'Are you in danger right now?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1E1E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Immediate safety threats and active roadside incidents receive priority dispatch escalation.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B6565),
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildPoliceAlertNotice(),
          const SizedBox(height: 20),
          _buildSosAlertButton(context),
          const SizedBox(height: 12),
          _buildReportPastIssueButton(context),
          const SizedBox(height: 20),
          const Text(
            'IF YOU ARE IN IMMEDIATE DANGER, ALSO CALL 911.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8B181B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              context.read<DriverSupportBloc>().add(
                    const DriverSupportSwitchView(DriverSupportViewStatus.center),
                  );
            },
            child: const Text(
              'Dismiss / Close',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5DFDF)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: Color(0xFF8B181B)),
          SizedBox(width: 6),
          Text(
            'CAB #142 • LETHBRIDGE FLEET',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF757575)),
          SizedBox(width: 3),
          Text(
            'GPS Transmitting',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShieldIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFFFBECEC),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.shield,
          size: 32,
          color: Color(0xFF8B181B),
        ),
      ),
    );
  }

  Widget _buildPoliceAlertNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFEF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.crisis_alert, size: 18, color: Color(0xFF8B181B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Distress signals instantly alert Lethbridge Police Services (LPS) and lock vehicle telemetry.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF333333),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosAlertButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<DriverSupportBloc>().add(
                const DriverSupportEmergencySosTriggered(),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB71C1C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
        ),
        icon: const Text('🚨', style: TextStyle(fontSize: 16)),
        label: const Text(
          'Send SOS alert',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildReportPastIssueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          context.read<DriverSupportBloc>().add(
                const DriverSupportSelectTopic(DriverSupportTopic.safety),
              );
          context.read<DriverSupportBloc>().add(
                const DriverSupportSwitchView(DriverSupportViewStatus.newTicket),
              );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF1EFEF),
          foregroundColor: const Color(0xFF1E1E1E),
          side: const BorderSide(color: Color(0xFFD6D1D1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFF1E1E1E)),
                SizedBox(width: 6),
                Text(
                  'Report a past issue',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 2),
            Text(
              'Opens support ticket with Safety preselected',
              style: TextStyle(fontSize: 10, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }
}
