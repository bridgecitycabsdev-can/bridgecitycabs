import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen PIPEDA / Play disclosure shown before any location permission.
///
/// "Agree" records `POST /driver/consents` then returns true so the caller can
/// request the OS permission. Confirm wording and the 90-day retention with counsel.
class LocationDisclosurePage extends ConsumerStatefulWidget {
  const LocationDisclosurePage({super.key});

  @override
  ConsumerState<LocationDisclosurePage> createState() =>
      _LocationDisclosurePageState();
}

class _LocationDisclosurePageState
    extends ConsumerState<LocationDisclosurePage> {
  var _loading = true;
  var _busy = false;
  String? _error;
  String _version = '';
  String _text = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ref
          .read(apiClientProvider)
          .dio
          .get<dynamic>('/driver/location-notice');
      final body = jsonMap(response.data);
      if (!mounted) return;
      setState(() {
        _version = body?['version'] is String ? body!['version'] as String : '';
        _text = body?['text'] is String ? body!['text'] as String : '';
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = errorMessage(error);
      });
    }
  }

  Future<void> _agree() async {
    if (_version.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).dio.post<dynamic>(
        '/driver/consents',
        data: <String, dynamic>{
          'type': 'LOCATION_TRACKING',
          'version': _version,
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(error);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location while on shift')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _text.isEmpty
                              ? 'Unable to load the location notice.'
                              : _text,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _busy || _version.isEmpty ? null : _agree,
                      child: Text(_busy ? 'Saving…' : 'Agree'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Not now'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Shows the disclosure; returns true only after consent is recorded.
Future<bool> showLocationDisclosure(BuildContext context) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const LocationDisclosurePage()),
  );
  return result == true;
}
