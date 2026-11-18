import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PlaceCategory {
  mall,
  medical,
  entertainment,
  university,
  transit,
  landmark,
  recent,
}

/// Represents a location or place result in Lethbridge.
class LethbridgePlace extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String? matchedPrefix;
  final double distanceKm;
  final int etaMinutes;
  final PlaceCategory category;
  final double lat;
  final double lng;

  const LethbridgePlace({
    required this.id,
    required this.title,
    required this.subtitle,
    this.matchedPrefix,
    required this.distanceKm,
    required this.etaMinutes,
    this.category = PlaceCategory.landmark,
    required this.lat,
    required this.lng,
  });

  String get distanceText => '${distanceKm.toStringAsFixed(1)} km';
  String get etaText => '~$etaMinutes min';

  IconData get iconData {
    switch (category) {
      case PlaceCategory.mall:
        return Icons.shopping_bag_outlined;
      case PlaceCategory.medical:
        return Icons.medical_services_outlined;
      case PlaceCategory.entertainment:
        return Icons.movie_outlined;
      case PlaceCategory.university:
        return Icons.school_outlined;
      case PlaceCategory.transit:
        return Icons.directions_bus_outlined;
      case PlaceCategory.recent:
        return Icons.history_rounded;
      case PlaceCategory.landmark:
        return Icons.location_on_outlined;
    }
  }

  static const List<LethbridgePlace> parkPlaceResults = [
    LethbridgePlace(
      id: 'park_place_mall',
      title: 'Park Place Mall',
      subtitle: '501 1st Ave S, Lethbridge, AB',
      matchedPrefix: 'Park Place',
      distanceKm: 1.8,
      etaMinutes: 4,
      category: PlaceCategory.mall,
      lat: 49.6990,
      lng: -112.8420,
    ),
    LethbridgePlace(
      id: 'park_place_dental',
      title: 'Park Place Dental Centre',
      subtitle: '501 1st Ave S #180, Lethbridge',
      matchedPrefix: 'Park Place',
      distanceKm: 1.8,
      etaMinutes: 4,
      category: PlaceCategory.medical,
      lat: 49.6992,
      lng: -112.8415,
    ),
    LethbridgePlace(
      id: 'park_place_cineplex',
      title: 'Park Place Cineplex',
      subtitle: '501 1st Ave S, Lethbridge',
      matchedPrefix: 'Park Place',
      distanceKm: 1.9,
      etaMinutes: 5,
      category: PlaceCategory.entertainment,
      lat: 49.6985,
      lng: -112.8425,
    ),
    LethbridgePlace(
      id: 'park_meadows_clinic',
      title: 'Park Meadows Medical Clinic',
      subtitle: '2034 18th Ave N, Lethbridge',
      matchedPrefix: 'Park',
      distanceKm: 4.2,
      etaMinutes: 8,
      category: PlaceCategory.medical,
      lat: 49.7120,
      lng: -112.8150,
    ),
  ];

  static const List<LethbridgePlace> popularLandmarks = [
    LethbridgePlace(
      id: 'uleth',
      title: 'University of Lethbridge',
      subtitle: '4401 University Dr W, Lethbridge',
      distanceKm: 5.6,
      etaMinutes: 10,
      category: PlaceCategory.university,
      lat: 49.6780,
      lng: -112.8650,
    ),
    LethbridgePlace(
      id: 'park_place_mall',
      title: 'Park Place Mall',
      subtitle: '501 1st Ave S, Lethbridge, AB',
      distanceKm: 1.8,
      etaMinutes: 4,
      category: PlaceCategory.mall,
      lat: 49.6990,
      lng: -112.8420,
    ),
    LethbridgePlace(
      id: 'enmax_centre',
      title: 'Enmax Centre Lethbridge',
      subtitle: '2510 Scenic Dr S, Lethbridge',
      distanceKm: 3.4,
      etaMinutes: 7,
      category: PlaceCategory.entertainment,
      lat: 49.6750,
      lng: -112.8200,
    ),
  ];

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        matchedPrefix,
        distanceKm,
        etaMinutes,
        category,
        lat,
        lng,
      ];
}
