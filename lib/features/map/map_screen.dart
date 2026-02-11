import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/toledo_spot.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/extensions.dart';
import '../../core/providers/spots_provider.dart';
import 'providers/map_controller_provider.dart';
import 'providers/user_location_provider.dart';
import 'widgets/empty_state.dart';
import 'widgets/map_controls.dart';
import 'widgets/map_layer.dart';
import 'widgets/user_location_marker.dart';
import 'widgets/floating_search_pill.dart';
import '../roulette/widgets/shuffle_deck_overlay.dart';
import '../roulette/providers/roulette_state_provider.dart';
import '../roulette/widgets/category_selector.dart';
import '../roulette/widgets/spot_bottom_sheet.dart';
import '../settings/widgets/theme_toggle.dart';

/// Tracks whether map tiles are loading successfully.
final _tileErrorProvider = StateProvider<bool>((ref) => false);

/// Main screen — dark map with markers, spin button, and bottom sheet overlay.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
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
              backgroundColor: context.colors.surface,
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
    final spotsAsync = ref.watch(toledoSpotsProvider);

    return Scaffold(
      body: spotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading spots: $err')),
        data: (allSpots) {
          // S5.2 + S6.3: Filter spots by active mode
          final filteredSpots = allSpots
              .where((s) => rouletteState.mode.categories.contains(s.category))
              .toList();

          return Stack(
            children: [
              // Map layer
              FlutterMap(
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
                  // Light tile layer (S4.5.3.1)
                  TileLayer(
                    urlTemplate: AppConstants.lightTileUrl,
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
                    selectedSpotId: rouletteState.selectedSpot?.id,
                    onSpotTapped: (spot) => _onSpotTapped(spot, mapController),
                  ),
                ],
              ),

              // Location error banner (S1.2) — shown when permission denied
              userLocation.whenOrNull(
                    error: (error, _) => LocationErrorBanner(error: error),
                  ) ??
                  const SizedBox.shrink(),

              // Tile error banner (S1.6)
              if (hasTileError) const TileErrorBanner(),

              // S6.3: Empty state when no spots match active mode
              if (filteredSpots.isEmpty) const EmptyStateOverlay(),

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
                        spots: allSpots,
                      ),
                    ),
                  ),
                ),
              ),

              // S7.6: Theme Toggle — top right
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: const ThemeToggle(),
              ),

              // S4.5.3.3: Floating Search Pill (Replaces SpinButton)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: rouletteState.selectedSpot != null
                    ? MediaQuery.of(context).size.height * 0.42 + 16
                    : 32,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingSearchPill(
                    onTapDice: () => _onSpin(mapController, filteredSpots),
                    onTapSearch: () {
                      // Future: Implement search
                    },
                  ),
                ),
              ),

              // Spin button placeholder (Functionality moved to Pill/Overlay)

              // Bottom sheet — displayed when a spot is selected AND overlay is closed
              if (rouletteState.selectedSpot != null && !_showOverlay)
                SpotBottomSheet(
                  spot: rouletteState.selectedSpot!,
                  onClose: () =>
                      ref.read(rouletteProvider.notifier).clearSelection(),
                ),

              // S4.5.4: Shuffle Deck Overlay
              if (_showOverlay && _winner != null)
                ShuffleDeckOverlay(
                  candidates: _candidates,
                  winner: _winner!,
                  onComplete: _onOverlayComplete,
                  onRespin: () {
                    setState(() => _showOverlay = false);
                    _onSpin(mapController, filteredSpots);
                  },
                  onLetsGo: _onLetsGo,
                ),
            ],
          );
        },
      ),
    );
  }

  /// S6.6: Animated camera fly-to instead of instant jump.
  void _animateCamera(MapController controller, LatLng target, double zoom) {
    final cam = controller.camera;
    final startLat = cam.center.latitude;
    final startLng = cam.center.longitude;
    final startZoom = cam.zoom;

    final animController = AnimationController(
      vsync: this,
      duration: AppConstants.cameraDuration,
    );
    final curve = CurvedAnimation(
      parent: animController,
      curve: Curves.easeInOutCubic,
    );

    animController.addListener(() {
      final t = curve.value;
      controller.move(
        LatLng(
          startLat + (target.latitude - startLat) * t,
          startLng + (target.longitude - startLng) * t,
        ),
        startZoom + (zoom - startZoom) * t,
      );
    });
    animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animController.dispose();
      }
    });
    animController.forward();
  }

  void _onSpotTapped(ToledoSpot spot, MapController controller) {
    _animateCamera(
      controller,
      LatLng(spot.latitude, spot.longitude),
      AppConstants.spotZoom,
    );
  }

  // S4.5.4: Overlay State
  bool _showOverlay = false;
  List<ToledoSpot> _candidates = [];
  ToledoSpot? _winner;

  Future<void> _onSpin(MapController controller, List<ToledoSpot> pool) async {
    if (pool.isEmpty) return;

    // 1. Generate Candidates (Shuffle Deck)
    final candidates = List<ToledoSpot>.from(pool)..shuffle();
    final deck = candidates.take(10).toList();

    // 2. Get Winner (Logic)
    final winner = await ref.read(rouletteProvider.notifier).spin();
    if (winner == null) return;

    // 3. Show Overlay
    if (mounted) {
      setState(() {
        _candidates = deck;
        _winner = winner;
        _showOverlay = true;
      });
    }
  }

  void _onOverlayComplete() {
    // Animation finished, winner is shown.
    // We update the map camera to the winner in background
    if (_winner != null) {
      ref
          .read(mapControllerProvider)
          .move(
            LatLng(_winner!.latitude, _winner!.longitude),
            AppConstants.spotZoom,
          );
    }
  }

  void _onLetsGo() {
    setState(() {
      _showOverlay = false;
    });
    // This reveals the bottom sheet which is already active due to notifier state
  }
}
