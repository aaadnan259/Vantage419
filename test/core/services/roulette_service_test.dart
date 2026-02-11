import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/services/roulette_service.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/user_visit.dart';

void main() {
  late RouletteService service;

  Future<RouletteService> createService([
    Map<String, Object> initial = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return RouletteService(prefs);
  }

  setUp(() async {
    service = await createService();
  });

  group('loadVisits', () {
    test('returns empty list when no data stored', () {
      expect(service.loadVisits(), isEmpty);
    });

    test('survives corrupt JSON gracefully', () async {
      final svc = await createService({'user_visits': '{broken'});
      expect(svc.loadVisits(), isEmpty);
    });

    test('skips non-map entries and parses others defensively', () async {
      final data = jsonEncode([
        {'spotId': 'ok_001', 'visitedAt': '2026-01-01T00:00:00.000'},
        {'bad': 'entry'}, // S3.4: parses with fallback defaults
        42, // Filtered by whereType<Map>
      ]);
      final svc = await createService({'user_visits': data});
      final visits = svc.loadVisits();
      // 2 map entries parse (with fallbacks), integer is skipped
      expect(visits.length, 2);
      expect(visits.first.spotId, 'ok_001');
      expect(visits.last.spotId, ''); // fallback from missing key
    });
  });

  group('visit pruning (S3.1)', () {
    test('caps visits at 500 entries', () async {
      // Record 550 visits
      var visits = <UserVisit>[];
      for (var i = 0; i < 550; i++) {
        visits.add(
          UserVisit(
            spotId: 'spot_$i',
            visitedAt: DateTime.now().subtract(Duration(hours: i)),
          ),
        );
      }
      await service.saveVisits(visits);
      final loaded = service.loadVisits();
      expect(loaded.length, lessThanOrEqualTo(500));
    });

    test('removes entries older than TTL window', () async {
      final old = UserVisit(
        spotId: 'ancient',
        visitedAt: DateTime.now().subtract(const Duration(days: 365)),
      );
      final recent = UserVisit(spotId: 'fresh', visitedAt: DateTime.now());
      await service.saveVisits([old, recent]);
      final loaded = service.loadVisits();
      expect(loaded.length, 1);
      expect(loaded.first.spotId, 'fresh');
    });
  });

  group('spin', () {
    final spots = [
      const ToledoSpot(
        id: 'test_001',
        name: 'Test Spot',
        latitude: 41.65,
        longitude: -83.54,
        category: SpotCategory.dining,
        vibeCheck: 'test',
        description: 'test description',
      ),
    ];

    test('returns null when pool is empty', () {
      final result = service.spin(
        spots: spots,
        categories: [SpotCategory.fitness],
        visits: [],
      );
      expect(result, isNull);
    });

    test('returns a spot when pool matches', () {
      final result = service.spin(
        spots: spots,
        categories: [SpotCategory.dining],
        visits: [],
      );
      expect(result, isNotNull);
      expect(result!.id, 'test_001');
    });

    test('still returns when all spots are recently visited', () {
      final visits = [UserVisit(spotId: 'test_001', visitedAt: DateTime.now())];
      final result = service.spin(
        spots: spots,
        categories: [SpotCategory.dining],
        visits: visits,
      );
      expect(result, isNotNull);
    });
  });
}
