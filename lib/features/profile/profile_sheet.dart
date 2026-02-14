import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/utils/extensions.dart';
import 'package:vantage419/features/profile/gamification_provider.dart';

/// Profile sheet showing gamification stats: streak, discovery progress,
/// and category completion.
class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final stats = ref.watch(discoveryStatsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Your Stats',
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            // Streak + Discovery cards row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF6B35),
                    label: 'Spin Streak',
                    value: '${gamification.streak}',
                    subtitle: gamification.streak > 0
                        ? '${gamification.streak} day${gamification.streak == 1 ? '' : 's'}'
                        : 'Spin today!',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.explore_rounded,
                    iconColor: context.colors.accent,
                    label: 'Discovered',
                    value: '${stats.discoveredCount}/${stats.totalSpots}',
                    subtitle:
                        '${(stats.overallProgress * 100).toInt()}% explored',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Category completion
            Text(
              'Category Progress',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            ...SpotCategory.values.map((cat) {
              final progress = stats.categoryProgress[cat];
              if (progress == null || progress.total == 0) {
                return const SizedBox.shrink();
              }
              return _CategoryRow(category: cat, progress: progress);
            }),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.headlineMedium?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.progress});

  final SpotCategory category;
  final CategoryProgress progress;

  @override
  Widget build(BuildContext context) {
    final isComplete = progress.discovered >= progress.total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: category.color),
              const SizedBox(width: 10),
              Text(
                category.displayName,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (isComplete)
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: context.colors.success,
                ),
              const SizedBox(width: 6),
              Text(
                '${progress.discovered}/${progress.total}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.progress,
              minHeight: 6,
              backgroundColor: context.colors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? context.colors.success : category.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
