import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/features/map/widgets/custom_marker.dart';

/// Builds a MarkerLayer from a list of spots.
/// S4.4: Uses CustomMarker static constants for DRY sizing.
class SpotMarkerLayer extends StatelessWidget {
  const SpotMarkerLayer({
    super.key,
    required this.spots,
    this.selectedSpotId,
    this.onSpotTapped,
  });

  final List<ToledoSpot> spots;
  final String? selectedSpotId;
  final ValueChanged<ToledoSpot>? onSpotTapped;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: spots.map((spot) {
        final isSelected = spot.id == selectedSpotId;
        // Always use max for Marker bounds
        final size = CustomMarker.selectedSize;
        return Marker(
          point: LatLng(spot.latitude, spot.longitude),
          width: size,
          height: size,
          child: CustomMarker(
            category: spot.category,
            isSelected: isSelected,
            onTap: () => onSpotTapped?.call(spot),
          ),
        );
      }).toList(),
    );
  }
}
