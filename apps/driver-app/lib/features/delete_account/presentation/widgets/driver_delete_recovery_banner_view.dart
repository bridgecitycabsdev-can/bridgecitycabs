import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_delete_account_bloc.dart';
import '../../bloc/driver_delete_account_event.dart';
import '../../bloc/driver_delete_account_state.dart';
import '../../data/models/driver_delete_status.dart';

class DriverDeleteRecoveryBannerView extends StatelessWidget {
  final DriverDeleteAccountState state;

  const DriverDeleteRecoveryBannerView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final conf = state.confirmationData;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSegmentedTabHeader(context),
          const SizedBox(height: 20),
          _buildRecoveryBannerCard(context, conf),
          const SizedBox(height: 16),
          _buildPreservedDetailsCard(conf),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAEA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                context.read<DriverDeleteAccountBloc>().add(
                      const DriverDeleteSwitchView(DriverDeleteStatus.deletionRequested),
                    );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: const Text(
                  '1. Confirmation Screen',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B6565),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                '2. In-App Recovery Banner',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryBannerCard(BuildContext context, conf) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 22, color: Color(0xFF856404)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Account Deletion In Progress',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF856404),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECC0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '24 days left',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Your account is currently scheduled for permanent erasure on ${conf.deletionTargetDate}. Logging in grants full grace restoration.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF66512C), height: 1.35),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<DriverDeleteAccountBloc>().add(
                      const DriverDeleteRestoreAccount(),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B181B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.restore, size: 18),
              label: const Text(
                'Cancel Deletion & Restore Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreservedDetailsCard(conf) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preserved Fleet Credentials',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Fleet Unit', conf.fleetUnit),
          _buildInfoRow('Driver Rating', conf.driverRating),
          _buildInfoRow('Final Statement Payout', '\$${conf.finalPayoutAmount.toStringAsFixed(2)} CAD'),
          _buildInfoRow('Deposit Date', conf.finalPayoutDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }
}
