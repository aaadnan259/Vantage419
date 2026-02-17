import 'package:firebase_performance/firebase_performance.dart'
    as firebase_performance;
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/services/performance_service.dart';

class ManualMockFirebasePerformance
    implements firebase_performance.FirebasePerformance {
  String? lastTraceName;
  ManualMockTrace? lastTrace;

  @override
  firebase_performance.Trace newTrace(String name) {
    lastTraceName = name;
    lastTrace = ManualMockTrace();
    return lastTrace!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ManualMockTrace implements firebase_performance.Trace {
  bool started = false;
  bool stopped = false;
  Map<String, int> metrics = {};

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  void setMetric(String name, int value) {
    metrics[name] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PerformanceService', () {
    late PerformanceService service;
    late ManualMockFirebasePerformance mockPerformance;

    setUp(() {
      mockPerformance = ManualMockFirebasePerformance();
      service = PerformanceService(performance: mockPerformance);
    });

    test('startTrace returns a Trace object and starts firebase trace', () {
      final trace = service.startTrace('test_trace');
      expect(trace, isA<Trace>());
      expect(mockPerformance.lastTraceName, 'test_trace');
      expect(mockPerformance.lastTrace?.started, isTrue);
    });

    test('Trace lifecycle updates metrics and stops firebase trace', () {
      final trace = service.startTrace('lifecycle_trace');
      final mockTrace = mockPerformance.lastTrace!;

      trace.setMetric('items_loaded', 10);
      expect(mockTrace.metrics['items_loaded'], 10);

      trace.stop();
      expect(mockTrace.stopped, isTrue);
    });
  });
}
