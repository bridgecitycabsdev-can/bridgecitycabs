import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/support_bloc.dart';
import '../bloc/support_event.dart';
import '../bloc/support_state.dart';
import '../../data/models/support_ticket_model.dart';
import '../../data/repositories/support_repository.dart';
import '../widgets/ticket_chat_bubble.dart';
import '../widgets/ticket_composer.dart';
import '../widgets/ticket_trip_context_strip.dart';

class TicketThreadPage extends StatelessWidget {
  final String ticketId;
  final SupportRepository? repository;
  final SupportTicket? initialTicket;

  const TicketThreadPage({
    super.key,
    required this.ticketId,
    this.repository,
    this.initialTicket,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<SupportBloc>();
      return _TicketThreadView(ticketId: ticketId);
    } catch (_) {
      return BlocProvider(
        create: (context) {
          final repo = repository ??
              MockSupportRepository(
                initialTickets: initialTicket != null ? [initialTicket!] : null,
              );
          return SupportBloc(repository: repo)
            ..add(SupportOpenTicketThread(ticketId));
        },
        child: _TicketThreadView(ticketId: ticketId),
      );
    }
  }
}

class _TicketThreadView extends StatefulWidget {
  final String ticketId;

  const _TicketThreadView({
    required this.ticketId,
  });

  @override
  State<_TicketThreadView> createState() => _TicketThreadViewState();
}

class _TicketThreadViewState extends State<_TicketThreadView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SupportBloc>().add(SupportOpenTicketThread(widget.ticketId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupportBloc, SupportState>(
      listener: (context, state) {
        if (state.activeTicket != null) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        final ticket = state.activeTicket;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
              onPressed: () {
                context.read<SupportBloc>().add(const SupportCloseTicketThread());
                Navigator.of(context).maybePop();
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket != null ? 'Ticket #${ticket.id}' : 'Support Ticket',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Bridge City Dispatch • Lethbridge, AB',
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.phone, color: Color(0xFFB91C1C), size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Calling Lethbridge Dispatch: 403-328-8888'),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ticket == null
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB91C1C)),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      TicketTripContextStrip(ticket: ticket),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: ticket.messages.length,
                          itemBuilder: (context, index) {
                            return TicketChatBubble(message: ticket.messages[index]);
                          },
                        ),
                      ),
                      TicketComposer(
                        text: state.threadInputMessage,
                        onChanged: (text) => context
                            .read<SupportBloc>()
                            .add(SupportThreadMessageChanged(text)),
                        onSend: () => context
                            .read<SupportBloc>()
                            .add(SupportSendThreadMessage(ticket.id)),
                        isSending: state.isSendingThreadMessage,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
