import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/core.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/core/providers/spots_provider.dart';

/// Provider for loading visit history from the repository.
final visitHistoryProvider = FutureProvider<List<UserVisit>>((ref) async {
  final repo = ref.watch(spotRepositoryProvider);
  return repo.getVisits();
});

/// A combined history item with the visit and the associated spot.
class HistoryItem {
  const HistoryItem({required this.visit, required this.spot});
  final UserVisit visit;
  final ToledoSpot spot;
}

/// Provider that combines visit history with spot details, sorted by date.
final historyItemsProvider = FutureProvider<List<HistoryItem>>((ref) async {
  final visits = await ref.watch(visitHistoryProvider.future);
  final spots = await ref.watch(toledoSpotsProvider.future);

  // Sort most recent first
  final sortedVisits = [...visits]
    ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

  // Build a lookup map for spots
  final spotMap = {for (final s in spots) s.id: s};

  return sortedVisits
      .map((visit) {
        final spot = spotMap[visit.spotId];
        if (spot == null) return null;
        return HistoryItem(visit: visit, spot: spot);
      })
      .whereType<HistoryItem>()
      .toList();
});

/// Bottom sheet showing the user's spin history with spot details.
class HistorySheet extends ConsumerWidget {
  const HistorySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyItemsProvider);

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
                    Icons.history_rounded,
                    color: context.colors.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Spin History',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: historyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Text(
                    'Failed to load history',
                    style: TextStyle(color: context.colors.textMuted),
                  ),
                ),
                data: (historyItems) {
                  if (historyItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.explore_off_rounded,
                            size: 48,
                            color: context.colors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No spins yet',
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the dice to start discovering!',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: historyItems.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 72,
                      color: context.colors.surfaceLight,
                    ),
                    itemBuilder: (context, index) {
                      final item = historyItems[index];
                      final visit = item.visit;
                      final spot = item.spot;

                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: spot.category.color.withValues(alpha: 0.15),
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
                          _formatDate(visit.visitedAt),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: spot.category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            spot.category.displayName,
                            style: TextStyle(
                              color: spot.category.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
