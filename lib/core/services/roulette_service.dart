import 'dart:math';
import '../models/toledo_spot.dart';
import '../models/spot_category.dart';
import '../models/user_visit.dart';
import '../utils/constants.dart';

/// Weighted random selection engine.
/// Refactored (S3.2.2) to be pure logic with no persistence dependencies.
class RouletteService {
  RouletteService();

  /// S3.5: Class-level RNG.
  final _rng = Random();

  /// Pick a random spot with weighted selection.
  /// Spots not visited in [AppConstants.visitedWindowDays] get
  /// [AppConstants.unvisitedWeight]× probability.
  ToledoSpot? spin({
    required List<ToledoSpot> spots,
    required List<ToledoSpot> pool, // Pre-filtered by category
    required List<UserVisit> visits,
  }) {
    if (pool.isEmpty) return null;

    final cutoff = DateTime.now().subtract(
      const Duration(days: AppConstants.visitedWindowDays),
    );

    final recentVisitIds = visits
        .where((v) => v.visitedAt.isAfter(cutoff))
        .map((v) => v.spotId)
        .toSet();

    // Build weighted list
    final weighted = <ToledoSpot>[];
    for (final spot in pool) {
      final weight = recentVisitIds.contains(spot.id)
          ? 1
          : AppConstants.unvisitedWeight;
      for (var i = 0; i < weight; i++) {
        weighted.add(spot);
      }
    }

    return weighted[_rng.nextInt(weighted.length)];
  }
}
