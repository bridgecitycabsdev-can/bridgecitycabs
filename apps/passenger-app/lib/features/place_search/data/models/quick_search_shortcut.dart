import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class QuickSearchShortcut extends Equatable {
  final String id;
  final String label;
  final IconData icon;
  final bool isHighlighted;

  const QuickSearchShortcut({
    required this.id,
    required this.label,
    required this.icon,
    this.isHighlighted = false,
  });

  static const List<QuickSearchShortcut> defaultShortcuts = [
    QuickSearchShortcut(
      id: 'pin_on_map',
      label: 'Pin on map',
      icon: Icons.location_on_outlined,
      isHighlighted: true,
    ),
    QuickSearchShortcut(
      id: 'recents',
      label: 'Recents',
      icon: Icons.history_rounded,
    ),
    QuickSearchShortcut(
      id: 'saved',
      label: 'Saved',
      icon: Icons.star_outline_rounded,
    ),
  ];

  static const List<QuickSearchShortcut> promptShortcuts = [
    QuickSearchShortcut(
      id: 'pin_on_map',
      label: 'Pin on map',
      icon: Icons.location_on_outlined,
      isHighlighted: true,
    ),
    QuickSearchShortcut(
      id: 'add_stop',
      label: 'Add stop',
      icon: Icons.add_rounded,
    ),
  ];

  static const List<QuickSearchShortcut> offlineShortcuts = [
    QuickSearchShortcut(
      id: 'pin_on_map',
      label: 'Pin on map',
      icon: Icons.location_on_outlined,
      isHighlighted: true,
    ),
    QuickSearchShortcut(
      id: 'home',
      label: 'Home',
      icon: Icons.home_outlined,
    ),
    QuickSearchShortcut(
      id: 'work',
      label: 'Work',
      icon: Icons.work_outline_rounded,
    ),
    QuickSearchShortcut(
      id: 'recents',
      label: 'Recents',
      icon: Icons.history_rounded,
    ),
  ];

  @override
  List<Object?> get props => [id, label, icon, isHighlighted];
}
