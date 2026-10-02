import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../http/json_map.dart';

class CodeEntry extends StatefulWidget {
  const CodeEntry({
    super.key,
    required this.phone,
    required this.onSubmit,
    required this.onResend,
  });

  final String phone;
  final Future<void> Function(String code) onSubmit;
  final Future<void> Function() onResend;

  @override
  State<CodeEntry> createState() => _CodeEntryState();
}

class _CodeEntryState extends State<CodeEntry> {
  final _code = TextEditingController();
  Timer? _timer;
  var _remaining = 60;
  var _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 1) {
        timer.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_code.text.trim());
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onResend();
      if (!mounted) return;
      _startTimer();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _code.text.trim();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the code',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text('Sent to ${widget.phone}'),
              const SizedBox(height: 24),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '6-digit code',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => code.length == 6 ? _submit() : null,
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy || code.length != 6 ? null : _submit,
                child: Text(_busy ? 'Checking…' : 'Verify'),
              ),
              const SizedBox(height: 12),
              if (_remaining > 0)
                Text('Resend in ${_remaining}s')
              else
                TextButton(
                  onPressed: _busy ? null : _resend,
                  child: const Text('Resend code'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
