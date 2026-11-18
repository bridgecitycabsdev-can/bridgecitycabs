import 'package:flutter/material.dart';
import '../../data/models/driver_rate_passenger_model.dart';

class DriverRatePassengerModal extends StatefulWidget {
  final DriverRatePassengerModel ratingModel;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<String> onTagToggled;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSubmitRatingPressed;
  final VoidCallback onSkipPressed;

  const DriverRatePassengerModal({
    super.key,
    required this.ratingModel,
    required this.onRatingChanged,
    required this.onTagToggled,
    required this.onNotesChanged,
    required this.onSubmitRatingPressed,
    required this.onSkipPressed,
  });

  @override
  State<DriverRatePassengerModal> createState() =>
      _DriverRatePassengerModalState();
}

class _DriverRatePassengerModalState extends State<DriverRatePassengerModal> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.ratingModel.dispatcherFeedbackNotes,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate passenger',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Trip #${widget.ratingModel.tripId} • ${widget.ratingModel.routeSummary}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onSkipPressed,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Passenger info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE5E7EB),
                  child: const Text(
                    'AM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.ratingModel.passengerName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle,
                            size: 13,
                            color: Color(0xFF10B981),
                          ),
                        ],
                      ),
                      Text(
                        widget.ratingModel.ridesCompletedSummary,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.ratingModel.tripFareTypeSummary,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFBA0C2F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tap to rate experience label & Stars
          const Center(
            child: Text(
              'TAP TO RATE EXPERIENCE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // 5 gold stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isFilled = widget.ratingModel.rating >= starIndex;
              final isHalf = !isFilled &&
                  widget.ratingModel.rating >= starIndex - 0.5;

              return IconButton(
                onPressed: () => widget.onRatingChanged(starIndex.toDouble()),
                icon: Icon(
                  isFilled
                      ? Icons.star_rounded
                      : isHalf
                          ? Icons.star_half_rounded
                          : Icons.star_outline_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 32,
                ),
              );
            }),
          ),
          Center(
            child: Text(
              widget.ratingModel.ratingLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Driver Quick Tags
          const Text(
            'DRIVER QUICK TAGS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DriverRatePassengerModel.availableTags.map((tag) {
              final isSelected = widget.ratingModel.selectedTags.contains(tag);
              return InkWell(
                onTap: () => widget.onTagToggled(tag),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFBA0C2F)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tag == 'Polite'
                            ? Icons.thumb_up_alt_outlined
                            : tag == 'On time'
                                ? Icons.access_time
                                : tag == 'Clean'
                                    ? Icons.auto_awesome
                                    : Icons.verified_user_outlined,
                        size: 13,
                        color:
                            isSelected ? Colors.white : const Color(0xFF4B5563),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Dispatcher Notes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'DISPATCHER NOTES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Sent to fleet log',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          TextField(
            controller: _notesController,
            onChanged: widget.onNotesChanged,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add feedback for Lethbridge dispatch (optional)...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBA0C2F)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit rating button
          ElevatedButton(
            onPressed: widget.onSubmitRatingPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA0C2F),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1_outlined, size: 18),
                SizedBox(width: 8),
                Text(
                  'Submit rating',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Skip button
          Center(
            child: TextButton(
              onPressed: widget.onSkipPressed,
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
