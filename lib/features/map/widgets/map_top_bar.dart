import 'package:flutter/material.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/utils/constants.dart';
import 'package:vantage419/features/map/widgets/map_icon_button.dart';
import 'package:vantage419/features/roulette/providers/roulette_state_provider.dart';
import 'package:vantage419/features/roulette/widgets/category_selector.dart';
import 'package:vantage419/features/settings/widgets/theme_toggle.dart';

class MapTopBar extends StatelessWidget {
  const MapTopBar({
    super.key,
    required this.rouletteState,
    required this.allSpots,
    required this.onModeSelected,
    required this.onFavoritesTap,
    required this.onHistoryTap,
    required this.onProfileTap,
  });

  final RouletteState rouletteState;
  final List<ToledoSpot> allSpots;
  final ValueChanged<int> onModeSelected;
  final VoidCallback onFavoritesTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    // S2.5: Category selector is dimmed during spin
    final topPadding =
        MediaQuery.of(context).padding.top + AppConstants.topBarPadding;

    return Stack(
      children: [
        // Category selector — top center
        Positioned(
          top: topPadding,
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
                  onSelected: onModeSelected,
                  spots: allSpots,
                ),
              ),
            ),
          ),
        ),

        // S7.6: Theme Toggle — top right
        Positioned(top: topPadding, right: 16, child: const ThemeToggle()),

        // Favorites + History buttons — top left
        Positioned(
          top: topPadding,
          left: 16,
          child: Row(
            children: [
              MapIconButton(
                icon: Icons.favorite_rounded,
                onTap: onFavoritesTap,
              ),
              const SizedBox(width: 8),
              MapIconButton(icon: Icons.history_rounded, onTap: onHistoryTap),
              const SizedBox(width: 8),
              MapIconButton(icon: Icons.bar_chart_rounded, onTap: onProfileTap),
            ],
          ),
        ),
      ],
    );
  }
}
