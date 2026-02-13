import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/services/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService service;

    setUp(() {
      service = AnalyticsService();
    });

    test('logEvent runs without error', () {
      // Should not throw — just prints in debug mode
      expect(
        () => service.logEvent('test_event', {'key': 'value'}),
        returnsNormally,
      );
    });

    test('logEvent works with no params', () {
      expect(() => service.logEvent('test_event'), returnsNormally);
    });

    test('logScreenView runs without error', () {
      expect(() => service.logScreenView('MapScreen'), returnsNormally);
    });
  });
}
