import 'package:flutter/material.dart';
import '../../data/models/place_search_config.dart';

class PlaceSearchHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onProfileTap;

  const PlaceSearchHeader({
    super.key,
    required this.onBack,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E1E), size: 24),
            onPressed: onBack,
          ),
          const Text(
            PlaceSearchConfig.screenTitle,
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF880E14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
