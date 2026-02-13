import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/features/roulette/providers/roulette_state_provider.dart';

/// Derived provider — the currently selected spot (nullable).
final selectedSpotProvider = Provider<ToledoSpot?>((ref) {
  return ref.watch(rouletteProvider).selectedSpot;
});
