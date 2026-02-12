import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';

/// Floating action pill — spin-only button at the bottom center of the map.
/// Triggers the roulette spin to discover a random spot.
class FloatingSearchPill extends StatelessWidget {
  const FloatingSearchPill({super.key, required this.onTapDice});

  final VoidCallback onTapDice;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: context.colors.accentDark,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTapDice,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.casino_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Spin',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
