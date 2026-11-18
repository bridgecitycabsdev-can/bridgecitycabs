import 'package:flutter/material.dart';

class DriverRatingSheet extends StatefulWidget {
  final String driverName;
  final ValueChanged<double> onRatingSubmitted;

  const DriverRatingSheet({
    super.key,
    required this.driverName,
    required this.onRatingSubmitted,
  });

  @override
  State<DriverRatingSheet> createState() => _DriverRatingSheetState();
}

class _DriverRatingSheetState extends State<DriverRatingSheet> {
  double _selectedRating = 5.0;
  final TextEditingController _feedbackController = TextEditingController();

  final List<String> _compliments = [
    'Clean vehicle',
    'Safe driver',
    'Great conversation',
    'Smooth ride',
    'Fast route',
  ];
  final Set<String> _selectedCompliments = {};

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Rate your trip with ${widget.driverName}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your feedback helps keep Bridge City Cabs safe and reliable.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),

              // Star picker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    iconSize: 36,
                    icon: Icon(
                      starIndex <= _selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: const Color(0xFFF59E0B),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRating = starIndex.toDouble();
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 14),

              // Compliments chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _compliments.map((compliment) {
                  final isSelected =
                      _selectedCompliments.contains(compliment);
                  return FilterChip(
                    label: Text(compliment),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFEBEE),
                    checkmarkColor: const Color(0xFFC62828),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFC62828)
                          : const Color(0xFF4B5563),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCompliments.add(compliment);
                        } else {
                          _selectedCompliments.remove(compliment);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Feedback field
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Leave a note for ${widget.driverName} (optional)...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onRatingSubmitted(_selectedRating);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Submit rating',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
