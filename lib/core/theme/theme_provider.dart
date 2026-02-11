import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/roulette/providers/roulette_state_provider.dart';

/// S7.3: Manages the active theme mode (System/Light/Dark) with persistence.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  final SharedPreferences _prefs;
  static const _themeKey = 'app_theme_mode';

  void _loadTheme() {
    final saved = _prefs.getString(_themeKey);
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeKey, mode.name);
  }

  void toggle() {
    // S7.6: Simple toggle logic (skips system for now if toggling manually)
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
