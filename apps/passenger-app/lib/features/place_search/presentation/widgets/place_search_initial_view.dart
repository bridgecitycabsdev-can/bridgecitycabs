import 'package:flutter/material.dart';
import '../../data/models/place_search_config.dart';

class PlaceSearchInitialView extends StatelessWidget {
  final ValueChanged<String> onLandmarkSelected;

  const PlaceSearchInitialView({
    super.key,
    required this.onLandmarkSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Concentric radar beacon with navigation pointer
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2).withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB71C1C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Headline
          const Text(
            PlaceSearchConfig.promptHeadline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            PlaceSearchConfig.promptDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Landmark suggestion chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: PlaceSearchConfig.popularLandmarks.map((landmark) {
              return ActionChip(
                label: Text(landmark),
                labelStyle: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: const Color(0xFFF3F4F6),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () => onLandmarkSelected(landmark),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
