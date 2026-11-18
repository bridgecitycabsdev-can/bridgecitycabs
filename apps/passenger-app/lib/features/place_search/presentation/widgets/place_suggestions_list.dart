import 'package:flutter/material.dart';
import '../../data/models/lethbridge_place.dart';

class PlaceSuggestionsList extends StatelessWidget {
  final List<LethbridgePlace> places;
  final ValueChanged<LethbridgePlace> onPlaceTap;

  const PlaceSuggestionsList({
    super.key,
    required this.places,
    required this.onPlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header: SUGGESTIONS + 4 places
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SUGGESTIONS',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                '${places.length} places',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // List of places
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: places.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 64,
              color: Color(0xFFF3F4F6),
            ),
            itemBuilder: (context, index) {
              final place = places[index];
              return InkWell(
                onTap: () => onPlaceTap(place),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Leading category icon circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          place.iconData,
                          color: index == 0
                              ? const Color(0xFFB71C1C)
                              : const Color(0xFF6B7280),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHighlightedTitle(place),
                            const SizedBox(height: 2),
                            Text(
                              place.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Distance & ETA
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            place.distanceText,
                            style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            place.etaText,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedTitle(LethbridgePlace place) {
    if (place.matchedPrefix == null || place.matchedPrefix!.isEmpty) {
      return Text(
        place.title,
        style: const TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final prefix = place.matchedPrefix!;
    final fullTitle = place.title;

    if (fullTitle.startsWith(prefix)) {
      final remainder = fullTitle.substring(prefix.length);
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: prefix,
              style: const TextStyle(
                color: Color(0xFF880E14),
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: remainder,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      place.title,
      style: const TextStyle(
        color: Color(0xFF1E1E1E),
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
