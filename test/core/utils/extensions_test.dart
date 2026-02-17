import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/utils/extensions.dart';

void main() {
  group('ColorX', () {
    test('darken should darken color by default amount (0.1)', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        0.0,
        0.0,
        0.5,
      ).toColor(); // Lightness 0.5
      final darkened = color.darken();
      final hslDarkened = HSLColor.fromColor(darkened);

      expect(hslDarkened.lightness, closeTo(0.4, 0.01));
    });

    test('darken should darken color by specified amount', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        0.0,
        0.0,
        0.5,
      ).toColor(); // Lightness 0.5
      final darkened = color.darken(0.2);
      final hslDarkened = HSLColor.fromColor(darkened);

      expect(hslDarkened.lightness, closeTo(0.3, 0.01));
    });

    test('darken should clamp lightness at 0.0', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        0.0,
        0.0,
        0.05,
      ).toColor(); // Lightness 0.05
      final darkened = color.darken(0.1); // Would be -0.05
      final hslDarkened = HSLColor.fromColor(darkened);

      expect(hslDarkened.lightness, closeTo(0.0, 0.01));
    });

    test('lighten should lighten color by default amount (0.1)', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        0.0,
        0.0,
        0.5,
      ).toColor(); // Lightness 0.5
      final lightened = color.lighten();
      final hslLightened = HSLColor.fromColor(lightened);

      expect(hslLightened.lightness, closeTo(0.6, 0.01));
    });

    test('lighten should lighten color by specified amount', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        0.0,
        0.0,
        0.5,
      ).toColor(); // Lightness 0.5
      final lightened = color.lighten(0.2);
      final hslLightened = HSLColor.fromColor(lightened);

      expect(hslLightened.lightness, closeTo(0.7, 0.01));
    });

    test('lighten should clamp lightness at 1.0', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        0.0,
        0.0,
        0.95,
      ).toColor(); // Lightness 0.95
      final lightened = color.lighten(0.1); // Would be 1.05
      final hslLightened = HSLColor.fromColor(lightened);

      expect(hslLightened.lightness, closeTo(1.0, 0.01));
    });
  });
}
