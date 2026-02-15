import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/providers/repository_providers.dart';

/// Provides the list of user visits from the repository.
/// Acts as the single source of truth for visits.
final visitsProvider = AsyncNotifierProvider<VisitsNotifier, List<UserVisit>>(
  VisitsNotifier.new,
);

class VisitsNotifier extends AsyncNotifier<List<UserVisit>> {
  @override
  FutureOr<List<UserVisit>> build() async {
    // Watch repository so if repository implementation changes, we rebuild (unlikely but correct)
    final repository = ref.watch(spotRepositoryProvider);
    return repository.getVisits();
  }

  /// Refreshes the visits list.
  /// Call this when visits are modified externally (e.g., by RouletteNotifier).
  Future<void> refresh() async {
    // We invalidate self which triggers build() again
    ref.invalidateSelf();
    await future;
  }
}
