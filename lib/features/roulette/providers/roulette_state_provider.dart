import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/roulette_mode.dart';
import '../../../core/models/toledo_spot.dart';
import '../../../core/models/user_visit.dart';
import '../../../core/services/roulette_service.dart';
import '../../../core/utils/constants.dart';
import '../../../data/toledo_spots.dart';

/// SharedPreferences provider — initialized in main.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main with ProviderScope');
});

/// RouletteService provider.
final rouletteServiceProvider = Provider<RouletteService>((ref) {
  return RouletteService(ref.read(sharedPreferencesProvider));
});

/// Current roulette mode state.
class RouletteState {
  const RouletteState({
    this.currentMode = 0,
    this.isSpinning = false,
    this.selectedSpot,
    this.visits = const [],
    this.errorMessage,
  });

  final int currentMode;
  final bool isSpinning;
  final ToledoSpot? selectedSpot;
  final List<UserVisit> visits;
  final String? errorMessage;

  /// S3.3: Bounds-checked mode getter — clamps to valid range.
  RouletteMode get mode =>
      RouletteMode.modes[currentMode.clamp(0, RouletteMode.modes.length - 1)];

  RouletteState copyWith({
    int? currentMode,
    bool? isSpinning,
    ToledoSpot? selectedSpot,
    List<UserVisit>? visits,
    String? errorMessage,
    bool clearSelectedSpot = false,
    bool clearError = false,
  }) {
    return RouletteState(
      currentMode: currentMode ?? this.currentMode,
      isSpinning: isSpinning ?? this.isSpinning,
      selectedSpot: clearSelectedSpot
          ? null
          : (selectedSpot ?? this.selectedSpot),
      visits: visits ?? this.visits,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Manages roulette spinning, mode selection, and visit tracking.
class RouletteNotifier extends StateNotifier<RouletteState> {
  RouletteNotifier(this._service) : super(const RouletteState()) {
    // S3.2: Debug-only validation that all spot IDs are unique
    assert(() {
      final ids = toledoSpots.map((s) => s.id).toList();
      final unique = ids.toSet();
      if (ids.length != unique.length) {
        final dupes = ids
            .where((id) => ids.where((i) => i == id).length > 1)
            .toSet();
        debugPrint('⚠️ Duplicate spot IDs detected: $dupes');
      }
      return ids.length == unique.length;
    }(), 'All spot IDs must be unique — found duplicates in toledo_spots.dart');

    _loadVisits();
  }

  final RouletteService _service;

  void _loadVisits() {
    state = state.copyWith(visits: _service.loadVisits());
  }

  /// S3.3: Bounds-checked mode selection — rejects invalid indices.
  void selectMode(int index) {
    if (index < 0 || index >= RouletteMode.modes.length) return;
    state = state.copyWith(
      currentMode: index,
      clearSelectedSpot: true,
      clearError: true,
    );
  }

  /// Spin the roulette — returns the selected spot or null.
  Future<ToledoSpot?> spin() async {
    if (state.isSpinning) return null;

    state = state.copyWith(
      isSpinning: true,
      clearSelectedSpot: true,
      clearError: true,
    );

    try {
      await Future.delayed(AppConstants.spinDuration);

      final result = _service.spin(
        spots: toledoSpots,
        categories: state.mode.categories,
        visits: state.visits,
      );

      if (result != null) {
        final updatedVisits = await _service.recordVisit(
          result.id,
          state.visits,
        );
        state = state.copyWith(
          isSpinning: false,
          selectedSpot: result,
          visits: updatedVisits,
        );
      } else {
        state = state.copyWith(
          isSpinning: false,
          errorMessage:
              "No spots match '${state.mode.displayName}' — try 'Surprise Me'!",
        );
      }

      return result;
    } catch (e) {
      debugPrint('⚠️ Spin failed: $e');
      state = state.copyWith(
        isSpinning: false,
        errorMessage: 'Something went wrong. Try spinning again.',
      );
      return null;
    }
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedSpot: true, clearError: true);
  }
}

final rouletteProvider = StateNotifierProvider<RouletteNotifier, RouletteState>(
  (ref) {
    return RouletteNotifier(ref.read(rouletteServiceProvider));
  },
);
