import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/models/roulette_mode.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/services/roulette_service.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/core/utils/constants.dart';
import 'package:vantage419/features/profile/gamification_provider.dart';

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
/// Migrated from StateNotifier to Notifier (Riverpod 2.x).
class RouletteNotifier extends Notifier<RouletteState> {
  @override
  RouletteState build() {
    _init();
    return const RouletteState();
  }

  Future<void> _init() async {
    try {
      final repository = ref.read(spotRepositoryProvider);
      final visits = await repository.getVisits();
      state = state.copyWith(visits: visits);
    } catch (e) {
      debugPrint('⚠️ Failed to load visits: $e');
    }
  }

  void selectMode(int index) {
    if (index < 0 || index >= RouletteMode.modes.length) return;

    final newMode = RouletteMode.modes[index];
    ref.read(analyticsProvider).logModeChange(newMode.displayName);

    state = state.copyWith(
      currentMode: index,
      clearSelectedSpot: true,
      clearError: true,
    );
  }

  /// Spin the roulette using data from Repository.
  Future<ToledoSpot?> spin() async {
    if (state.isSpinning) return null;

    state = state.copyWith(
      isSpinning: true,
      clearSelectedSpot: true,
      clearError: true,
    );

    try {
      final analytics = ref.read(analyticsProvider);
      final repository = ref.read(spotRepositoryProvider);
      final service = ref.read(rouletteServiceProvider);

      analytics.logSpinStart(state.mode.displayName); // ignore: unawaited_futures

      // S3.2: Fetch data from Repository (Abstracted Source)
      final spots = await repository.getSpots();
      final visits = await repository.getVisits();

      // Artificial delay for suspense
      await Future.delayed(AppConstants.spinDuration);

      final result = service.spin(
        pool: spots
            .where((s) => state.mode.categories.contains(s.category))
            .toList(),
        visits: visits,
      );

      if (result != null) {
        analytics.logSpinComplete(result.id, result.name); // ignore: unawaited_futures
        final updatedVisits = await repository.logVisit(result.id, visits);

        // Update gamification streak
        ref.read(gamificationProvider.notifier).recordSpin();

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

final rouletteProvider = NotifierProvider<RouletteNotifier, RouletteState>(
  RouletteNotifier.new,
);
