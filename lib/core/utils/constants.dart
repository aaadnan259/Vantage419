import 'package:latlong2/latlong.dart';

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
  static const markerSelectedSize = 48.0;
  static const markerIconSize = 24.0;

  // Common border radii (S4.6)
  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 16.0;
  static const radiusXL = 20.0;

  // Weighting — unvisited spots get this multiplier
  static const unvisitedWeight = 3;
  static const visitedWindowDays = 30;
}
