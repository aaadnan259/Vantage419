import 'package:flutter/material.dart';
import 'package:vantage419/core/theme/palette.dart';

/// Convenience extensions.
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mq => MediaQuery.of(this);
  double get screenWidth => mq.size.width;
  double get screenHeight => mq.size.height;

  /// S7.5: Access the current theme's VantagePalette.
  /// Usage: `context.colors.surface`
  VantagePalette get colors =>
      Theme.of(this).extension<VantagePalette>() ?? VantagePalette.dark;
}

extension ColorX on Color {
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
