import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../http/json_map.dart';

class PhoneEntry extends StatefulWidget {
  const PhoneEntry({super.key, required this.onSubmit});

  final Future<void> Function(String rawPhone) onSubmit;

  @override
  State<PhoneEntry> createState() => _PhoneEntryState();
}

class _PhoneEntryState extends State<PhoneEntry> {
  final _phone = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_phone.text);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mobile number',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('Canada +1. We text a 6-digit code.'),
              const SizedBox(height: 24),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ()+-]')),
                ],
                decoration: const InputDecoration(
                  prefixText: '+1 ',
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Sending…' : 'Send code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
