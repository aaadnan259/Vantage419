import 'package:firebase_performance/firebase_performance.dart' as fp;
import 'package:flutter/foundation.dart';

/// Performance monitoring abstraction.
/// Uses Firebase Performance Monitoring.
class PerformanceService {
  /// Start a trace for a specific operation.
  /// Returns a [Trace] object that must be stopped.
  Trace startTrace(String name) {
    debugPrint('⏱️ Performance: Trace started - $name');

    fp.FirebasePerformance? performance;
    try {
      performance = fp.FirebasePerformance.instance;
    } catch (e) {
      // Firebase likely not initialized, proceed with debug trace only
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

  void stop() {
    _stopwatch.stop();
    debugPrint(
      '⏱️ Performance: Trace stopped - $name (${_stopwatch.elapsedMilliseconds}ms)',
    );
    // Fire-and-forget async stop
    fpTrace?.stop();
  }

  void setMetric(String metricName, int value) {
    debugPrint('⏱️ Performance: Metric $name.$metricName = $value');
    fpTrace?.setMetric(metricName, value);
  }
}
