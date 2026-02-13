import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/services/performance_service.dart';

void main() {
  group('PerformanceService', () {
    test('startTrace returns a Trace object', () {
      final service = PerformanceService();
      final trace = service.startTrace('test_trace');
      expect(trace, isA<Trace>());
      trace.stop();
    });

    test('Trace lifecycle runs without error', () {
      final service = PerformanceService();
      final trace = service.startTrace('lifecycle_trace');

      expect(() => trace.setMetric('items_loaded', 10), returnsNormally);
      expect(() => trace.stop(), returnsNormally);
    });
  });
}
