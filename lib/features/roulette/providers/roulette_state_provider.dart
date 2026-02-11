import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  RouletteMode get mode => RouletteMode.modes[currentMode];

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
    _loadVisits();
  }

  final RouletteService _service;

  void _loadVisits() {
    state = state.copyWith(visits: _service.loadVisits());
  }

  void selectMode(int index) {
    state = state.copyWith(
      currentMode: index,
      clearSelectedSpot: true,
      clearError: true,
    );
  }

  /// Spin the roulette — returns the selected spot or null.
  /// Wrapped in try/catch/finally so the button NEVER locks up.
  Future<ToledoSpot?> spin() async {
    if (state.isSpinning) return null;

    state = state.copyWith(
      isSpinning: true,
      clearSelectedSpot: true,
      clearError: true,
    );

    try {
      // Simulate spin delay for animation
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
        // No spots match the current mode
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
