import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/spot_category.dart';

/// App-wide constants.
abstract final class AppConstants {
  // Toledo, Ohio center
  static const toledoCenter = LatLng(41.6528, -83.5379);
  static const defaultZoom = 13.0;
  static const spotZoom = 15.5;

  // Dark map tiles (CartoDB Dark Matter)
  static const darkTileUrl =
      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';

  // Animation durations
  static const spinDuration = Duration(milliseconds: 1000);
  static const cameraDuration = Duration(milliseconds: 1200);
  static const sheetDuration = Duration(milliseconds: 300);

  // Bottom sheet heights (fraction of screen)
  static const sheetCollapsed = 0.40;
  static const sheetExpanded = 0.80;

  // Spin button
  static const spinButtonSize = 80.0;

  // Marker sizes
  static const markerSize = 40.0;
  static const markerIconSize = 24.0;

  // Weighting — unvisited spots get this multiplier
  static const unvisitedWeight = 3;
  static const visitedWindowDays = 30;
}

/// Pre-defined roulette modes.
class RouletteMode {
  const RouletteMode({
    required this.name,
    required this.displayName,
    required this.categories,
    required this.color,
  });

  final String name;
  final String displayName;
  final List<SpotCategory> categories;
  final Color color;

  /// All pre-defined modes.
  static const List<RouletteMode> modes = [
    RouletteMode(
      name: 'hungry',
      displayName: 'Hungry',
      categories: [SpotCategory.dining, SpotCategory.cafe],
      color: Color(0xFFFF6B6B),
    ),
    RouletteMode(
      name: 'active',
      displayName: 'Active',
      categories: [SpotCategory.recreation, SpotCategory.fitness],
      color: Color(0xFF4ECDC4),
    ),
    RouletteMode(
      name: 'surprise',
      displayName: 'Surprise Me',
      categories: SpotCategory.values,
      color: Color(0xFFFFE66D),
    ),
  ];
}
