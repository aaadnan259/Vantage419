import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/toledo_spot.dart';
import 'roulette_state_provider.dart';

/// Derived provider — the currently selected spot (nullable).
final selectedSpotProvider = Provider<ToledoSpot?>((ref) {
  return ref.watch(rouletteProvider).selectedSpot;
});
