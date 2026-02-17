import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/features/map/widgets/empty_state.dart';
import 'package:vantage419/features/map/widgets/map_controls.dart';

class MapStatusBanners extends StatelessWidget {
  const MapStatusBanners({
    super.key,
    required this.userLocation,
    required this.hasTileError,
    required this.filteredSpots,
  });

  final AsyncValue<LatLng> userLocation;
  final bool hasTileError;
  final List<ToledoSpot> filteredSpots;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Location error banner (S1.2) — shown when permission denied
        userLocation.whenOrNull(
              error: (error, _) => LocationErrorBanner(error: error),
            ) ??
            const SizedBox.shrink(),

        // Tile error banner (S1.6)
        if (hasTileError) const TileErrorBanner(),

        // S6.3: Empty state when no spots match active mode
        if (filteredSpots.isEmpty) const EmptyStateOverlay(),
      ],
    );
  }
}
