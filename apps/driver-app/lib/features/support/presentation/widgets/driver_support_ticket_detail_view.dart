import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_support_bloc.dart';
import '../../bloc/driver_support_event.dart';
import '../../bloc/driver_support_state.dart';
import '../../data/models/driver_support_message.dart';
import '../../data/models/driver_support_ticket.dart';

class DriverSupportTicketDetailView extends StatefulWidget {
  final DriverSupportState state;

  const DriverSupportTicketDetailView({
    super.key,
    required this.state,
  });

  @override
  State<DriverSupportTicketDetailView> createState() =>
      _DriverSupportTicketDetailViewState();
}

class _DriverSupportTicketDetailViewState
    extends State<DriverSupportTicketDetailView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.state.selectedTicket ??
        (widget.state.tickets.isNotEmpty ? widget.state.tickets.first : null);

    if (ticket == null) {
      return const Center(child: Text('No ticket selected'));
    }

    return Column(
      children: [
        _buildTicketSubheader(ticket),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ticket.linkedTripId != null) _buildLinkedTripCard(ticket),
                const SizedBox(height: 12),
                _buildMapThumbnail(ticket),
                const SizedBox(height: 16),
                _buildDateSeparator('Today, 18 Jul 2026'),
                const SizedBox(height: 12),
                ...ticket.messages.map((m) => _buildMessageBubble(context, m)),
                const SizedBox(height: 10),
                _buildTypingIndicator(),
                const SizedBox(height: 14),
                _buildReopenNoticeBanner(),
                const SizedBox(height: 12),
                _buildQuickActionChips(context),
              ],
            ),
          ),
        ),
        _buildMessageComposer(context, ticket),
      ],
    );
  }

  Widget _buildTicketSubheader(DriverSupportTicket ticket) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, size: 16, color: Color(0xFF8B181B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ticket.subject,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2A2A2A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFBECEC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Color(0xFF8B181B)),
                const SizedBox(width: 4),
                Text(
                  'OPEN #${ticket.id}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B181B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedTripCard(DriverSupportTicket ticket) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5DFDF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFFBECEC),
                child: const Icon(
                  Icons.local_taxi,
                  size: 17,
                  color: Color(0xFF8B181B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LINKED TRIP #${ticket.linkedTripId}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF424242),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ticket.linkedTripRoute ?? 'University Dr to Downtown Lethbridge',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B6565)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${ticket.linkedTripFare?.toStringAsFixed(2) ?? '22.10'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF8B181B),
                    ),
                  ),
                  const Text(
                    'CAD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B181B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1EFEF)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ticket.linkedTripDate ?? '18 Jul 2026'} • Cash Trip',
                style: const TextStyle(fontSize: 10, color: Color(0xFF8C8282)),
              ),
              const Row(
                children: [
                  Text(
                    'View receipt',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B181B),
                    ),
                  ),
                  Icon(Icons.arrow_forward, size: 12, color: Color(0xFF8B181B)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapThumbnail(DriverSupportTicket ticket) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 85,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFE2EBE5),
          gradient: LinearGradient(
            colors: [Color(0xFFD6E3DB), Color(0xFFCADBD1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.map_outlined,
                size: 44,
                color: Colors.black.withOpacity(0.12),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alt_route, size: 12, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      ticket.tariffCorridor,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(String label) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF555555),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, DriverSupportMessage message) {
    final isDriver = message.sender.isDriver;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Align(
        alignment: isDriver ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isDriver ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isDriver) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: const Color(0xFFFBECEC),
                    child: const Icon(
                      Icons.support_agent,
                      size: 12,
                      color: Color(0xFF8B181B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    message.authorName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B181B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _getBubbleColor(message),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: isDriver ? const Radius.circular(14) : Radius.zero,
                  bottomRight: isDriver ? Radius.zero : const Radius.circular(14),
                ),
                border: message.deliveryStatus.isFailed
                    ? Border.all(color: const Color(0xFFF5C6C6))
                    : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: isDriver && !message.deliveryStatus.isFailed
                      ? (message.deliveryStatus.isSending
                          ? const Color(0xFF8B181B)
                          : Colors.white)
                      : const Color(0xFF1E1E1E),
                ),
              ),
            ),
            const SizedBox(height: 3),
            _buildStatusFooter(context, message),
          ],
        ),
      ),
    );
  }

  Color _getBubbleColor(DriverSupportMessage message) {
    if (message.sender.isAgent) {
      return const Color(0xFFF1EFEF);
    }
    if (message.deliveryStatus.isFailed) {
      return const Color(0xFFFFF0F0);
    }
    if (message.deliveryStatus.isSending) {
      return const Color(0xFFFBECEC);
    }
    return const Color(0xFFC62828);
  }

  Widget _buildStatusFooter(BuildContext context, DriverSupportMessage message) {
    if (message.sender.isAgent) {
      return Text(
        message.timestamp,
        style: const TextStyle(fontSize: 10, color: Color(0xFF8C8282)),
      );
    }

    if (message.deliveryStatus.isFailed) {
      return InkWell(
        onTap: () {
          context.read<DriverSupportBloc>().add(
                DriverSupportRetryChatMessage(message.id),
              );
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 12, color: Color(0xFFC62828)),
            SizedBox(width: 4),
            Text(
              'Failed to send. Tap to retry.',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFC62828),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (message.deliveryStatus.isSending) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 10, color: Color(0xFF757575)),
          SizedBox(width: 4),
          Text(
            'Sending...',
            style: TextStyle(fontSize: 10, color: Color(0xFF757575)),
          ),
        ],
      );
    }

    return Text(
      '${message.timestamp} • Delivered ✓',
      style: const TextStyle(fontSize: 10, color: Color(0xFF8C8282)),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: const [
        Text(
          '••• ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B181B),
          ),
        ),
        Text(
          'Agent Sarah is typing dispatch notes...',
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildReopenNoticeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: Color(0xFF757575)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This ticket is resolved. Replying will reopen...',
              style: TextStyle(fontSize: 11, color: Color(0xFF555555)),
            ),
          ),
          Icon(Icons.close, size: 14, color: Color(0xFF757575)),
        ],
      ),
    );
  }

  Widget _buildQuickActionChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionPill(context, '🧾 Add receipt photo'),
          const SizedBox(width: 8),
          _buildActionPill(context, '✓ Confirm cash total'),
        ],
      ),
    );
  }

  Widget _buildActionPill(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        context.read<DriverSupportBloc>().add(
              DriverSupportQuickActionTriggered(text),
            );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD6D1D1)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer(BuildContext context, DriverSupportTicket ticket) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file, color: Color(0xFF757575)),
                onPressed: () {
                  context.read<DriverSupportBloc>().add(
                        const DriverSupportQuickActionTriggered('Attach document'),
                      );
                },
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EFEF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type your reply...',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    context.read<DriverSupportBloc>().add(
                          DriverSupportSendChatMessage(text),
                        );
                    _textController.clear();
                  }
                },
                child: CircleAvatar(
                  radius: 19,
                  backgroundColor: const Color(0xFF8B181B),
                  child: const Icon(
                    Icons.send,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Messages in support tickets cannot be edited or deleted.',
            style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}
