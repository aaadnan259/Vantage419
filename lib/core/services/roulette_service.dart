import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/toledo_spot.dart';
import '../models/spot_category.dart';
import '../models/user_visit.dart';
import '../utils/constants.dart';

/// Weighted random selection engine for spot discovery.
class RouletteService {
  RouletteService(this._prefs);

  final SharedPreferences _prefs;
  static const _visitsKey = 'user_visits';

  /// S3.5: Class-level RNG for better distribution across spins.
  final _rng = Random();

  /// Hard cap on stored visits to prevent unbounded growth (S3.1).
  static const _maxVisits = 500;

  /// Load persisted visits from disk.
  /// Handles corrupt JSON gracefully — resets and returns empty on failure.
  List<UserVisit> loadVisits() {
    final raw = _prefs.getString(_visitsKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        debugPrint('⚠️ Visit data is not a list, resetting');
        _prefs.remove(_visitsKey);
        return [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) {
            try {
              return UserVisit.fromJson(e);
            } catch (_) {
              return null;
            }
          })
          .whereType<UserVisit>()
          .toList();
    } catch (e) {
      debugPrint('⚠️ Corrupt visit data, resetting: $e');
      _prefs.remove(_visitsKey);
      return [];
    }
  }

  /// Save visits to disk after pruning stale entries (S3.1).
  Future<void> saveVisits(List<UserVisit> visits) async {
    final pruned = _pruneVisits(visits);
    final json = jsonEncode(pruned.map((v) => v.toJson()).toList());
    await _prefs.setString(_visitsKey, json);
  }

  /// Remove entries older than the visit window and cap total count (S3.1).
  List<UserVisit> _pruneVisits(List<UserVisit> visits) {
    final cutoff = DateTime.now().subtract(
      const Duration(days: AppConstants.visitedWindowDays * 2),
    );

    var pruned = visits.where((v) => v.visitedAt.isAfter(cutoff)).toList();

    // Hard cap — keep most recent if over limit
    if (pruned.length > _maxVisits) {
      pruned.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
      pruned = pruned.sublist(0, _maxVisits);
    }

    return pruned;
  }

  /// Record a visit for the given spot.
  Future<List<UserVisit>> recordVisit(
    String spotId,
    List<UserVisit> existing,
  ) async {
    final updated = [
      ...existing,
      UserVisit(spotId: spotId, visitedAt: DateTime.now()),
    ];
    await saveVisits(updated);
    return _pruneVisits(updated);
  }

  /// Pick a random spot with weighted selection.
  /// Spots not visited in [AppConstants.visitedWindowDays] get
  /// [AppConstants.unvisitedWeight]× probability.
  ToledoSpot? spin({
    required List<ToledoSpot> spots,
    required List<SpotCategory> categories,
    required List<UserVisit> visits,
  }) {
    final pool = spots.where((s) => categories.contains(s.category)).toList();

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
