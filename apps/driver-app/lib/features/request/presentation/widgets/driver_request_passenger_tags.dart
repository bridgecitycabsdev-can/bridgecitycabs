import 'package:flutter/material.dart';

class DriverRequestPassengerTags extends StatelessWidget {
  final String passengerName;
  final double passengerRating;
  final List<String> tags;
  final bool isScheduled;

  const DriverRequestPassengerTags({
    super.key,
    required this.passengerName,
    required this.passengerRating,
    required this.tags,
    this.isScheduled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Passenger initial & rating pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundColor: const Color(0xFFC62828),
                  child: Text(
                    passengerName.isNotEmpty ? passengerName[0] : 'P',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  passengerName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text(
                  passengerRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Additional tags
          ...tags.map((tag) {
            final isRedTag = tag.contains('Scheduled') || tag.contains('Urgent');
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isRedTag
                      ? const Color(0xFFB71C1C)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tag.contains('Airport')) ...[
                      const Icon(Icons.flight, size: 12, color: Colors.black54),
                      const SizedBox(width: 4),
                    ] else if (tag.contains('Quick') || tag.contains('Immed')) ...[
                      const Icon(Icons.bolt, size: 12, color: Colors.deepOrange),
                      const SizedBox(width: 4),
                    ] else if (tag.contains('Bag')) ...[
                      const Icon(Icons.luggage, size: 12, color: Colors.black54),
                      const SizedBox(width: 4),
                    ] else if (tag.contains('Ride') || tag.contains('Van')) ...[
                      const Icon(Icons.person, size: 12, color: Colors.black54),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isRedTag ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
