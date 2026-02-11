import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';

/// S6.3 / S4.5.5: Empty state when no spots match active mode.
/// Updated with "Playful" editorial style.
class EmptyStateOverlay extends StatelessWidget {
  const EmptyStateOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Playful Icon (Hungry Ghost / Plate)
            Icon(
              Icons.no_meals_rounded,
              size: 64,
              color: context.colors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              "No spots here!",
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your filters or\nexplore a different area.",
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
