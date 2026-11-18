import 'package:flutter/material.dart';

class DriverReviewsEdgeCards extends StatelessWidget {
  final int activeInspectorIndex;
  final ValueChanged<int> onInspectorTabChanged;
  final VoidCallback onResetFilter;
  final VoidCallback onGoOnline;
  final VoidCallback onRetry;

  const DriverReviewsEdgeCards({
    super.key,
    required this.activeInspectorIndex,
    required this.onInspectorTabChanged,
    required this.onResetFilter,
    required this.onGoOnline,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // UI State Inspector Segmented Header
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UI STATE INSPECTOR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF616161),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Interactive Preview',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC62828),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Inspector Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildInspectorChip(0, 'Showcase All'),
              _buildInspectorChip(1, 'Filtered Empty (1 ★)'),
              _buildInspectorChip(2, 'New Driver'),
              _buildInspectorChip(3, 'Service Failure'),
              _buildInspectorChip(4, 'Feed Loading'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Edge State 1: No Matching Filter Results
        if (activeInspectorIndex == 0 || activeInspectorIndex == 1) ...[
          _buildSectionHeader('State: No Matching Filter Results', '1 ★ active', const Color(0xFFEEEEEE), const Color(0xFF424242)),
          const SizedBox(height: 8),
          _buildNoMatchingFilterCard(),
          const SizedBox(height: 20),
        ],

        // Edge State 2: First-Time Onboarding Driver
        if (activeInspectorIndex == 0 || activeInspectorIndex == 2) ...[
          _buildSectionHeader('State: First-Time Onboarding Driver', 'New Account', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
          const SizedBox(height: 8),
          _buildNewDriverEmptyCard(),
          const SizedBox(height: 20),
        ],

        // Edge State 3: Service Failure / Sync Timeout
        if (activeInspectorIndex == 0 || activeInspectorIndex == 3) ...[
          _buildSectionHeader('State: Service Failure / Sync Timeout', '504 Gateway', const Color(0xFFFFEBEE), const Color(0xFFC62828)),
          const SizedBox(height: 8),
          _buildServiceFailureCard(),
          const SizedBox(height: 20),
        ],

        // Edge State 4: Feed & Infinite Scroll Loading
        if (activeInspectorIndex == 0 || activeInspectorIndex == 4) ...[
          _buildSectionHeader('State: Feed & Infinite Scroll Loading', 'Page 1 of 4', const Color(0xFFF5F5F5), const Color(0xFF616161)),
          const SizedBox(height: 8),
          _buildFeedLoadingSection(),
          const SizedBox(height: 20),
          _buildSectionHeader('Skeleton Cache Sync State', '', Colors.transparent, Colors.transparent),
          const SizedBox(height: 8),
          _buildSkeletonLoaderCard(),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildInspectorChip(int index, String label) {
    final isSelected = activeInspectorIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF424242),
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF8B0000),
        backgroundColor: const Color(0xFFEEEEEE),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onSelected: (_) => onInspectorTabChanged(index),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badge, Color badgeBg, Color badgeTextColor) {
    return Row(
      children: [
        const Icon(Icons.bookmark_outline_rounded, size: 14, color: Color(0xFFC62828)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
          ),
        ),
        if (badge.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
            child: Text(
              badge,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeTextColor),
            ),
          ),
      ],
    );
  }

  Widget _buildNoMatchingFilterCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
            child: const Icon(Icons.star_border_purple500_rounded, color: Color(0xFF757575), size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            'No reviews with this rating',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
          ),
          const SizedBox(height: 4),
          const Text(
            'There are currently no reviews matching the selected 1 ★ filter.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onResetFilter,
            icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF424242)),
            label: const Text('Reset filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewDriverEmptyCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: Color(0xFFFFF9C4), shape: BoxShape.circle),
            child: const Icon(Icons.star_rounded, color: Color(0xFFFBC02D), size: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            'No reviews yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete rides across Lethbridge to get your first passenger review and rating score.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFC62828)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'High Demand: Downtown & West Lethbridge. Est. wait under 4 mins for pickups',
                    style: TextStyle(fontSize: 11, color: Color(0xFF424242), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onGoOnline,
              icon: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF69F0AE), shape: BoxShape.circle),
              ),
              label: const Text('Go online to get rides', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFailureCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded, color: Color(0xFFC62828), size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            "Couldn't load reviews",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Connection timed out while fetching passenger feedback records.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFC62828)),
            label: const Text('Try again', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFC62828)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedLoadingSection() {
    return Column(
      children: [
        _buildFeedCard(
          name: 'Sarah M.',
          subtitle: 'Yesterday • University Dr West',
          ratingText: '5.0',
          comment: '“Super smooth drive across Whoop-Up Drive during rush hour. Car was impeccably clean and warm on a freezing evening!”',
          tags: ['Smooth Driving', 'Punctual Pickup', '+\$4.00 Tip'],
        ),
        const SizedBox(height: 10),
        _buildFeedCard(
          name: 'Liam K.',
          subtitle: '3 days ago • Park Place Mall',
          ratingText: '5.0',
          comment: '“Helped with my heavy grocery bags and took the quickest route avoiding the train crossing. Bridge City drivers are the best.”',
          tags: ['Great Route', 'Luggage Help'],
        ),
        const SizedBox(height: 14),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC62828)),
            ),
            SizedBox(width: 8),
            Text('Loading more reviews...', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
          ],
        ),
      ],
    );
  }

  Widget _buildFeedCard({
    required String name,
    required String subtitle,
    required String ratingText,
    required String comment,
    required List<String> tags,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Color(0xFFC62828), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                    const SizedBox(height: 1),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFA000)),
                    const SizedBox(width: 2),
                    Text(ratingText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(comment, style: const TextStyle(fontSize: 12, color: Color(0xFF333333), height: 1.35)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: tags.map((t) {
              final isTip = t.contains('Tip');
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isTip ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  t,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isTip ? const Color(0xFF2E7D32) : const Color(0xFF616161)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoaderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, height: 12, decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 4),
                  Container(width: 60, height: 10, decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(5))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(width: double.infinity, height: 10, decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(5))),
          const SizedBox(height: 6),
          Container(width: 200, height: 10, decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(5))),
        ],
      ),
    );
  }
}
