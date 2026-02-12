import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/roulette_mode.dart';
import '../../../core/models/toledo_spot.dart';
import '../../../core/models/user_visit.dart';
import '../../../core/repositories/spot_repository.dart';
import '../../../core/services/roulette_service.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/utils/constants.dart';

/// Pure logic service provider.
final rouletteServiceProvider = Provider<RouletteService>((ref) {
  return RouletteService();
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

  /// S3.3: Bounds-checked mode getter.
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
  RouletteNotifier(this._repository, this._service)
    : super(const RouletteState()) {
    _init();
  }

  final SpotRepository _repository;
  final RouletteService _service;

  Future<void> _init() async {
    try {
      final visits = await _repository.getVisits();
      if (!mounted) return;
      state = state.copyWith(visits: visits);
    } catch (e) {
      debugPrint('⚠️ Failed to load visits: $e');
      // Non-fatal — app works with empty visit history
    }
  }

  void selectMode(int index) {
    if (index < 0 || index >= RouletteMode.modes.length) return;
    state = state.copyWith(
      currentMode: index,
      clearSelectedSpot: true,
      clearError: true,
    );
  }

  /// Spin the roulette using data from Reservoir.
  Future<ToledoSpot?> spin() async {
    if (state.isSpinning) return null;

    state = state.copyWith(
      isSpinning: true,
      clearSelectedSpot: true,
      clearError: true,
    );

    try {
      // S3.2: Fetch data from Repository (Abstracted Source)
      // This allows moving to Supabase later without changing this logic.
      final spots = await _repository.getSpots();
      // Ensure local state is fresh
      final visits = await _repository.getVisits();

      // Artificial delay for suspense
      await Future.delayed(AppConstants.spinDuration);

      final result = _service.spin(
        spots: spots,
        pool: spots
            .where((s) => state.mode.categories.contains(s.category))
            .toList(),
        visits: visits,
      );

      if (result != null) {
        final updatedVisits = await _repository.logVisit(result.id, visits);
        if (!mounted) return null;

        state = state.copyWith(
          isSpinning: false,
          selectedSpot: result,
          visits: updatedVisits,
        );
      } else {
        if (!mounted) return null;

        state = state.copyWith(
          isSpinning: false,
          errorMessage:
              "No spots match '${state.mode.displayName}' — try 'Surprise Me'!",
        );
      }

      return result;
    } catch (e) {
      debugPrint('⚠️ Spin failed: $e');
      if (!mounted) return null;

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
    final repository = ref.watch(spotRepositoryProvider);
    final service = ref.watch(rouletteServiceProvider);
    return RouletteNotifier(repository, service);
  },
);
