import 'package:firebase_performance/firebase_performance.dart' as fp;
import 'package:flutter/foundation.dart';

/// Performance monitoring abstraction.
/// Uses Firebase Performance Monitoring.
class PerformanceService {
  final fp.FirebasePerformance? _performance;

  /// Creates a [PerformanceService].
  /// An optional [fp.FirebasePerformance] instance can be provided for testing.
  PerformanceService({fp.FirebasePerformance? performance})
    : _performance = performance;

  /// Start a trace for a specific operation.
  /// Returns a [Trace] object that must be stopped.
  Trace startTrace(String name) {
    if (kDebugMode) {
      debugPrint('⏱️ Performance: Trace started - $name');
    }

    fp.FirebasePerformance? performance = _performance;
    if (performance == null) {
      try {
        performance = fp.FirebasePerformance.instance;
      } catch (e) {
        // Firebase likely not initialized, proceed with debug trace only
      }
    }

    final fpTrace = performance?.newTrace(name);
    // Fire-and-forget async start to keep API synchronous
    fpTrace?.start();

    final trace = Trace(name, fpTrace: fpTrace);
    trace.start();
    return trace;
  }
}

/// Represents a performance trace.
class Trace {
  Trace(this.name, {this.fpTrace});

  final String name;
  final fp.Trace? fpTrace;
  final Stopwatch _stopwatch = Stopwatch();

  void start() {
    _stopwatch.start();
  }

  /// Stop the trace.
  void stop() {
    _stopwatch.stop();
    if (kDebugMode) {
      debugPrint(
        '⏱️ Performance: Trace stopped - $name (${_stopwatch.elapsedMilliseconds}ms)',
      );
    }
    // Fire-and-forget async stop
    fpTrace?.stop();
  }

  /// Set a metric for the trace.
  void setMetric(String metricName, int value) {
    if (kDebugMode) {
      debugPrint('⏱️ Performance: Metric $name.$metricName = $value');
    }
    fpTrace?.setMetric(metricName, value);
  }
}
