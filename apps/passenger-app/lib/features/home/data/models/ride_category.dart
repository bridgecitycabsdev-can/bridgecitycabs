import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RideCategory extends Equatable {
  final String id;
  final String label;
  final IconData icon;

  const RideCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  static const List<RideCategory> homeCategories = [
    RideCategory(
      id: 'schedule',
      label: 'Schedule',
      icon: Icons.calendar_today_outlined,
    ),
    RideCategory(
      id: 'airport',
      label: 'Airport',
      icon: Icons.flight_takeoff_rounded,
    ),
    RideCategory(
      id: 'long_distance',
      label: 'Long distance',
      icon: Icons.alt_route_rounded,
    ),
  ];

  static const List<RideCategory> hubShortcuts = [
    RideCategory(
      id: 'campus_express',
      label: 'Campus Express',
      icon: Icons.school_outlined,
    ),
    RideCategory(
      id: 'park_place_mall',
      label: 'Park Place Mall',
      icon: Icons.shopping_bag_outlined,
    ),
    RideCategory(
      id: 'regional',
      label: 'Regional...',
      icon: Icons.add_rounded,
    ),
  ];

  @override
  List<Object?> get props => [id, label, icon];
}
