import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/services/roulette_service.dart';

void main() {
  test('RouletteService Spin Benchmark', () {
    final service = RouletteService();
    const poolSize = 10000;
    const iterations = 1000;
    const visitedCount = 2000;

    // Generate pool
    final pool = List.generate(poolSize, (index) {
      return ToledoSpot(
        id: 'spot_$index',
        name: 'Spot $index',
        latitude: 0,
        longitude: 0,
        category: SpotCategory.dining,
        vibeCheck: '',
        description: '',
      );
    });

    // Generate visits for the first `visitedCount` spots
    final visits = List.generate(visitedCount, (index) {
      return UserVisit(
        spotId: 'spot_$index',
        visitedAt: DateTime.now(), // Recently visited
      );
    });

    final stopwatch = Stopwatch()..start();

    for (var i = 0; i < iterations; i++) {
      service.spin(pool: pool, visits: visits);
    }

    stopwatch.stop();
    // ignore: avoid_print
    print(
      'Benchmark: ${stopwatch.elapsedMilliseconds} ms for $iterations spins on a pool of $poolSize spots.',
    );
  });
}
