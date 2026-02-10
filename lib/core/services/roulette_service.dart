import 'dart:convert';
import 'dart:math';
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

  /// Load persisted visits from disk.
  List<UserVisit> loadVisits() {
    final raw = _prefs.getString(_visitsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => UserVisit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Save visits to disk.
  Future<void> saveVisits(List<UserVisit> visits) async {
    final json = jsonEncode(visits.map((v) => v.toJson()).toList());
    await _prefs.setString(_visitsKey, json);
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
    return updated;
  }

  /// Pick a random spot with weighted selection.
  /// Spots not visited in [AppConstants.visitedWindowDays] get
  /// [AppConstants.unvisitedWeight]× probability.
  ToledoSpot? spin({
    required List<ToledoSpot> spots,
    required List<SpotCategory> categories,
    required List<UserVisit> visits,
  }) {
    // Filter by category
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

    final rng = Random();
    return weighted[rng.nextInt(weighted.length)];
  }
}
