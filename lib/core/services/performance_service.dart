import 'package:flutter/foundation.dart';

/// Performance monitoring abstraction.
/// Swap to Firebase Performance Monitoring when ready.
class PerformanceService {
  /// Start a trace for a specific operation.
  /// Returns a [Trace] object that must be stopped.
  Trace startTrace(String name) {
    debugPrint('⏱️ Performance: Trace started - $name');
    final trace = Trace(name);
    // Swap: final trace = FirebasePerformance.instance.newTrace(name);
    // Swap: await trace.start();
    trace.start();
    return trace;
  }
}

/// Represents a performance trace.
class Trace {
  Trace(this.name);

  final String name;
  final Stopwatch _stopwatch = Stopwatch();

  void start() {
    _stopwatch.start();
  }

  void stop() {
    _stopwatch.stop();
    debugPrint(
      '⏱️ Performance: Trace stopped - $name (${_stopwatch.elapsedMilliseconds}ms)',
    );
    // Swap: await firebaseTrace.stop();
  }

  void setMetric(String metricName, int value) {
    debugPrint('⏱️ Performance: Metric $name.$metricName = $value');
    // Swap: firebaseTrace.setMetric(metricName, value);
  }
}
