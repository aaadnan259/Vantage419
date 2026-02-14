import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/providers/repository_providers.dart';

const _favoritesKey = 'favorite_spot_ids';

/// Provides the set of favorited spot IDs, persisted in SharedPreferences.
/// Migrated to Notifier (Riverpod 2.x).
final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return _load(prefs);
  }

  static Set<String> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_favoritesKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.cast<String>().toSet();
      return {};
    } catch (_) {
      return {};
    }
  }

  void toggle(String spotId) {
    final updated = Set<String>.from(state);
    if (updated.contains(spotId)) {
      updated.remove(spotId);
    } else {
      updated.add(spotId);
    }
    state = updated;
    _persist();
  }

  bool isFavorited(String spotId) => state.contains(spotId);

  Future<void> _persist() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final json = jsonEncode(state.toList());
    await prefs.setString(_favoritesKey, json);
  }
}
