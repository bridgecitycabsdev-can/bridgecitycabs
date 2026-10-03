import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_placeholder.dart';

/// google_maps_flutter wrapper. Falls back to the placeholder when the
/// platform has no key yet or the map fails to build.
class TripMap extends StatelessWidget {
  const TripMap({
    super.key,
    this.label = 'Map',
    this.driverLat,
    this.driverLng,
    this.pickupLat,
    this.pickupLng,
    this.usePlaceholder = false,
  });

  final String label;
  final double? driverLat;
  final double? driverLng;
  final double? pickupLat;
  final double? pickupLng;
  final bool usePlaceholder;

  @override
  Widget build(BuildContext context) {
    if (usePlaceholder) {
      return MapPlaceholder(
        label: label,
        driverLat: driverLat,
        driverLng: driverLng,
      );
    }

    final centerLat = driverLat ?? pickupLat;
    final centerLng = driverLng ?? pickupLng;
    if (centerLat == null || centerLng == null) {
      return MapPlaceholder(label: label);
    }

    final markers = <Marker>{};
    if (driverLat != null && driverLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(driverLat!, driverLng!),
          infoWindow: const InfoWindow(title: 'Driver'),
        ),
      );
    }
    if (pickupLat != null && pickupLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(pickupLat!, pickupLng!),
          infoWindow: const InfoWindow(title: 'Pickup'),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(centerLat, centerLng),
        zoom: 14,
      ),
      markers: markers,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
