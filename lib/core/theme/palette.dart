import 'package:flutter/material.dart';

/// S7.1: Semantic color palette extension for Light/Dark mode support.
/// Replaces hardcoded static colors in `VantageColors`.
@immutable
class VantagePalette extends ThemeExtension<VantagePalette> {
  const VantagePalette({
    required this.primaryBackground,
    required this.surface,
    required this.surfaceLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.error,
    required this.success,
    required this.warning,
  });

  // Backgrounds
  final Color primaryBackground;
  final Color surface;
  final Color surfaceLight;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Brand
  final Color accent;
  final Color accentLight;
  final Color accentDark;

  // Status
  final Color error;
  final Color success;
  final Color warning;

  /// S7.2: Dark Mode Palette ("Midnight" - Deep Green & Gold)
  static const dark = VantagePalette(
    primaryBackground: Color(0xFF051907), // Deep Green
    surface: Color(0xFF0A200C), // Slightly lighter green
    surfaceLight: Color(0xFF142B16),
    textPrimary: Color(0xFFE6E6E6),
    textSecondary: Color(0xFFC4C4C4),
    textMuted: Color(0xFF8B95A8),
    accent: Color(0xFFFFD700), // Gold
    accentLight: Color(0xFFFFE66D),
    accentDark: Color(0xFFC6A700),
    error: Color(0xFFF44336),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFB74D),
  );

  /// S7.2: Light Mode Palette ("YummiBite" - Cream & Forest Green)
  static const light = VantagePalette(
    primaryBackground: Color(0xFFFAF7F2), // Cream (Warm, paper-like)
    surface: Color(0xFFFFFFFF), // Pure White
    surfaceLight: Color(0xFFF0EBE0), // Slightly darker cream
    textPrimary: Color(0xFF1A1A1A), // Charcoal
    textSecondary: Color(0xFF4A4A4A), // Graphite
    textMuted: Color(0xFF8C8C8C),
    accent: Color(0xFF7CB342), // Fresh Lime
    accentLight: Color(0xFFAED581),
    accentDark: Color(0xFF2D5016), // Forest Green (Primary Brand)
    error: Color(0xFFD32F2F),
    success: Color(0xFF388E3C),
    warning: Color(0xFFF57C00),
  );

  @override
  VantagePalette copyWith({
    Color? primaryBackground,
    Color? surface,
    Color? surfaceLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentLight,
    Color? accentDark,
    Color? error,
    Color? success,
    Color? warning,
  }) {
    return VantagePalette(
      primaryBackground: primaryBackground ?? this.primaryBackground,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      accentDark: accentDark ?? this.accentDark,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  VantagePalette lerp(ThemeExtension<VantagePalette>? other, double t) {
    if (other is! VantagePalette) return this;
    return VantagePalette(
      primaryBackground: Color.lerp(
        primaryBackground,
        other.primaryBackground,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
