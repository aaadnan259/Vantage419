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

    test('logError runs without error', () {
      expect(
        () => service.logError(Exception('Test error'), StackTrace.current),
        returnsNormally,
      );
    });

    test('logError runs without error with fatal flag', () {
      expect(
        () => service.logError(Exception('Fatal error'), StackTrace.current, fatal: true),
        returnsNormally,
      );
    });
  });
  test('logSpinStart runs without error', () {
    final service = AnalyticsService();
    expect(() => service.logSpinStart('Solo Dining'), returnsNormally);
  });

  test('logSpinComplete runs without error', () {
    final service = AnalyticsService();
    expect(
      () => service.logSpinComplete('spot_123', 'Test Spot'),
      returnsNormally,
    );
  });

  test('logModeChange runs without error', () {
    final service = AnalyticsService();
    expect(() => service.logModeChange('Date Night'), returnsNormally);
  });
}
