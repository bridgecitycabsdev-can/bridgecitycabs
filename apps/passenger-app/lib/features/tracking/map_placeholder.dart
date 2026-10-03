import 'package:flutter/material.dart';

/// Placeholder until google_maps_flutter is wired with restricted SDK keys.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    this.label = 'Map',
    this.driverLat,
    this.driverLng,
  });

  final String label;
  final double? driverLat;
  final double? driverLng;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDriver = driverLat != null && driverLng != null;
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.map_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.titleMedium),
          if (hasDriver) ...[
            const SizedBox(height: 4),
            Text(
              'Driver ${driverLat!.toStringAsFixed(5)}, ${driverLng!.toStringAsFixed(5)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
