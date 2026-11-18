import 'package:flutter/material.dart';
import '../../data/models/support_config.dart';

class TicketComposer extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final bool isSending;

  const TicketComposer({
    super.key,
    required this.text,
    required this.onChanged,
    required this.onSend,
    required this.isSending,
  });

  @override
  State<TicketComposer> createState() => _TicketComposerState();
}

class _TicketComposerState extends State<TicketComposer> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant TicketComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != _controller.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.text.trim().isNotEmpty && !widget.isSending;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file, color: Color(0xFF6B7280)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo & receipt attachment ready'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Material(
                color: canSend ? const Color(0xFFB91C1C) : const Color(0xFFE5E7EB),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: canSend ? widget.onSend : null,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: widget.isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            size: 18,
                            color: canSend ? Colors.white : const Color(0xFF9CA3AF),
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            SupportConfig.chatDisclaimer,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
