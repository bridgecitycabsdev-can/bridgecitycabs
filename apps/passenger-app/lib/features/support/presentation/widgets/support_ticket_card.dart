import 'package:flutter/material.dart';
import '../../data/models/support_ticket_model.dart';

class SupportTicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const SupportTicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  Color _getStatusBgColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFFECFDF5);
      case TicketStatus.inProgress:
        return const Color(0xFFFFFBEB);
      case TicketStatus.resolved:
      case TicketStatus.closed:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusTextColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFF047857);
      case TicketStatus.inProgress:
        return const Color(0xFFB45309);
      case TicketStatus.resolved:
      case TicketStatus.closed:
        return const Color(0xFF4B5563);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ticket.hasUnread ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB),
            width: ticket.hasUnread ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(ticket.category.emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        ticket.category.displayName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBgColor(ticket.status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.status.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _getStatusTextColor(ticket.status),
                    ),
                  ),
                ),
                const Spacer(),
                if (ticket.hasUnread) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  ticket.createdAt,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            if (ticket.tripRoute != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.route_outlined, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket.tripRoute!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (ticket.tripId != null) ...[
                  Text(
                    'Trip #${ticket.tripId}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (ticket.formattedFare.isNotEmpty) ...[
                    const Text(' • ', style: TextStyle(color: Color(0xFF9CA3AF))),
                    Text(
                      ticket.formattedFare,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ] else if (ticket.metaNote != null) ...[
                  Text(
                    ticket.metaNote!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
