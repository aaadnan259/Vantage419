import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/utils/constants.dart';
import 'package:vantage419/core/utils/extensions.dart';
import 'package:vantage419/core/providers/spots_provider.dart';
import 'package:vantage419/features/map/providers/map_controller_provider.dart';
import 'package:vantage419/features/map/providers/user_location_provider.dart';
import 'package:vantage419/features/map/widgets/empty_state.dart';
import 'package:vantage419/features/map/widgets/map_controls.dart';
import 'package:vantage419/features/map/widgets/map_layer.dart';
import 'package:vantage419/features/map/widgets/user_location_marker.dart';
import 'package:vantage419/features/map/widgets/map_icon_button.dart';
import 'package:vantage419/features/map/widgets/floating_search_pill.dart';
import 'package:vantage419/features/roulette/widgets/shuffle_deck_overlay.dart';
import 'package:vantage419/features/roulette/providers/roulette_state_provider.dart';
import 'package:vantage419/features/roulette/widgets/category_selector.dart';
import 'package:vantage419/features/roulette/widgets/spot_bottom_sheet.dart';
import 'package:vantage419/features/settings/widgets/theme_toggle.dart';
import 'package:vantage419/features/favorites/favorites_sheet.dart';
import 'package:vantage419/features/history/history_sheet.dart';
import 'package:vantage419/features/profile/profile_sheet.dart';
import 'package:vantage419/l10n/generated/app_localizations.dart';
import 'package:vantage419/features/map/utils/map_camera_animator.dart';

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
  late final MapCameraAnimator _mapAnimator;

  @override
  void initState() {
    super.initState();
    _mapAnimator = MapCameraAnimator(vsync: this);

    // Track screen view
    ref.read(analyticsProvider).logScreenView('MapScreen');

    // Listen for roulette error messages and surface them as SnackBars (S1.3)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(rouletteProvider, (prev, next) {
        if (next.errorType != RouletteErrorType.none &&
            next.errorType != prev?.errorType) {
          final localizations = AppLocalizations.of(context);
          String? msg;

          if (localizations != null) {
            if (next.errorType == RouletteErrorType.noSpotsMatch) {
              msg = localizations.noSpotsMatchMode(next.mode.displayName);
            } else if (next.errorType == RouletteErrorType.generic) {
              msg = localizations.genericSpinError;
            }
          }

          if (msg != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: context.colors.surface,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.snackBarRadius,
                  ),
                ),
                duration: AppConstants.snackBarDuration,
              ),
            );
          }
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
        error: (err, stack) => Center(
          child: Text(
            AppLocalizations.of(context)?.errorLoadingSpots(err.toString()) ??
                'Error: $err',
          ),
        ),
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
                  // Theme-aware tile layer — switches between dark/light tiles
                  TileLayer(
                    urlTemplate: Theme.of(context).brightness == Brightness.dark
                        ? AppConstants.darkTileUrl
                        : AppConstants.lightTileUrl,
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
                top:
                    MediaQuery.of(context).padding.top +
                    AppConstants.topBarPadding,
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
                top:
                    MediaQuery.of(context).padding.top +
                    AppConstants.topBarPadding,
                right: 16,
                child: const ThemeToggle(),
              ),

              // Favorites + History buttons — top left
              Positioned(
                top:
                    MediaQuery.of(context).padding.top +
                    AppConstants.topBarPadding,
                left: 16,
                child: Row(
                  children: [
                    MapIconButton(
                      icon: Icons.favorite_rounded,
                      onTap: () => FavoritesSheet.show(context, allSpots),
                    ),
                    const SizedBox(width: 8),
                    MapIconButton(
                      icon: Icons.history_rounded,
                      onTap: () => HistorySheet.show(context),
                    ),
                    const SizedBox(width: 8),
                    MapIconButton(
                      icon: Icons.bar_chart_rounded,
                      onTap: () => ProfileSheet.show(context),
                    ),
                  ],
                ),
              ),

              // S4.5.3.3: Floating Search Pill (Replaces SpinButton)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: rouletteState.selectedSpot != null
                    ? MediaQuery.of(context).size.height *
                              AppConstants.bottomSheetHeightRatio +
                          AppConstants.pillAboveSheetPadding
                    : AppConstants.pillBottomOffset,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingSearchPill(
                    onTapDice: () => _onSpin(mapController, filteredSpots),
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
                  userLocation: userLocation.valueOrNull,
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

  @override
  void dispose() {
    _mapAnimator.dispose();
    super.dispose();
  }

  void _onSpotTapped(ToledoSpot spot, MapController controller) {
    _mapAnimator.animateTo(
      controller,
      LatLng(spot.latitude, spot.longitude),
      AppConstants.spotZoom,
    );
  }

  // S4.5.4: Overlay State
  bool _showOverlay = false;
  List<ToledoSpot> _candidates = [];
  ToledoSpot? _winner;
  DateTime? _lastSpinTime;

  Future<void> _onSpin(MapController controller, List<ToledoSpot> pool) async {
    if (pool.isEmpty) return;

    // Rate limit: 2-second cooldown between spins
    final now = DateTime.now();
    if (_lastSpinTime != null &&
        now.difference(_lastSpinTime!) <
            const Duration(seconds: AppConstants.spinCooldownSeconds)) {
      return;
    }
    _lastSpinTime = now;

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
