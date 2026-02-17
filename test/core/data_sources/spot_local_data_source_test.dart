import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/data_sources/spot_local_data_source.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/services/performance_service.dart';

void main() {
  late SpotLocalDataSource dataSource;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = SpotLocalDataSource(prefs, PerformanceService());
  });

  test('saveVisits encodes and saves visits correctly using compute', () async {
    final now = DateTime.now();
    final visits = [
      UserVisit(
        spotId: 'spot_1',
        visitedAt: now.subtract(const Duration(days: 1)),
        rating: 5,
      ),
      UserVisit(
        spotId: 'spot_2',
        visitedAt: now.subtract(const Duration(days: 2)),
        rating: 4,
      ),
    ];

    await dataSource.saveVisits(visits);

    final jsonString = prefs.getString('user_visits');
    expect(jsonString, isNotNull);

    final decoded = jsonDecode(jsonString!) as List;
    expect(decoded.length, 2);
    // Note: The order depends on pruning logic.
    // If we assume visits are saved, we check if they are present.
    // The implementation of saveVisits prunes and sorts (if needed).
    // Let's verify content.
    final spotIds = decoded.map((e) => e['spotId']).toList();
    expect(spotIds, containsAll(['spot_1', 'spot_2']));
  });

  test('loadVisits retrieves saved visits correctly', () async {
    final now = DateTime.now();
    final visits = [
      UserVisit(
        spotId: 'spot_1',
        visitedAt: now.subtract(const Duration(days: 1)),
        rating: 5,
      ),
    ];
    // Save first
    await dataSource.saveVisits(visits);

    // Load back
    final loadedVisits = await dataSource.loadVisits();
    expect(loadedVisits.length, 1);
    expect(loadedVisits[0].spotId, 'spot_1');
  });
}
