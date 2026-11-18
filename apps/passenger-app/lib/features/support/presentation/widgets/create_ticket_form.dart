import 'package:flutter/material.dart';
import '../../data/models/support_ticket_model.dart';

class CreateTicketForm extends StatefulWidget {
  final TicketCategory selectedCategory;
  final ValueChanged<TicketCategory> onCategoryChanged;
  final String? tripRoute;
  final String? tripId;
  final double? tripFareCad;
  final String? driverName;
  final String title;
  final ValueChanged<String> onTitleChanged;
  final String message;
  final ValueChanged<String> onMessageChanged;
  final bool isSubmitting;
  final bool isValid;
  final VoidCallback onSubmit;

  const CreateTicketForm({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.tripRoute,
    this.tripId,
    this.tripFareCad,
    this.driverName,
    required this.title,
    required this.onTitleChanged,
    required this.message,
    required this.onMessageChanged,
    required this.isSubmitting,
    required this.isValid,
    required this.onSubmit,
  });

  @override
  State<CreateTicketForm> createState() => _CreateTicketFormState();
}

class _CreateTicketFormState extends State<CreateTicketForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  bool _attachedPhoto = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _messageController = TextEditingController(text: widget.message);
  }

  @override
  void didUpdateWidget(covariant CreateTicketForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.title != _titleController.text) {
      _titleController.text = widget.title;
    }
    if (widget.message != _messageController.text) {
      _messageController.text = widget.message;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report an Issue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select a category and provide details so dispatch can resolve this quickly.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Category Chips
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TicketCategory.values.map((cat) {
              final isSelected = cat == widget.selectedCategory;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(cat.displayName),
                  ],
                ),
                selected: isSelected,
                selectedColor: const Color(0xFFFEF2F2),
                backgroundColor: const Color(0xFFF9FAFB),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFFB91C1C) : const Color(0xFF4B5563),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
                  ),
                ),
                onSelected: (_) => widget.onCategoryChanged(cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Associated Trip Strip
          if (widget.tripRoute != null) ...[
            const Text(
              'Associated Ride',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Color(0xFF4F46E5),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tripRoute!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Trip #${widget.tripId ?? 'BC-84920'} • \$${(widget.tripFareCad ?? 16.20).toStringAsFixed(2)} CAD • ${widget.driverName ?? 'Michael K.'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Title / Subject Input
          const Text(
            'Subject',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            onChanged: widget.onTitleChanged,
            decoration: InputDecoration(
              hintText: 'e.g., Left black backpack in Toyota Camry',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Message / Description Input
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            onChanged: widget.onMessageChanged,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Please describe what happened in detail so local dispatch can review logs or contact the driver...',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Attachment Mock Button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _attachedPhoto = !_attachedPhoto;
              });
            },
            icon: Icon(
              _attachedPhoto ? Icons.check_circle : Icons.attach_file,
              color: _attachedPhoto ? const Color(0xFF059669) : const Color(0xFF4B5563),
              size: 18,
            ),
            label: Text(
              _attachedPhoto ? 'photo_receipt_attached.jpg (Tap to remove)' : 'Attach Photo or Receipt',
              style: TextStyle(
                fontSize: 12,
                color: _attachedPhoto ? const Color(0xFF059669) : const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              side: BorderSide(
                color: _attachedPhoto ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.isValid && !widget.isSubmitting ? widget.onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: widget.isValid ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
