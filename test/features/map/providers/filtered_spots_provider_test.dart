import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/providers/spots_provider.dart';
import 'package:vantage419/features/map/providers/filtered_spots_provider.dart';
import 'package:vantage419/features/roulette/providers/roulette_state_provider.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/core/services/analytics_service.dart';

void main() {
  test('filteredSpotsProvider filters spots based on roulette mode', () async {
    // 1. Setup Mock Data
    const diningSpot = ToledoSpot(
      id: '1',
      name: 'Dining Spot',
      latitude: 0,
      longitude: 0,
      category: SpotCategory.dining,
      vibeCheck: 'Vibe',
      description: 'Desc',
    );
    const fitnessSpot = ToledoSpot(
      id: '2',
      name: 'Fitness Spot',
      latitude: 0,
      longitude: 0,
      category: SpotCategory.fitness,
      vibeCheck: 'Vibe',
      description: 'Desc',
    );
    final spots = [diningSpot, fitnessSpot];

    // 2. Setup Container with Overrides
    final container = ProviderContainer(
      overrides: [
        toledoSpotsProvider.overrideWith((ref) => Future.value(spots)),
        analyticsProvider.overrideWithValue(AnalyticsService()), // No-op
      ],
    );
    addTearDown(container.dispose);

    // 3. Verify Initial State (Mode 0: Hungry -> Dining, Cafe)
    // Wait for toledoSpotsProvider to emit data
    await container.read(toledoSpotsProvider.future);

    var filtered = container.read(filteredSpotsProvider);
    expect(filtered.length, 1);
    expect(filtered.first.id, diningSpot.id);

    // 4. Change Mode (Mode 1: Active -> Recreation, Fitness)
    await container.read(rouletteProvider.notifier).selectMode(1);

    // 5. Verify Updated State
    filtered = container.read(filteredSpotsProvider);
    expect(filtered.length, 1);
    expect(filtered.first.id, fitnessSpot.id);
  });
}
