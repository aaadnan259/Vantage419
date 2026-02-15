import 'package:firebase_performance/firebase_performance.dart' as firebase_performance;
import 'package:flutter/foundation.dart';

/// Performance monitoring abstraction.
class PerformanceService {
  final firebase_performance.FirebasePerformance _performance;

  /// Creates a [PerformanceService].
  /// An optional [firebase_performance.FirebasePerformance] instance can be provided for testing.
  PerformanceService({firebase_performance.FirebasePerformance? performance})
      : _performance =
            performance ?? firebase_performance.FirebasePerformance.instance;

  /// Start a trace for a specific operation.
  /// Returns a [Trace] object that must be stopped.
  Trace startTrace(String name) {
    debugPrint('⏱️ Performance: Trace started - $name');
    final firebaseTrace = _performance.newTrace(name);
    // Fire and forget start() to keep API synchronous and avoid latency
    firebaseTrace.start();
    return Trace(name, firebaseTrace);
  }
}

/// Represents a performance trace.
class Trace {
  Trace(this.name, this._firebaseTrace);

  final String name;
  final firebase_performance.Trace _firebaseTrace;
  final Stopwatch _stopwatch = Stopwatch()..start();

  /// Stop the trace.
  void stop() {
    _stopwatch.stop();
    // Fire and forget stop() to keep API synchronous and avoid latency
    _firebaseTrace.stop();
    debugPrint(
      '⏱️ Performance: Trace stopped - $name (${_stopwatch.elapsedMilliseconds}ms)',
    );
  }

  /// Set a metric for the trace.
  void setMetric(String metricName, int value) {
    debugPrint('⏱️ Performance: Metric $name.$metricName = $value');
    _firebaseTrace.setMetric(metricName, value);
  }
}
