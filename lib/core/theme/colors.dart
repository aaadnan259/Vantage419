import 'package:flutter/material.dart';

/// Vantage 419 color palette — dark theme optimized for OLED.
/// Category colors live in SpotCategory enum — that's the single source of truth (S4.2).
abstract final class VantageColors {
  // Backgrounds
  static const primaryBackground = Color(0xFF0A0E14);
  static const surface = Color(0xFF1A1F2E);
  static const surfaceLight = Color(0xFF252B3B);

  // Text
  static const textPrimary = Color(0xFFE6E6E6);
  static const textSecondary = Color(0xFF8B95A8);
  static const textMuted = Color(0xFF5A6475);

  // Brand — Toyota Blue
  static const accent = Color(0xFF0D7ABF);
  static const accentLight = Color(0xFF1A9AE6);
  static const accentDark = Color(0xFF085A8F);

  // Status
  static const error = Color(0xFFF44336);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFB74D);
}
