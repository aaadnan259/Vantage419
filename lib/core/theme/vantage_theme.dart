import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Assembles the complete Vantage Dark theme.
abstract final class VantageTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: VantageColors.primaryBackground,
    colorScheme: const ColorScheme.dark(
      primary: VantageColors.accent,
      onPrimary: VantageColors.textPrimary,
      secondary: VantageColors.accentLight,
      surface: VantageColors.surface,
      onSurface: VantageColors.textPrimary,
      error: VantageColors.error,
    ),
    textTheme: VantageTypography.textTheme.apply(
      bodyColor: VantageColors.textPrimary,
      displayColor: VantageColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: VantageColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: VantageColors.accent,
      foregroundColor: VantageColors.textPrimary,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: VantageColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
