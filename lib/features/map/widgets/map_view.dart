import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/utils/constants.dart';
import 'package:vantage419/core/utils/extensions.dart';
import 'package:vantage419/features/map/widgets/map_layer.dart';
import 'package:vantage419/features/map/widgets/user_location_marker.dart';

class MapView extends StatelessWidget {
  const MapView({
    super.key,
    required this.mapController,
    required this.userLocation,
    required this.filteredSpots,
    this.selectedSpotId,
    required this.onSpotTapped,
    required this.onTileError,
    required this.onUserLocationSuccess,
    this.tileProvider,
  });

  final MapController mapController;
  final AsyncValue<LatLng> userLocation;
  final List<ToledoSpot> filteredSpots;
  final String? selectedSpotId;
  final ValueChanged<ToledoSpot> onSpotTapped;
  final VoidCallback onTileError;
  final VoidCallback onUserLocationSuccess;
  final TileProvider? tileProvider;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: AppConstants.toledoCenter,
        initialZoom: AppConstants.defaultZoom,
        backgroundColor: context.colors.primaryBackground,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // Theme-aware tile layer — switches between dark/light tiles
        TileLayer(
          urlTemplate: Theme.of(context).brightness == Brightness.dark
              ? AppConstants.darkTileUrl
              : AppConstants.lightTileUrl,
          userAgentPackageName: 'com.vantage419.app',
          maxZoom: 19,
          tileProvider: tileProvider ?? NetworkTileProvider(),
          errorTileCallback: (tile, error, stackTrace) {
            // Mark tile error state — shows banner
            Future.microtask(() {
              if (context.mounted) {
                onTileError();
              }
            });
          },
        ),

        // User location marker — handles permission errors (S1.2)
        userLocation.when(
          data: (pos) {
            // Clear tile error if location works (network likely ok)
            Future.microtask(() {
              if (context.mounted) {
                onUserLocationSuccess();
              }
            });
            return MarkerLayer(
              markers: [
                Marker(
                  point: pos,
                  width: 24,
                  height: 24,
                  child: const UserLocationMarker(),
                ),
              ],
            );
          },
          loading: () => const MarkerLayer(markers: []),
          error: (_, _) => const MarkerLayer(markers: []),
        ),

        // S5.2: Only render markers for spots matching active mode
        SpotMarkerLayer(
          spots: filteredSpots,
          selectedSpotId: selectedSpotId,
          onSpotTapped: onSpotTapped,
        ),
      ],
    );
  }
}
