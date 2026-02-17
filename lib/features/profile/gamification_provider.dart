import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/core/providers/spots_provider.dart';

const _streakKey = 'spin_streak';
const _lastSpinDateKey = 'last_spin_date';

/// Gamification state for the user.
class GamificationState {
  const GamificationState({this.streak = 0, this.lastSpinDate});

  final int streak;
  final DateTime? lastSpinDate;

  GamificationState copyWith({int? streak, DateTime? lastSpinDate}) {
    return GamificationState(
      streak: streak ?? this.streak,
      lastSpinDate: lastSpinDate ?? this.lastSpinDate,
    );
  }
}

/// Manages spin streak tracking, persisted in SharedPreferences.
final gamificationProvider =
    NotifierProvider<GamificationNotifier, GamificationState>(
      GamificationNotifier.new,
    );

class GamificationNotifier extends Notifier<GamificationState> {
  @override
  GamificationState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final streak = prefs.getInt(_streakKey) ?? 0;
    final lastDateStr = prefs.getString(_lastSpinDateKey);
    final lastDate = lastDateStr != null
        ? DateTime.tryParse(lastDateStr)
        : null;

    return GamificationState(streak: streak, lastSpinDate: lastDate);
  }

  /// Call after every spin to update streak.
  Future<void> recordSpin() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = state.lastSpinDate;

    int newStreak;
    if (last == null) {
      // First ever spin
      newStreak = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        // Already spun today — no streak change
        return;
      } else if (diff == 1) {
        // Consecutive day — increment
        newStreak = state.streak + 1;
      } else {
        // Streak broken — reset to 1
        newStreak = 1;
      }
    }

    state = state.copyWith(streak: newStreak, lastSpinDate: now);
    await _persist(newStreak, now);
  }

  Future<void> _persist(int streak, DateTime date) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastSpinDateKey, date.toIso8601String());
  }
}

/// Discovery stats computed from visits + spots.
class DiscoveryStats {
  const DiscoveryStats({
    required this.totalSpots,
    required this.discoveredCount,
    required this.categoryProgress,
  });

  final int totalSpots;
  final int discoveredCount;
  final Map<SpotCategory, CategoryProgress> categoryProgress;

  double get overallProgress =>
      totalSpots > 0 ? discoveredCount / totalSpots : 0;
}

class CategoryProgress {
  const CategoryProgress({required this.discovered, required this.total});

  final int discovered;
  final int total;

  double get progress => total > 0 ? discovered / total : 0;
}

/// Computed provider that calculates discovery stats from visits + spots.
final discoveryStatsProvider = Provider<DiscoveryStats>((ref) {
  final spotsAsync = ref.watch(toledoSpotsProvider);

  return spotsAsync.when(
    loading: () => const DiscoveryStats(
      totalSpots: 0,
      discoveredCount: 0,
      categoryProgress: {},
    ),
    error: (_, _) => const DiscoveryStats(
      totalSpots: 0,
      discoveredCount: 0,
      categoryProgress: {},
    ),
    data: (spots) {
      // We need visits — read synchronously from shared prefs
      final prefs = ref.read(sharedPreferencesProvider);
      final raw = prefs.getString('user_visits');
      final visits = <UserVisit>[];
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                visits.add(UserVisit.fromJson(item));
              }
            }
          }
        } catch (_) {}
      }

      final visitedIds = visits.map((v) => v.spotId).toSet();
      final discovered = spots.where((s) => visitedIds.contains(s.id)).length;

      // Category breakdown
      final categoryProgress = <SpotCategory, CategoryProgress>{};
      for (final cat in SpotCategory.values) {
        final catSpots = spots.where((s) => s.category == cat).toList();
        final catDiscovered = catSpots
            .where((s) => visitedIds.contains(s.id))
            .length;
        categoryProgress[cat] = CategoryProgress(
          discovered: catDiscovered,
          total: catSpots.length,
        );
      }

      return DiscoveryStats(
        totalSpots: spots.length,
        discoveredCount: discovered,
        categoryProgress: categoryProgress,
      );
    },
  );
});
