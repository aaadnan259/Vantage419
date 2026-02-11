import 'package:flutter/material.dart';
import '../../../core/models/roulette_mode.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/models/toledo_spot.dart';

/// Three-button row for roulette mode switching.
/// S2.3: 44dp tap targets, Semantics labels, mode icons, InkWell ripple.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.spots,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<ToledoSpot> spots;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(RouletteMode.modes.length, (i) {
          final mode = RouletteMode.modes[i];
          final isActive = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
            child: _ModeChip(
              label: mode.displayName,
              icon: mode.icon,
              color: mode.color,
              isActive: isActive,
              // S6.5: Count spots matching this mode
              count: spots
                  .where((s) => mode.categories.contains(s.category))
                  .length,
              onTap: () => onSelected(i),
            ),
          );
        }),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.count,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label mode, ${isActive ? 'selected' : 'not selected'}',
      button: true,
      selected: isActive,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: color.withValues(alpha: 0.2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? color.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? color
                      : context.colors.textMuted.withValues(alpha: 0.3),
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isActive ? color : context.colors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$label ($count)',
                    style: TextStyle(
                      color: isActive ? color : context.colors.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
