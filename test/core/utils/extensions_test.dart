import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/core/utils/extensions.dart';

void main() {
  group('Distance Utils', () {
    test('distanceMiles calculates distance between two points correctly', () {
      // Toledo, OH (approx)
      const toledo = LatLng(41.6528, -83.5379);
      // Detroit, MI (approx)
      const detroit = LatLng(42.3314, -83.0458);

      final distance = distanceMiles(toledo, detroit);

      // Distance is roughly 53-55 miles
      expect(distance, closeTo(54.0, 2.0));
    });

    test('distanceMiles returns 0 for same point', () {
      const point = LatLng(41.6528, -83.5379);
      expect(distanceMiles(point, point), equals(0.0));
    });

    test('formatDistance formats values < 10 with 1 decimal place', () {
      expect(formatDistance(0.3), '0.3 mi');
      expect(formatDistance(5.5), '5.5 mi');
      expect(formatDistance(9.9), '9.9 mi');
      expect(formatDistance(0.0), '0.0 mi');
    });

    test('formatDistance formats values >= 10 as rounded integer', () {
      expect(formatDistance(10.0), '10 mi');
      expect(formatDistance(10.4), '10 mi');
      expect(formatDistance(10.5), '11 mi'); // Rounding behavior
      expect(formatDistance(12.8), '13 mi');
      expect(formatDistance(100.2), '100 mi');
    });
  });

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
