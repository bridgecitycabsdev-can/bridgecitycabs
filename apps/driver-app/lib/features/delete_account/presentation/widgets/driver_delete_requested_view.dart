import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_delete_account_bloc.dart';
import '../../bloc/driver_delete_account_event.dart';
import '../../bloc/driver_delete_account_state.dart';
import '../../data/models/driver_delete_status.dart';

class DriverDeleteRequestedView extends StatelessWidget {
  final DriverDeleteAccountState state;

  const DriverDeleteRequestedView({
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
          const SizedBox(height: 18),
          _buildHeroHeader(conf),
          const SizedBox(height: 20),
          _buildFinalPayoutCard(conf),
          const SizedBox(height: 14),
          _buildGraceProtocolCard(conf),
          const SizedBox(height: 14),
          _buildDispatcherCard(conf),
          const SizedBox(height: 24),
          _buildDoneButton(context),
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
                '1. Confirmation Screen',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                context.read<DriverDeleteAccountBloc>().add(
                      const DriverDeleteSwitchView(DriverDeleteStatus.recoveryBanner),
                    );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: const Text(
                  '2. In-App Recovery Banner',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B6565),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(conf) {
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBECEC),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.local_taxi, color: Color(0xFF8B181B), size: 30),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B181B),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.delete_sweep, color: Colors.white, size: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 6, color: Color(0xFF8B181B)),
                const SizedBox(width: 6),
                Text(
                  conf.fleetUnit,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Deletion requested',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your account will be deleted on ${conf.deletionTargetDate}. Log in before then to cancel. Remaining earnings will be paid out in your final statement.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B6565),
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPayoutCard(conf) {
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.payments_outlined, color: Color(0xFF2E7D32), size: 18),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Final payout scheduled',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '\$${conf.finalPayoutAmount.toStringAsFixed(2)} CAD',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Direct deposit for remaining shift fares & tips will clear on ${conf.finalPayoutDate} to your ${conf.bankAccountMasked}.',
            style: const TextStyle(fontSize: 11, color: Color(0xFF555555), height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildGraceProtocolCard(conf) {
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBECEC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.shield_outlined, color: Color(0xFF8B181B), size: 18),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '30-day grace protocol',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Hold active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B181B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Driver shift dispatches are temporarily disabled. Your medallion profile, ${conf.driverRating} rating, and tenure can be fully restored instantly anytime by logging back in.',
            style: const TextStyle(fontSize: 11, color: Color(0xFF555555), height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatcherCard(conf) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFEF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2DDDD)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE5DFDF),
            child: const Icon(Icons.headset_mic_outlined, size: 16, color: Color(0xFF4A4A4A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need dispatcher assistance?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lethbridge Central Depot: ${conf.depotPhone}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E1E1E),
              elevation: 0,
              side: const BorderSide(color: Color(0xFFD6D1D1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            child: const Text(
              'Call',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<DriverDeleteAccountBloc>().add(
                    const DriverDeleteCompleteSignout(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B181B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            label: const Text(
              'Done',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            icon: const Icon(Icons.exit_to_app, size: 18),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Signs out driver and returns to phone verification screen',
          style: TextStyle(fontSize: 11, color: Color(0xFF757575)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
