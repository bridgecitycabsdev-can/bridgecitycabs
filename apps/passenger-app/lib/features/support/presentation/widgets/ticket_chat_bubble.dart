import 'package:flutter/material.dart';
import '../../data/models/support_ticket_model.dart';

class TicketChatBubble extends StatelessWidget {
  final TicketMessage message;

  const TicketChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSupport = message.isSupport;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment:
            isSupport ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (isSupport) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB91C1C),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'S',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Dispatch',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB91C1C),
                    ),
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
              color: isSupport ? const Color(0xFFF3F4F6) : const Color(0xFFB91C1C),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isSupport ? 2 : 14),
                bottomRight: Radius.circular(isSupport ? 14 : 2),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: isSupport ? const Color(0xFF1F2937) : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.timestamp,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              if (!isSupport) ...[
                const SizedBox(width: 4),
                Icon(
                  message.status == MessageDeliveryStatus.read
                      ? Icons.done_all
                      : Icons.done,
                  size: 13,
                  color: message.status == MessageDeliveryStatus.read
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF9CA3AF),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
