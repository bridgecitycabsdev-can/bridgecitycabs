import 'package:flutter/material.dart';

import 'places.dart';

class PlaceField extends StatefulWidget {
  const PlaceField({
    super.key,
    required this.label,
    required this.controller,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final PlaceSearchController controller;
  final Future<void> Function(PlaceDetails details) onSelected;
  final bool enabled;

  @override
  State<PlaceField> createState() => _PlaceFieldState();
}

class _PlaceFieldState extends State<PlaceField> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.controller.text);
    widget.controller.addListener(_sync);
  }

  @override
  void didUpdateWidget(covariant PlaceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
      _text.text = widget.controller.text;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    _text.dispose();
    super.dispose();
  }

  void _sync() {
    if (_text.text != widget.controller.text) {
      _text.value = TextEditingValue(
        text: widget.controller.text,
        selection: TextSelection.collapsed(
          offset: widget.controller.text.length,
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          enabled: widget.enabled,
          controller: _text,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
          ),
          onChanged: controller.edit,
        ),
        if (controller.open && controller.suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: [
                for (final suggestion in controller.suggestions)
                  ListTile(
                    dense: true,
                    title: Text(suggestion.primaryText),
                    subtitle: Text(suggestion.secondaryText),
                    onTap: () async {
                      final details = await controller.select(
                        suggestion.placeId,
                      );
                      if (details != null) await widget.onSelected(details);
                    },
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Powered by Google',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
