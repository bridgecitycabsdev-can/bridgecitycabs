import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_support_bloc.dart';
import '../../bloc/driver_support_event.dart';
import '../../bloc/driver_support_state.dart';
import '../../data/models/driver_support_form_state.dart';
import '../../data/models/driver_support_status.dart';
import '../../data/models/driver_support_ticket.dart';

class DriverSupportMyTicketsView extends StatelessWidget {
  final DriverSupportState state;

  const DriverSupportMyTicketsView({
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
          _buildResolutionDeskHeader(context),
          const SizedBox(height: 14),
          _buildFilterChipsRow(context),
          const SizedBox(height: 16),
          _buildTicketsList(context),
          const SizedBox(height: 20),
          _buildSimulatedDispatchStates(context),
          const SizedBox(height: 16),
          _buildPriorityCabGuaranteeCard(),
        ],
      ),
    );
  }

  Widget _buildResolutionDeskHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D5D5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFBECEC),
            child: const Icon(
              Icons.support_agent,
              size: 22,
              color: Color(0xFF8B181B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Driver Resolution Desk',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lethbridge Fleet Dispatch #402',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DriverSupportBloc>().add(
                    const DriverSupportSwitchView(DriverSupportViewStatus.newTicket),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B181B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.add, size: 14),
            label: const Text(
              'New ticket',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipsRow(BuildContext context) {
    final filters = [
      (DriverSupportTicketFilter.all, 'All tickets ${state.totalTicketsCount}'),
      (DriverSupportTicketFilter.open, 'Open ${state.openTicketsCount}'),
      (DriverSupportTicketFilter.inProgress, 'In progress ${state.inProgressTicketsCount}'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((item) {
          final filter = item.$1;
          final label = item.$2;
          final isSelected = state.selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(label),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF4A4A4A),
              ),
              selectedColor: const Color(0xFF8B181B),
              backgroundColor: const Color(0xFFF1EFEF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF8B181B) : const Color(0xFFE0DBDB),
                ),
              ),
              showCheckmark: false,
              onSelected: (_) {
                context.read<DriverSupportBloc>().add(DriverSupportSelectFilter(filter));
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTicketsList(BuildContext context) {
    if (state.dispatchState == DriverSupportDispatchState.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: Color(0xFF8B181B)),
        ),
      );
    }

    if (state.dispatchState == DriverSupportDispatchState.error) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4F4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF5C6C6)),
        ),
        child: const Center(
          child: Text(
            'Dispatch telemetry error: Could not fetch open tickets. Pull down to refresh.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8B181B), fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final tickets = state.filteredTickets;
    if (tickets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E3E3)),
        ),
        child: const Center(
          child: Text(
            'No tickets found in this category.',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575), fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Column(
      children: tickets.map((ticket) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTicketCard(context, ticket),
        );
      }).toList(),
    );
  }

  Widget _buildTicketCard(BuildContext context, DriverSupportTicket ticket) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E4E4)),
      ),
      child: InkWell(
        onTap: () {
          context.read<DriverSupportBloc>().add(DriverSupportSelectTicket(ticket.id));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${ticket.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (ticket.hasNewReply)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: Color(0xFF8B181B)),
                          SizedBox(width: 4),
                          Text(
                            'New reply',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B181B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  _buildStatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                ticket.subject,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildChipTag(ticket.topic.iconEmoji, ticket.topic.label),
                  if (ticket.linkedTripId != null)
                    _buildChipTag('🧾', 'Trip #${ticket.linkedTripId} (\$${ticket.linkedTripFare?.toStringAsFixed(2)})'),
                  if (ticket.vehicleUnit != null)
                    _buildChipTag('🚖', ticket.vehicleUnit!),
                  if (ticket.otaPatch != null)
                    _buildChipTag('📥', ticket.otaPatch!),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.lastUpdatedText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFFBDBDBD)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DriverSupportTicketStatus status) {
    switch (status) {
      case DriverSupportTicketStatus.open:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [
              Icon(Icons.circle, size: 6, color: Color(0xFF856404)),
              SizedBox(width: 4),
              Text(
                'Open',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF856404),
                ),
              ),
            ],
          ),
        );
      case DriverSupportTicketStatus.inProgress:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E2E),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [
              Icon(Icons.circle, size: 6, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'In progress',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case DriverSupportTicketStatus.resolved:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFD4EDDA),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [
              Icon(Icons.check, size: 12, color: Color(0xFF155724)),
              SizedBox(width: 3),
              Text(
                'Resolved',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF155724),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildChipTag(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFEF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$emoji $text',
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF4A4A4A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSimulatedDispatchStates(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8D5D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.remove_red_eye_outlined, size: 14, color: Color(0xFF8B181B)),
              SizedBox(width: 6),
              Text(
                'SIMULATED DISPATCH STATES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B181B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: DriverSupportDispatchState.values.map((s) {
              final isSelected = state.dispatchState == s;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () {
                      context.read<DriverSupportBloc>().add(
                            DriverSupportSetDispatchState(s),
                          );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF8B181B))
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? const Color(0xFF8B181B) : const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCabGuaranteeCard() {
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
            backgroundColor: const Color(0xFFE8D5D5),
            child: const Icon(
              Icons.verified_outlined,
              size: 16,
              color: Color(0xFF8B181B),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priority Cab Guarantee',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'All urgent safety tickets answered < 5m',
                  style: TextStyle(fontSize: 11, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 6, color: Color(0xFF2E7D32)),
                SizedBox(width: 4),
                Text(
                  'Online',
                  style: TextStyle(
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
    );
  }
}
