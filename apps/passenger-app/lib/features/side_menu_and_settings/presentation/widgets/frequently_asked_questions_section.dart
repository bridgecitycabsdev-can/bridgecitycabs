import 'package:flutter/material.dart';
import '../../data/models/faq_item_model.dart';

class FrequentlyAskedQuestionsSection extends StatelessWidget {
  final String searchQuery;
  final FaqCategory selectedCategory;
  final List<FaqItem> faqs;
  final Set<String> expandedFaqIds;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<FaqCategory> onCategorySelected;
  final ValueChanged<String> onFaqToggled;

  const FrequentlyAskedQuestionsSection({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.faqs,
    required this.expandedFaqIds,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onFaqToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'FREQUENTLY ASKED QUESTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.8,
            ),
          ),
        ),
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              icon: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
              hintText: 'Search help & FAQs...',
              hintStyle: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: FaqCategory.values.map((cat) {
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat.displayName),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFEE2E2),
                  backgroundColor: Colors.white,
                  checkmarkColor: const Color(0xFFDC2626),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFE5E7EB),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFDC2626) : const Color(0xFF374151),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (_) => onCategorySelected(cat),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // FAQ items list
        if (faqs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const Text(
              'No questions found matching your search.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          )
        else
          ...faqs.map((faq) => _buildFaqTile(faq)),
      ],
    );
  }

  Widget _buildFaqTile(FaqItem faq) {
    final isExpanded = expandedFaqIds.contains(faq.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? const Color(0xFFFCA5A5) : const Color(0xFFF3F4F6),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => onFaqToggled(faq.id),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isExpanded ? const Color(0xFF991B1B) : const Color(0xFF1F2937),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: isExpanded ? const Color(0xFFDC2626) : const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faq.answer,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  if (faq.meteredFareBox != null) ...[
                    const SizedBox(height: 12),
                    _buildMeteredRateBox(faq.meteredFareBox!),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeteredRateBox(MeteredFareBoxData box) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_taxi_outlined,
                color: Color(0xFFDC2626),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                box.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRateRow('Base Metered Drop', box.baseDrop),
          const SizedBox(height: 4),
          _buildRateRow('Distance Rate', box.distanceRate),
          const SizedBox(height: 4),
          _buildRateRow('Waiting / Delay', box.waitingRate),
          const Divider(height: 14, color: Color(0xFFFCA5A5)),
          Text(
            box.taxNote,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
