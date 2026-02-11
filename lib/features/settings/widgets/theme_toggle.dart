import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/extensions.dart';

/// Floating button to toggle between System, Light, and Dark themes.
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final nextMode = _nextMode(themeMode);
          ref.read(themeProvider.notifier).setThemeMode(nextMode);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.textMuted.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getIcon(themeMode),
            color: context.colors.textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  ThemeMode _nextMode(ThemeMode current) {
    switch (current) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }

  IconData _getIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }
}
