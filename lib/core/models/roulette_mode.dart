import 'package:flutter/material.dart';
import 'package:vantage419/core/models/spot_category.dart';

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
  final Set<SpotCategory> categories;
  final Color color;
  final IconData icon;

  /// All pre-defined modes.
  static const List<RouletteMode> modes = [
    RouletteMode(
      name: 'hungry',
      displayName: 'Hungry',
      categories: {SpotCategory.dining, SpotCategory.cafe},
      color: Color(0xFFFF6B6B),
      icon: Icons.restaurant_rounded,
    ),
    RouletteMode(
      name: 'active',
      displayName: 'Active',
      categories: {SpotCategory.recreation, SpotCategory.fitness},
      color: Color(0xFF4ECDC4),
      icon: Icons.directions_run_rounded,
    ),
    RouletteMode(
      name: 'going_out',
      displayName: 'Going Out',
      categories: {
        SpotCategory.nightlife,
        SpotCategory.entertainment,
        SpotCategory.cafe,
      },
      color: Color(0xFFE040FB),
      icon: Icons.nightlife_rounded,
    ),
    RouletteMode(
      name: 'surprise',
      displayName: 'Surprise Me',
      categories: {
        SpotCategory.dining,
        SpotCategory.recreation,
        SpotCategory.fitness,
        SpotCategory.cafe,
        SpotCategory.entertainment,
        SpotCategory.nightlife,
      },
      color: Color(0xFFFFE66D),
      icon: Icons.casino_rounded,
    ),
  ];
}
