import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

const _batteryHelpKey = 'driver.battery_help.v1';

/// One-time OEM battery guidance. Does not request ignore-battery-optimizations
/// (Play restricts that permission).
class BatteryHelpPage extends StatelessWidget {
  const BatteryHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keep location running')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Some Android phones stop apps that share location in the '
                'background. After you finish this tip, open your phone’s '
                'battery settings for Bridge City Cabs and allow unrestricted '
                'or “no restrictions” while you are on shift.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'We do not ask for a permanent “ignore battery optimizations” '
                'permission. If tracking stops after the app is force-closed, '
                'open the app again when you return to your cab.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://dontkillmyapp.com/'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Manufacturer battery tips'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows once per install on Android after the first on-shift start.
Future<void> maybeShowBatteryHelp(BuildContext context, WidgetRef ref) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  final store = FlutterSecureStore();
  final seen = await store.read(_batteryHelpKey);
  if (seen == '1') return;
  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const BatteryHelpPage()),
  );
  await store.write(_batteryHelpKey, '1');
}
