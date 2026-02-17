import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/utils/constants.dart';
import 'package:vantage419/features/map/widgets/floating_search_pill.dart';
import 'package:vantage419/features/roulette/providers/roulette_state_provider.dart';
import 'package:vantage419/features/roulette/widgets/shuffle_deck_overlay.dart';
import 'package:vantage419/features/roulette/widgets/spot_bottom_sheet.dart';

class MapActionArea extends StatelessWidget {
  const MapActionArea({
    super.key,
    required this.rouletteState,
    required this.userLocation,
    required this.showOverlay,
    required this.candidates,
    this.winner,
    required this.onSpin,
    required this.onOverlayComplete,
    required this.onRespin,
    required this.onLetsGo,
    required this.onCloseSelection,
  });

  final RouletteState rouletteState;
  final AsyncValue<LatLng> userLocation;
  final bool showOverlay;
  final List<ToledoSpot> candidates;
  final ToledoSpot? winner;
  final VoidCallback onSpin;
  final VoidCallback onOverlayComplete;
  final VoidCallback onRespin;
  final VoidCallback onLetsGo;
  final VoidCallback onCloseSelection;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
          child: Center(child: FloatingSearchPill(onTapDice: onSpin)),
        ),

        // Bottom sheet — displayed when a spot is selected AND overlay is closed
        if (rouletteState.selectedSpot != null && !showOverlay)
          SpotBottomSheet(
            spot: rouletteState.selectedSpot!,
            onClose: onCloseSelection,
            userLocation: userLocation.valueOrNull,
          ),

        // S4.5.4: Shuffle Deck Overlay
        if (showOverlay && winner != null)
          ShuffleDeckOverlay(
            candidates: candidates,
            winner: winner!,
            onComplete: onOverlayComplete,
            onRespin: onRespin,
            onLetsGo: onLetsGo,
          ),
      ],
    );
  }
}
