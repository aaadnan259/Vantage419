import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/core.dart';
import 'package:vantage419/features/favorites/favorites_provider.dart';

/// Full-screen bottom sheet showing the user's favorited spots.
class FavoritesSheet extends ConsumerWidget {
  const FavoritesSheet({super.key, required this.allSpots});

  final List<ToledoSpot> allSpots;

  static void show(BuildContext context, List<ToledoSpot> spots) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FavoritesSheet(allSpots: spots),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);
    final favSpots = allSpots.where((s) => favIds.contains(s.id)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            const DragHandle(),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: context.colors.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'My Spots',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${favSpots.length}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Spot list or empty state
            Expanded(
              child: favSpots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 48,
                            color: context.colors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No favorites yet',
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the heart on any spot to save it',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: favSpots.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        indent: 72,
                        color: context.colors.surfaceLight,
                      ),
                      itemBuilder: (context, index) {
                        final spot = favSpots[index];
                        return ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: spot.category.color.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              spot.category.icon,
                              color: spot.category.color,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            spot.name,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            spot.category.displayName,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.favorite_rounded,
                              color: context.colors.accent,
                              size: 20,
                            ),
                            onPressed: () => ref
                                .read(favoritesProvider.notifier)
                                .toggle(spot.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
