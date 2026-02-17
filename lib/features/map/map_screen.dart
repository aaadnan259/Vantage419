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
import 'package:vantage419/features/roulette/providers/roulette_state_provider.dart';
import 'package:vantage419/features/favorites/favorites_sheet.dart';
import 'package:vantage419/features/history/history_sheet.dart';
import 'package:vantage419/features/profile/profile_sheet.dart';
import 'package:vantage419/l10n/generated/app_localizations.dart';
import 'package:vantage419/features/map/widgets/map_view.dart';
import 'package:vantage419/features/map/widgets/map_top_bar.dart';
import 'package:vantage419/features/map/widgets/map_status_banners.dart';
import 'package:vantage419/features/map/widgets/map_action_area.dart';

/// Tracks whether map tiles are loading successfully.
final _tileErrorProvider = StateProvider<bool>((ref) => false);

/// Main screen — dark map with markers, spin button, and bottom sheet overlay.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.tileProvider});

  @visibleForTesting
  final TileProvider? tileProvider;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  AnimationController? _cameraAnimController;
  @override
  void initState() {
    super.initState();
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
              MapView(
                mapController: mapController,
                userLocation: userLocation,
                filteredSpots: filteredSpots,
                selectedSpotId: rouletteState.selectedSpot?.id,
                onSpotTapped: (spot) => _onSpotTapped(spot, mapController),
                onTileError: () =>
                    ref.read(_tileErrorProvider.notifier).state = true,
                onUserLocationSuccess: () =>
                    ref.read(_tileErrorProvider.notifier).state = false,
                tileProvider: widget.tileProvider,
              ),

              // Status banners
              MapStatusBanners(
                userLocation: userLocation,
                hasTileError: hasTileError,
                filteredSpots: filteredSpots,
              ),

              // Top controls
              MapTopBar(
                rouletteState: rouletteState,
                allSpots: allSpots,
                onModeSelected: (i) =>
                    ref.read(rouletteProvider.notifier).selectMode(i),
                onFavoritesTap: () => FavoritesSheet.show(context, allSpots),
                onHistoryTap: () => HistorySheet.show(context),
                onProfileTap: () => ProfileSheet.show(context),
              ),

              // Action area (Pill, BottomSheet, Overlay)
              MapActionArea(
                rouletteState: rouletteState,
                userLocation: userLocation,
                showOverlay: _showOverlay,
                candidates: _candidates,
                winner: _winner,
                onSpin: () => _onSpin(mapController, filteredSpots),
                onOverlayComplete: _onOverlayComplete,
                onRespin: () {
                  setState(() => _showOverlay = false);
                  _onSpin(mapController, filteredSpots);
                },
                onLetsGo: _onLetsGo,
                onCloseSelection: () =>
                    ref.read(rouletteProvider.notifier).clearSelection(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// S6.6: Animated camera fly-to instead of instant jump.
  void _animateCamera(MapController controller, LatLng target, double zoom) {
    // Cancel any in-flight camera animation to avoid leaks
    _cameraAnimController?.dispose();

    final cam = controller.camera;
    final startLat = cam.center.latitude;
    final startLng = cam.center.longitude;
    final startZoom = cam.zoom;

    final animController = AnimationController(
      vsync: this,
      duration: AppConstants.cameraDuration,
    );
    _cameraAnimController = animController;

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
        if (_cameraAnimController == animController) {
          _cameraAnimController = null;
        }
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
