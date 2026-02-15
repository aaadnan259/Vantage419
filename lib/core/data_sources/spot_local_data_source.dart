import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/utils/constants.dart';
import 'package:vantage419/core/services/performance_service.dart';

/// Top-level function for compute to avoid capturing closures
List<UserVisit> _parseVisits(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    throw const FormatException('Expected a list');
  }
  return decoded
      .whereType<Map<String, dynamic>>()
      .map((e) => UserVisit.fromJson(e))
      .toList();
}

class SpotLocalDataSource {
  final SharedPreferences _prefs;
  static const _visitsKey = 'user_visits';
  static const _maxVisits = 500;
  static const _spotsAssetPath = 'assets/data/spots.json';

  SpotLocalDataSource(this._prefs, this._performance);

  final PerformanceService _performance;

  List<ToledoSpot>? _cachedSpots;

  /// Loads spots from the bundled JSON asset.
  /// Caches results after first load so repeated calls are free.
  Future<List<ToledoSpot>> fetchStaticSpots() async {
    if (_cachedSpots != null) return _cachedSpots!;

    try {
      final trace = _performance.startTrace('fetch_static_spots');
      final raw = await rootBundle.loadString(_spotsAssetPath);
      final decoded = jsonDecode(raw) as List<dynamic>;
      _cachedSpots = decoded
          .whereType<Map<String, dynamic>>()
          .map((json) => ToledoSpot.fromJson(json))
          .toList();

      trace.setMetric('spot_count', _cachedSpots!.length);
      trace.stop();

      return _cachedSpots!;
    } catch (e) {
      debugPrint('⚠️ Failed to load spots asset: $e');
      return [];
    }
  }

  Future<List<UserVisit>> loadVisits() async {
    final raw = _prefs.getString(_visitsKey);
    if (raw == null) return [];

    try {
      return await compute(_parseVisits, raw);
    } catch (e) {
      debugPrint('⚠️ Corrupt visit data, resetting: $e');
      await _prefs.remove(_visitsKey);
      return [];
    }
  }

  Future<void> saveVisits(List<UserVisit> visits) async {
    // Pruning logic handled here to ensure data integrity at the source
    final cutoff = DateTime.now().subtract(
      const Duration(days: AppConstants.visitedWindowDays * 2),
    );

    var pruned = visits.where((v) => v.visitedAt.isAfter(cutoff)).toList();
    if (pruned.length > _maxVisits) {
      pruned.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
      pruned = pruned.sublist(0, _maxVisits);
    }

    final json = jsonEncode(pruned.map((v) => v.toJson()).toList());
    await _prefs.setString(_visitsKey, json);
  }
}
