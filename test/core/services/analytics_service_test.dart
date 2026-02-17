import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/services/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  final List<String> logs = [];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    logs.add('logEvent: $name $parameters');
  }

  @override
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    logs.add('logScreenView: $screenName');
  }
}

void main() {
  group('AnalyticsService', () {
    late AnalyticsService service;
    late FakeFirebaseAnalytics fakeAnalytics;

    setUp(() {
      fakeAnalytics = FakeFirebaseAnalytics();
      service = AnalyticsService(fakeAnalytics);
    });

    test('logEvent calls firebase analytics', () async {
      await service.logEvent('test_event', {'key': 'value'});
      expect(fakeAnalytics.logs, contains('logEvent: test_event {key: value}'));
    });

    test('logEvent works with no params', () async {
      await service.logEvent('test_event');
      expect(fakeAnalytics.logs, contains('logEvent: test_event null'));
    });

    test('logScreenView calls firebase analytics', () async {
      await service.logScreenView('MapScreen');
      expect(fakeAnalytics.logs, contains('logScreenView: MapScreen'));
    });

    test('logSpinStart calls logEvent', () async {
      await service.logSpinStart('Solo Dining');
      // Allow async execution to complete
      await Future.delayed(Duration.zero);
      expect(
        fakeAnalytics.logs,
        contains('logEvent: spin_start {mode: Solo Dining}'),
      );
    });

    test('logSpinComplete calls logEvent', () async {
      await service.logSpinComplete('spot_123', 'Test Spot');
      await Future.delayed(Duration.zero);
      expect(
        fakeAnalytics.logs,
        contains(
          'logEvent: spin_complete {spot_id: spot_123, spot_name: Test Spot}',
        ),
      );
    });

    test('logModeChange calls logEvent', () async {
      await service.logModeChange('Date Night');
      await Future.delayed(Duration.zero);
      expect(
        fakeAnalytics.logs,
        contains('logEvent: mode_change {mode: Date Night}'),
      );
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
        () => service.logError(
          Exception('Fatal error'),
          StackTrace.current,
          fatal: true,
        ),
        returnsNormally,
      );
    });
  });

  test('logSpinStart runs without error with null analytics', () async {
    final service = AnalyticsService();
    await expectLater(service.logSpinStart('Solo Dining'), completes);
  });

  test('logSpinComplete runs without error with null analytics', () async {
    final service = AnalyticsService();
    await expectLater(
      service.logSpinComplete('spot_123', 'Test Spot'),
      completes,
    );
  });

  test('logModeChange runs without error with null analytics', () async {
    final service = AnalyticsService();
    await expectLater(service.logModeChange('Date Night'), completes);
  });
}
