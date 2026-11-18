import 'package:flutter/material.dart';
import '../../data/models/choose_ride_config.dart';
import '../../data/models/promo_code.dart';

class PromoCodeSection extends StatefulWidget {
  final PromoCode? appliedPromo;
  final String? errorMessage;
  final ValueChanged<String> onApplyPromo;
  final VoidCallback onRemovePromo;

  const PromoCodeSection({
    super.key,
    this.appliedPromo,
    this.errorMessage,
    required this.onApplyPromo,
    required this.onRemovePromo,
  });

  @override
  State<PromoCodeSection> createState() => _PromoCodeSectionState();
}

class _PromoCodeSectionState extends State<PromoCodeSection> {
  bool _isInputOpen = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Promo successfully applied state (Image 3)
    if (widget.appliedPromo != null && widget.appliedPromo!.isValid) {
      final promo = widget.appliedPromo!;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${ChooseRideConfig.promoAppliedPrefix} ${promo.code}',
                        style: const TextStyle(
                          color: Color(0xFF065F46),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    promo.description,
                    style: const TextStyle(
                      color: Color(0xFF047857),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '-\$${promo.discountAmountCad.toStringAsFixed(2)} CAD',
                style: const TextStyle(
                  color: Color(0xFF065F46),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: widget.onRemovePromo,
              child: const Text(
                ChooseRideConfig.removePromo,
                style: TextStyle(
                  color: Color(0xFF047857),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. Input open or Error state (Image 4)
    if (_isInputOpen || widget.errorMessage != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.errorMessage != null ? const Color(0xFFB71C1C) : const Color(0xFFFFCDD2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Enter promo code',
                      prefixIcon: const Icon(Icons.local_offer_outlined, color: Color(0xFFB71C1C), size: 18),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              onPressed: () => _controller.clear(),
                            )
                          : null,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      widget.onApplyPromo(_controller.text.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(ChooseRideConfig.applyPromo),
                ),
              ],
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFB71C1C)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFB71C1C),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }

    // 3. Collapsed "Have a promo code? Add" state (Image 2)
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.confirmation_number_outlined, size: 18, color: Color(0xFF4B5563)),
              SizedBox(width: 10),
              Text(
                ChooseRideConfig.havePromoCode,
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => setState(() => _isInputOpen = true),
            child: const Text(
              ChooseRideConfig.addPromo,
              style: TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
