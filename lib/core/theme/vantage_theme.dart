import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'palette.dart';
import 'typography.dart';

/// Assembles the complete Vantage theme (Light & Dark).
abstract final class VantageTheme {
  /// S7.4: Dark Theme Factory
  static ThemeData get dark {
    final palette = VantagePalette.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.primaryBackground,
      extensions: [palette],
      colorScheme: ColorScheme.dark(
        primary: palette.accent,
        onPrimary: palette.textPrimary,
        secondary: palette.accentLight,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        error: palette.error,
      ),
      textTheme: VantageTypography.textTheme.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: palette.textPrimary,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// S7.4: Light Theme Factory
  static ThemeData get light {
    final palette = VantagePalette.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: palette.primaryBackground,
      extensions: [palette],
      colorScheme: ColorScheme.light(
        primary: palette.accent,
        onPrimary: Colors.white,
        secondary: palette.accentLight,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        error: palette.error,
      ),
      textTheme: VantageTypography.textTheme.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
