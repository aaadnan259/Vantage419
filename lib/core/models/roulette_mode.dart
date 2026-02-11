import 'package:flutter/material.dart';
import 'spot_category.dart';

/// A roulette mode that filters spots by category groups.
class RouletteMode {
  const RouletteMode({
    required this.name,
    required this.displayName,
    required this.categories,
    required this.color,
    required this.icon,
  });

  final String name;
  final String displayName;
  final List<SpotCategory> categories;
  final Color color;
  final IconData icon;

  /// All pre-defined modes.
  static const List<RouletteMode> modes = [
    RouletteMode(
      name: 'hungry',
      displayName: 'Hungry',
      categories: [SpotCategory.dining, SpotCategory.cafe],
      color: Color(0xFFFF6B6B),
      icon: Icons.restaurant_rounded,
    ),
    RouletteMode(
      name: 'active',
      displayName: 'Active',
      categories: [SpotCategory.recreation, SpotCategory.fitness],
      color: Color(0xFF4ECDC4),
      icon: Icons.directions_run_rounded,
    ),
    RouletteMode(
      name: 'surprise',
      displayName: 'Surprise Me',
      categories: SpotCategory.values,
      color: Color(0xFFFFE66D),
      icon: Icons.casino_rounded,
    ),
  ];
}
