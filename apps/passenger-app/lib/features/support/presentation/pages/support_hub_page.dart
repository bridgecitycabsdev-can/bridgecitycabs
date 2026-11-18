import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/support_bloc.dart';
import '../bloc/support_event.dart';
import '../bloc/support_state.dart';
import '../../data/models/support_ticket_model.dart';
import '../../data/repositories/support_repository.dart';
import '../widgets/create_ticket_form.dart';
import '../widgets/support_app_bar.dart';
import '../widgets/support_empty_view.dart';
import '../widgets/support_guarantee_card.dart';
import '../widgets/support_quick_contact_card.dart';
import '../widgets/support_tab_bar.dart';
import '../widgets/support_ticket_card.dart';
import 'ticket_thread_page.dart';

class SupportHubPage extends StatelessWidget {
  final SupportRepository? repository;
  final List<SupportTicket>? initialTickets;
  final SupportHubTab initialTab;

  const SupportHubPage({
    super.key,
    this.repository,
    this.initialTickets,
    this.initialTab = SupportHubTab.myTickets,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = repository ??
            MockSupportRepository(initialTickets: initialTickets);
        final bloc = SupportBloc(repository: repo);
        bloc.add(const SupportLoadHubRequested());
        if (initialTab != SupportHubTab.myTickets) {
          bloc.add(SupportTabChanged(initialTab));
        }
        return bloc;
      },
      child: const _SupportHubView(),
    );
  }
}

class _SupportHubView extends StatelessWidget {
  const _SupportHubView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupportBloc, SupportState>(
      listener: (context, state) {
        if (state.status == SupportStatus.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Support ticket created. Lethbridge dispatch will assist you shortly.'),
              backgroundColor: Color(0xFF059669),
            ),
          );
        } else if (state.status == SupportStatus.failure ||
            state.status == SupportStatus.submitFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred with Support Hub.'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const SupportAppBar(),
          body: SafeArea(
            child: Column(
              children: [
                SupportTabBar(
                  selectedTab: state.selectedTab,
                  ticketCount: state.tickets.length,
                  onTabSelected: (tab) =>
                      context.read<SupportBloc>().add(SupportTabChanged(tab)),
                ),
                Expanded(
                  child: state.selectedTab == SupportHubTab.newReport
                      ? CreateTicketForm(
                          selectedCategory: state.createCategory,
                          onCategoryChanged: (cat) => context
                              .read<SupportBloc>()
                              .add(SupportCategoryChanged(cat)),
                          tripRoute: state.createTripRoute,
                          tripId: state.createTripId,
                          tripFareCad: state.createTripFareCad,
                          driverName: state.createDriverName,
                          title: state.createTitle,
                          onTitleChanged: (t) =>
                              context.read<SupportBloc>().add(SupportTitleChanged(t)),
                          message: state.createMessage,
                          onMessageChanged: (m) =>
                              context.read<SupportBloc>().add(SupportMessageChanged(m)),
                          isSubmitting: state.status == SupportStatus.submitting,
                          isValid: state.isFormValid,
                          onSubmit: () => context
                              .read<SupportBloc>()
                              .add(const SupportCreateTicketSubmitted()),
                        )
                      : _buildMyTicketsView(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyTicketsView(BuildContext context, SupportState state) {
    if (state.status == SupportStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB91C1C)),
        ),
      );
    }

    if (!state.hasTickets) {
      return SupportEmptyView(
        onCreateTicket: () => context
            .read<SupportBloc>()
            .add(const SupportTabChanged(SupportHubTab.newReport)),
      );
    }

    final filtered = state.filteredTickets;

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<SupportBloc>()
            .add(const SupportLoadHubRequested(forceRefresh: true));
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SupportQuickContactCard(),

          // Filter bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All (${state.tickets.length})',
                  isSelected: state.selectedFilter == null,
                  onTap: () => context
                      .read<SupportBloc>()
                      .add(const SupportFilterSelected(null)),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '🎒 Lost item',
                  isSelected: state.selectedFilter == TicketCategory.lostItem,
                  onTap: () => context
                      .read<SupportBloc>()
                      .add(const SupportFilterSelected(TicketCategory.lostItem)),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '💳 Payment',
                  isSelected: state.selectedFilter == TicketCategory.paymentIssue,
                  onTap: () => context
                      .read<SupportBloc>()
                      .add(const SupportFilterSelected(TicketCategory.paymentIssue)),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '🔀 Complaint',
                  isSelected: state.selectedFilter == TicketCategory.complaint,
                  onTap: () => context
                      .read<SupportBloc>()
                      .add(const SupportFilterSelected(TicketCategory.complaint)),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                const Text(
                  'Recent Inquiries',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${state.activeTicketCount} active',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No tickets match the selected filter.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            )
          else
            ...filtered.map(
              (ticket) => SupportTicketCard(
                ticket: ticket,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<SupportBloc>(),
                        child: TicketThreadPage(ticketId: ticket.id),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),
          const SupportGuaranteeCard(),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}
