import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/providers/spots_provider.dart';
import 'package:vantage419/features/roulette/providers/roulette_state_provider.dart';

/// Provides a memoized list of spots filtered by the active roulette mode.
///
/// This avoids re-filtering the entire spot list on every build or location update,
/// which is crucial for map performance.
final filteredSpotsProvider = Provider<List<ToledoSpot>>((ref) {
  // Watch the full list of spots
  final spotsAsync = ref.watch(toledoSpotsProvider);

  // Watch only the mode from roulette state to minimize rebuilds
  final mode = ref.watch(rouletteProvider.select((state) => state.mode));

  // Return filtered list if data is available, otherwise empty list.
  // The UI handles loading/error states by watching spotsAsync separately.
  return spotsAsync.maybeWhen(
    data: (spots) {
      return spots
          // Note: mode.categories is a Set<SpotCategory>, so contains() is O(1).
          // This ensures efficient filtering even with large spot lists.
          .where((s) => mode.categories.contains(s.category))
          .toList();
    },
    orElse: () => const [],
  );
});
