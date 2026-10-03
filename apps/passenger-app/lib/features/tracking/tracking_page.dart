import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'driver_location.dart';
import 'trip_map.dart';

class TrackingPage extends ConsumerStatefulWidget {
  const TrackingPage({super.key});

  @override
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(activeBookingProvider);
    final location = ref.watch(driverLocationProvider);

    ref.listen(activeBookingProvider, (previous, next) {
      final booking = next.value;
      if (booking == null || booking.isTerminal) {
        context.go('/home');
      } else if (booking.isSearching) {
        context.go('/searching');
      }
    });

    return bookingAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Trip')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage(error)),
              TextButton(
                onPressed: () =>
                    ref.read(activeBookingProvider.notifier).refresh(),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
      data: (booking) {
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip')),
            body: const Center(child: Text('No active trip')),
          );
        }
        final driver = booking.driver;
        final vehicle = driver?.vehicle;
        return Scaffold(
          appBar: AppBar(
            title: Text(booking.status.replaceAll('_', ' ')),
            actions: [
              if (booking.canCancel)
                TextButton(
                  onPressed: _busy ? null : () => _cancel(booking.id),
                  child: const Text('Cancel'),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: TripMap(
                  label: booking.trackingId,
                  // Keep the placeholder until restricted SDK keys are present.
                  usePlaceholder: true,
                  driverLat: location?.lat,
                  driverLng: location?.lng,
                  pickupLat: booking.stops
                      .where((s) => s.type == 'PICKUP')
                      .map((s) => s.lat)
                      .firstOrNull,
                  pickupLng: booking.stops
                      .where((s) => s.type == 'PICKUP')
                      .map((s) => s.lng)
                      .firstOrNull,
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (driver != null) ...[
                        Text(
                          driver.firstName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Rating ${driver.rating.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (vehicle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            [
                              vehicle.make,
                              vehicle.model,
                              if (vehicle.colour != null) vehicle.colour!,
                            ].join(' · '),
                          ),
                          Text(vehicle.plate),
                          if (vehicle.unitNumber != null)
                            Text('Unit ${vehicle.unitNumber}'),
                        ],
                      ] else
                        Text(
                          'Driver details appear once assigned',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (booking.etaSeconds != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'ETA ${(booking.etaSeconds! / 60).ceil()} min',
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cancel(String bookingId) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(apiClientProvider)
          .dio
          .post<dynamic>('/passenger/bookings/$bookingId/cancel', data: {});
      if (!mounted) return;
      ref.read(activeBookingProvider.notifier).clear();
      ref.read(driverLocationProvider.notifier).clear();
      context.go('/home');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(error);
      });
    }
  }
}
