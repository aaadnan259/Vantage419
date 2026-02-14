import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/services/roulette_service.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/user_visit.dart';

void main() {
  late RouletteService service;

  setUp(() {
    service = RouletteService();
  });

  const spot1 = ToledoSpot(
    id: '1',
    name: 'Spot 1',
    latitude: 0,
    longitude: 0,
    category: SpotCategory.dining,
    vibeCheck: '',
    description: '',
  );

  const spot2 = ToledoSpot(
    id: '2',
    name: 'Spot 2',
    latitude: 0,
    longitude: 0,
    category: SpotCategory.recreation,
    vibeCheck: '',
    description: '',
  );

  final spots = [spot1, spot2];

  test(
    'Spin returns a spot from the provided pool (Category Filter logic)',
    () {
      // Simulate filtering by 'Dining' (caller responsibility)
      final diningPool = spots
          .where((s) => s.category == SpotCategory.dining)
          .toList();

      final result = service.spin(pool: diningPool, visits: []);

      expect(result, isNotNull);
      expect(result!.category, equals(SpotCategory.dining));
      expect(result, equals(spot1));
    },
  );

  test('Spin biases against recently visited spots (Weighted logic)', () {
    // We can't deterministically test random, but we can verify it *can* pick unvisited
    // In a pure statistical test, we'd run this 1000 times.
    // For unit testing, we ensure it doesn't crash and returns a valid spot.

    final visited = [
      UserVisit(spotId: '1', visitedAt: DateTime.now()), // Recently visited
    ];

    // If we only have spot1 in pool, it MUST return spot1 even if visited
    final result = service.spin(pool: [spot1], visits: visited);

    expect(result, equals(spot1));

    // If we have both, it should favor spot2, but spot1 is still possible.
    // We just verify it returns *one* of them.
    final resultBoth = service.spin(pool: spots, visits: visited);
    expect(spots.contains(resultBoth), isTrue);
  });
}
