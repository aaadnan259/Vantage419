import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/roulette_mode.dart';

void main() {
  test('Benchmark spot filtering', () {
    // 1. Setup
    const int spotCount = 10000;
    const int iterations = 1000;

    final spots = List.generate(spotCount, (index) {
      return ToledoSpot(
        id: 'spot_$index',
        name: 'Spot $index',
        latitude: 0.0,
        longitude: 0.0,
        category: SpotCategory.values[index % SpotCategory.values.length],
        vibeCheck: 'Vibe',
        description: 'Description',
      );
    });

    final mode = RouletteMode.modes[0]; // Hungry (Dining, Cafe)

    // 2. Measure Filtering (Baseline)
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      final filtered = spots
          .where((s) => mode.categories.contains(s.category))
          .toList();
      assert(filtered.isNotEmpty);
    }
    stopwatch.stop();
    debugPrint(
      'Filtering $spotCount spots $iterations times took: ${stopwatch.elapsedMilliseconds} ms',
    );
    debugPrint(
      'Average time per filter: ${stopwatch.elapsedMicroseconds / iterations} µs',
    );

    // 3. Measure Accessing Cached (Optimized)
    final cached = spots
        .where((s) => mode.categories.contains(s.category))
        .toList();

    stopwatch.reset();
    stopwatch.start();
    for (int i = 0; i < iterations; i++) {
      final result = cached;
      assert(result.isNotEmpty);
    }
    stopwatch.stop();
    debugPrint(
      'Accessing cached spots $iterations times took: ${stopwatch.elapsedMilliseconds} ms',
    );
    debugPrint(
      'Average time per access: ${stopwatch.elapsedMicroseconds / iterations} µs',
    );
  });
}
