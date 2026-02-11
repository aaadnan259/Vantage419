import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;
import 'package:latlong2/latlong.dart';
import '../../core/models/toledo_spot.dart';
import '../../core/services/location_service.dart';
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

/// Tracks whether map tiles are loading successfully.
final _tileErrorProvider = StateProvider<bool>((ref) => false);

/// Main screen — dark map with markers, spin button, and bottom sheet overlay.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for roulette error messages and surface them as SnackBars (S1.3)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(rouletteProvider, (prev, next) {
        final msg = next.errorMessage;
        if (msg != null && msg != prev?.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: VantageColors.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapController = ref.watch(mapControllerProvider);
    final rouletteState = ref.watch(rouletteProvider);
    final userLocation = ref.watch(userLocationProvider);
    final hasTileError = ref.watch(_tileErrorProvider);

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
              // Dark tile layer with error tracking (S1.6)
              TileLayer(
                urlTemplate: AppConstants.darkTileUrl,
                userAgentPackageName: 'com.vantage419.app',
                maxZoom: 19,
                tileProvider: NetworkTileProvider(),
                errorTileCallback: (tile, error, stackTrace) {
                  // Mark tile error state — shows banner
                  Future.microtask(() {
                    if (context.mounted) {
                      ref.read(_tileErrorProvider.notifier).state = true;
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
                      ref.read(_tileErrorProvider.notifier).state = false;
                    }
                  });
                  return MarkerLayer(
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
                  );
                },
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

          // Location error banner (S1.2) — shown when permission denied
          userLocation.whenOrNull(
                error: (error, _) => _LocationErrorBanner(error: error),
              ) ??
              const SizedBox.shrink(),

          // Tile error banner (S1.6) — shown when tiles fail to load
          if (hasTileError) const _TileErrorBanner(),

          // Category selector — top center (S2.5: dim during spin)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                ignoring: rouletteState.isSpinning,
                child: AnimatedOpacity(
                  opacity: rouletteState.isSpinning ? 0.4 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: CategorySelector(
                    selectedIndex: rouletteState.currentMode,
                    onSelected: (i) =>
                        ref.read(rouletteProvider.notifier).selectMode(i),
                  ),
                ),
              ),
            ),
          ),

          // Spin button — S2.2: AnimatedPositioned slides above sheet
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: rouletteState.selectedSpot != null
                ? MediaQuery.of(context).size.height * 0.42 + 16
                : 32,
            right: 24,
            child: SpinButton(
              isSpinning: rouletteState.isSpinning,
              hasResult: rouletteState.selectedSpot != null,
              hasError: rouletteState.errorMessage != null,
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

/// Banner shown when location permissions are denied or services disabled.
class _LocationErrorBanner extends StatelessWidget {
  const _LocationErrorBanner({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    String message;
    String actionLabel;
    VoidCallback? onAction;

    if (error is LocationPermissionDeniedForeverException) {
      message = 'Location access permanently denied';
      actionLabel = 'Open Settings';
      onAction = () => Geolocator.openAppSettings();
    } else if (error is LocationDisabledException) {
      message = 'Location services are off';
      actionLabel = 'Enable';
      onAction = () => Geolocator.openLocationSettings();
    } else if (error is LocationPermissionDeniedException) {
      message = 'Location permission needed for your position';
      actionLabel = 'Settings';
      onAction = () => Geolocator.openAppSettings();
    } else {
      message = 'Location unavailable';
      actionLabel = '';
      onAction = null;
    }

    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: VantageColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: VantageColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_off_rounded,
                color: VantageColors.warning,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: VantageColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (onAction != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: VantageColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(44, 44),
                  ),
                  child: Text(actionLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner shown when map tiles fail to load (S1.6).
class _TileErrorBanner extends StatelessWidget {
  const _TileErrorBanner();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: VantageColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: VantageColors.textMuted.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: VantageColors.textMuted,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Map tiles unavailable — check your connection',
                  style: TextStyle(
                    color: VantageColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
