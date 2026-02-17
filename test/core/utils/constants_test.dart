import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/utils/constants.dart';

void main() {
  group('AppConstants Navigation', () {
    test('googleNavScheme formatting works correctly', () {
      const lat = 41.6528;
      const lng = -83.5379;
      final url = AppConstants.googleNavScheme
          .replaceAll('{lat}', lat.toString())
          .replaceAll('{lng}', lng.toString());

      expect(url, 'google.navigation:q=41.6528,-83.5379&mode=d');
    });

    test('wazeNavScheme formatting works correctly', () {
      const lat = 41.6528;
      const lng = -83.5379;
      final url = AppConstants.wazeNavScheme
          .replaceAll('{lat}', lat.toString())
          .replaceAll('{lng}', lng.toString());

      expect(url, 'https://waze.com/ul?ll=41.6528,-83.5379&navigate=yes');
    });

    test('googleWebNavScheme formatting works correctly', () {
      const lat = 41.6528;
      const lng = -83.5379;
      final url = AppConstants.googleWebNavScheme
          .replaceAll('{lat}', lat.toString())
          .replaceAll('{lng}', lng.toString());

      expect(url, 'https://www.google.com/maps/dir/?api=1&destination=41.6528,-83.5379');
    });
  });
}
