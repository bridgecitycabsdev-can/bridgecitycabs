import 'package:flutter/material.dart';

/// Predefined common transit & pickup hubs across Lethbridge, Alberta.
class LocationHub {
  final String id;
  final String name;
  final IconData icon;
  final double lat;
  final double lng;
  final String address;

  const LocationHub({
    required this.id,
    required this.name,
    required this.icon,
    required this.lat,
    required this.lng,
    required this.address,
  });

  static const List<LocationHub> lethbridgeHubs = [
    LocationHub(
      id: 'park_place',
      name: 'Park Place',
      icon: Icons.shopping_bag_outlined,
      lat: 49.6974,
      lng: -112.8427,
      address: '501 1 Ave S, Lethbridge, AB',
    ),
    LocationHub(
      id: 'downtown_hub',
      name: 'Downtown Hub',
      icon: Icons.account_balance_outlined,
      lat: 49.6942,
      lng: -112.8364,
      address: '4th Ave S & Scenic Dr, Lethbridge, AB',
    ),
    LocationHub(
      id: 'westside_uleth',
      name: 'Westside / ULeth',
      icon: Icons.school_outlined,
      lat: 49.6781,
      lng: -112.8687,
      address: '4401 University Dr W, Lethbridge, AB',
    ),
  ];
}
