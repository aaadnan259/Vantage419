import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';

/// S4.5.3: Floating Search Pill
/// Replaces the old "Spin FAB".
/// Located at bottom center.
/// Features:
/// - Left: Search Icon + "Find a spot..." text
/// - Right: Green Circle Button with Dice icon (Triggers Roulette)
class FloatingSearchPill extends StatelessWidget {
  const FloatingSearchPill({
    super.key,
    required this.onTapDice,
    this.onTapSearch,
  });

  final VoidCallback onTapDice;
  final VoidCallback? onTapSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
      child: Row(
        children: [
          // Search Area (Left)
          Expanded(
            child: InkWell(
              onTap: onTapSearch,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: context.colors.textPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Find a spot...',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Divider
          Container(width: 1, height: 24, color: context.colors.surfaceLight),

          // Dice Button (Right)
          Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
              color: context.colors.accentDark, // Forest Green
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTapDice,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.casino_rounded, // Dice icon
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
