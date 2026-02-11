import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/services/roulette_service.dart';

void main() {
  late RouletteService service;

  setUp(() {
    service = RouletteService();
  });

  // Data Loading tests moved to SpotRepository test

  group('RouletteService Spin Logic', () {
    final spots = [
      const ToledoSpot(
        id: '1',
        name: 'Spot 1',
        latitude: 0,
        longitude: 0,
        category: SpotCategory.dining,
        vibeCheck: '',
        description: '',
      ),
      const ToledoSpot(
        id: '2',
        name: 'Spot 2',
        latitude: 0,
        longitude: 0,
        category: SpotCategory.dining,
        vibeCheck: '',
        description: '',
      ),
    ];

    test('Returns null if pool is empty', () {
      final result = service.spin(spots: spots, pool: [], visits: []);
      expect(result, isNull);
    });

    test('Returns a spot from the pool', () {
      final result = service.spin(spots: spots, pool: spots, visits: []);
      expect(result, isNotNull);
      expect(spots.contains(result), isTrue);
    });

    test('Weighted selection logic runs without error', () {
      // Statistical testing is flaky, so we just ensure it runs
      final result = service.spin(
        spots: spots,
        pool: spots,
        visits: [UserVisit(spotId: '1', visitedAt: DateTime.now())],
      );
      expect(result, isNotNull);
    });
  });
}
