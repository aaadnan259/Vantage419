import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/toledo_spot.dart';
import 'custom_marker.dart';

/// Builds a MarkerLayer from a list of spots.
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
        return Marker(
          point: LatLng(spot.latitude, spot.longitude),
          width: isSelected ? 48 : 40,
          height: isSelected ? 48 : 40,
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
