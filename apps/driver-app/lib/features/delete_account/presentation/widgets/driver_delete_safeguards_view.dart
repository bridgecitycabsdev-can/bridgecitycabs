import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_delete_account_bloc.dart';
import '../../bloc/driver_delete_account_event.dart';
import '../../bloc/driver_delete_account_state.dart';
import '../../data/models/driver_delete_safeguard_block.dart';

class DriverDeleteSafeguardsView extends StatelessWidget {
  final DriverDeleteAccountState state;

  const DriverDeleteSafeguardsView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final block = state.activeSafeguardBlock;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildBlockTypeFilterChips(context),
          const SizedBox(height: 16),
          _buildActiveBlockCard(context, block),
          const SizedBox(height: 16),
          _buildBylawNotice(),
          const SizedBox(height: 14),
          _buildFleetProtocolCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PROTOCOL SAFEGUARDS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: const [
                Icon(Icons.circle, size: 7, color: Color(0xFF8B181B)),
                SizedBox(width: 4),
                Text(
                  '5 Live States',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B181B),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Review validation blocks that halt driver account termination in Lethbridge fleet service.',
          style: TextStyle(fontSize: 11, color: Color(0xFF757575), height: 1.3),
        ),
      ],
    );
  }

  Widget _buildBlockTypeFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DriverDeleteSafeguardBlockType.values.map((type) {
          final isSelected = state.selectedBlockType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(type.label),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF333333),
              ),
              selectedColor: const Color(0xFF8B181B),
              backgroundColor: const Color(0xFFF1EFEF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF8B181B) : const Color(0xFFDCD7D7),
                ),
              ),
              showCheckmark: false,
              onSelected: (_) {
                context.read<DriverDeleteAccountBloc>().add(
                      DriverDeleteSelectSafeguardBlock(type),
                    );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveBlockCard(
    BuildContext context,
    DriverDeleteSafeguardBlock block,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5C6C6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B181B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B181B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          block.tag,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        block.cabUnit,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    block.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF8B181B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            block.description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4A4A4A),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (block.type == DriverDeleteSafeguardBlockType.tripActive) ...[
            _buildActiveTripSubCard(block),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                if (block.type == DriverDeleteSafeguardBlockType.tripActive) {
                  context.read<DriverDeleteAccountBloc>().add(
                        const DriverDeleteGoToActiveTrip(),
                      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Action: ${block.actionButtonText}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B181B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.local_taxi, size: 18),
              label: Text(
                block.actionButtonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTripSubCard(DriverDeleteSafeguardBlock block) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECD6D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_pin_circle_outlined, size: 16, color: Color(0xFF8B181B)),
                  const SizedBox(width: 6),
                  Text(
                    'Passenger: ${block.passengerName ?? "Sarah K."}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'METER RUNNING',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.navigation, size: 14, color: Color(0xFF8B181B)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block.pickupLocation ?? 'Lethbridge Airport (YQL)',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '↓ ${block.dropoffLocation ?? "Downtown Scenic Drive"}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B6565)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'FARE ESTIMATE',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${block.fareEstimate?.toStringAsFixed(2) ?? "28.40"}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E)),
                    ),
                  ],
                ),
                Container(width: 1, height: 26, color: const Color(0xFFD6D1D1)),
                Column(
                  children: [
                    const Text(
                      'ETA DESTINATION',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      block.etaMinutes ?? '11 min',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBylawNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5DFDF)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 16, color: Color(0xFF555555)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vehicle GPS and fare meters remain locked during ride fulfillment per City of Lethbridge Taxi Bylaw 5834.',
              style: TextStyle(fontSize: 10, color: Color(0xFF555555), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetProtocolCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DFDF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF8B181B)),
              SizedBox(width: 6),
              Text(
                'LETHBRIDGE CITY FLEET PROTOCOL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B181B),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'All account deletion flows comply with Alberta Transportation Regulation Part 4 and Bridge City Cabs municipal charter.',
            style: TextStyle(fontSize: 10, color: Color(0xFF6B6565), height: 1.35),
          ),
        ],
      ),
    );
  }
}
