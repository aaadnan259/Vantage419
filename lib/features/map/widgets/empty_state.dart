import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';

/// Shown on the map when no spots match the active roulette mode.
class EmptyStateOverlay extends StatelessWidget {
  const EmptyStateOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: 32,
      right: 32,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.colors.textMuted.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: context.colors.textSecondary,
                size: 20,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'No spots in this category yet',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
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
