import 'dart:math';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/utils/constants.dart';

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

    // Calculate total weight (O(n)) to avoid memory allocation for weighted list
    int totalWeight = 0;
    for (final spot in pool) {
      totalWeight += recentVisitIds.contains(spot.id)
          ? 1
          : AppConstants.unvisitedWeight;
    }

    if (totalWeight == 0) return null;

    int randomWeight = _rng.nextInt(totalWeight);

    // Select based on cumulative weight
    for (final spot in pool) {
      final weight = recentVisitIds.contains(spot.id)
          ? 1
          : AppConstants.unvisitedWeight;
      randomWeight -= weight;
      if (randomWeight < 0) {
        return spot;
      }
    }

    // Fallback should theoretically not be reached if math is correct
    return pool.last;
  }
}
