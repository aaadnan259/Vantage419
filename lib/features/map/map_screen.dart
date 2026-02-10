import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/toledo_spot.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/constants.dart';
import '../../data/toledo_spots.dart';
import 'providers/map_controller_provider.dart';
import 'providers/user_location_provider.dart';
import 'widgets/map_layer.dart';
import '../roulette/providers/roulette_state_provider.dart';
import '../roulette/widgets/spin_button.dart';
import '../roulette/widgets/category_selector.dart';
import '../roulette/widgets/spot_bottom_sheet.dart';

/// Main screen — dark map with markers, spin button, and bottom sheet overlay.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final mapController = ref.watch(mapControllerProvider);
    final rouletteState = ref.watch(rouletteProvider);
    final userLocation = ref.watch(userLocationProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map layer
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: AppConstants.toledoCenter,
              initialZoom: AppConstants.defaultZoom,
              backgroundColor: VantageColors.primaryBackground,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Dark tile layer
              TileLayer(
                urlTemplate: AppConstants.darkTileUrl,
                userAgentPackageName: 'com.vantage419.app',
                maxZoom: 19,
                tileProvider: NetworkTileProvider(),
              ),

              // User location marker
              userLocation.when(
                data: (pos) => MarkerLayer(
                  markers: [
                    Marker(
                      point: pos,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: VantageColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: VantageColors.accent.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, _) => const MarkerLayer(markers: []),
              ),

              // Spot markers
              SpotMarkerLayer(
                spots: toledoSpots,
                selectedSpotId: rouletteState.selectedSpot?.id,
                onSpotTapped: (spot) => _onSpotTapped(spot, mapController),
              ),
            ],
          ),

          // Category selector — top center
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Center(
              child: CategorySelector(
                selectedIndex: rouletteState.currentMode,
                onSelected: (i) =>
                    ref.read(rouletteProvider.notifier).selectMode(i),
              ),
            ),
          ),

          // Spin button — bottom right, thumb zone
          Positioned(
            bottom: rouletteState.selectedSpot != null
                ? MediaQuery.of(context).size.height * 0.42
                : 32,
            right: 24,
            child: SpinButton(
              isSpinning: rouletteState.isSpinning,
              onSpin: () => _onSpin(mapController),
            ),
          ),

          // Bottom sheet — displayed when a spot is selected
          if (rouletteState.selectedSpot != null)
            SpotBottomSheet(
              spot: rouletteState.selectedSpot!,
              onClose: () =>
                  ref.read(rouletteProvider.notifier).clearSelection(),
            ),
        ],
      ),
    );
  }

  void _onSpotTapped(ToledoSpot spot, MapController controller) {
    controller.move(
      LatLng(spot.latitude, spot.longitude),
      AppConstants.spotZoom,
    );
  }

  Future<void> _onSpin(MapController controller) async {
    final spot = await ref.read(rouletteProvider.notifier).spin();
    if (spot != null) {
      controller.move(
        LatLng(spot.latitude, spot.longitude),
        AppConstants.spotZoom,
      );
    }
  }
}
