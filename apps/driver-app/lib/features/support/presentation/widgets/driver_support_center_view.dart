import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_support_bloc.dart';
import '../../bloc/driver_support_event.dart';
import '../../bloc/driver_support_state.dart';
import '../../data/models/driver_support_status.dart';

class DriverSupportCenterView extends StatelessWidget {
  final DriverSupportState state;

  const DriverSupportCenterView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFleetSubheader(),
          const SizedBox(height: 14),
          _buildTopToggleButtons(context),
          const SizedBox(height: 16),
          _buildContactChannelsRow(context),
          const SizedBox(height: 12),
          _buildSupportAvailabilityNote(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildShiftDispatchHubCard(context),
          const SizedBox(height: 20),
          _buildPopularHelpTopicsSection(context),
          const SizedBox(height: 16),
          _buildWinterRoadAdvisoryCard(),
          const SizedBox(height: 24),
          _buildNewTicketButton(context),
        ],
      ),
    );
  }

  Widget _buildFleetSubheader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
            Text(
              state.fleetSupportLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A4A4A),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            state.cabUnit,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopToggleButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<DriverSupportBloc>().add(
                      const DriverSupportSwitchView(DriverSupportViewStatus.newTicket),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B181B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text(
                'New report',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                context.read<DriverSupportBloc>().add(
                      const DriverSupportSwitchView(DriverSupportViewStatus.myTickets),
                    );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2B2B2B),
                side: const BorderSide(color: Color(0xFFD6D1D1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'My tickets',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B181B),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${state.openTicketsCount}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactChannelsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE7E3E3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFFBECEC),
                        child: const Icon(
                          Icons.mail_outline,
                          size: 16,
                          color: Color(0xFF8B181B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '<2h reply',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Email us',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.supportEmail,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE7E3E3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFFBECEC),
                        child: const Icon(
                          Icons.headset_mic_outlined,
                          size: 16,
                          color: Color(0xFF8B181B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '24/7 Live',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Call support',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.supportPhone,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportAvailabilityNote() {
    return const Row(
      children: [
        Icon(Icons.info_outline, size: 14, color: Color(0xFF757575)),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'Support is available 24/7 for all Lethbridge fleet drivers.',
            style: TextStyle(fontSize: 11, color: Color(0xFF757575)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4DFDF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: const Row(
        children: [
          Icon(Icons.search, size: 20, color: Color(0xFF9E9E9E)),
          SizedBox(width: 10),
          Text(
            'Search help topics',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftDispatchHubCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
                gradient: LinearGradient(
                  colors: [Color(0xFF5A7264), Color(0xFF86A088)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.terrain,
                      size: 48,
                      color: Colors.white70,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Lethbridge High Level Viaduct Area',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'SHIFT DISPATCH HUB',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8B181B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Bridge City Dispatch Desk • 4th Ave S • Downtown',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2A2A2A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFFF1EFEF),
                    child: const Icon(
                      Icons.near_me_outlined,
                      size: 16,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularHelpTopicsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Popular help topics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
            Text(
              'Fast resolution',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEAE5E5)),
          ),
          child: Column(
            children: state.faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              final isLast = index == state.faqs.length - 1;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: faq.isDestructive
                          ? const Color(0xFFFBECEC)
                          : const Color(0xFFF4F4F4),
                      child: Icon(
                        _getFaqIcon(faq.iconType),
                        size: 18,
                        color: faq.isDestructive
                            ? const Color(0xFF8B181B)
                            : const Color(0xFF333333),
                      ),
                    ),
                    title: Text(
                      faq.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: faq.isDestructive
                            ? const Color(0xFF8B181B)
                            : const Color(0xFF1E1E1E),
                      ),
                    ),
                    subtitle: Text(
                      faq.subtitle,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFBDBDBD)),
                    onTap: () {
                      if (faq.isDestructive) {
                        context.read<DriverSupportBloc>().add(
                              const DriverSupportSwitchView(DriverSupportViewStatus.emergencySos),
                            );
                      } else {
                        context.read<DriverSupportBloc>().add(
                              const DriverSupportSwitchView(DriverSupportViewStatus.newTicket),
                            );
                      }
                    },
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 56, endIndent: 14, color: Color(0xFFF0EBEB)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getFaqIcon(String type) {
    switch (type) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'shield':
        return Icons.verified_user_outlined;
      case 'passenger_no_show':
        return Icons.person_off_outlined;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildWinterRoadAdvisoryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4DFDF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFEDE8E8),
            child: const Icon(
              Icons.ac_unit,
              size: 16,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Whoop-Up Drive Winter Road Advisory',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Coulee road grades may experience ice. Keep extra following distance.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B6565),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewTicketButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<DriverSupportBloc>().add(
                const DriverSupportSwitchView(DriverSupportViewStatus.newTicket),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B181B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 1,
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'New ticket',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
