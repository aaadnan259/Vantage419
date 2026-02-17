import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/models/user_visit.dart';

// Top-level function for compute
String _encodeVisits(List<Map<String, dynamic>> visitsJson) {
  return jsonEncode(visitsJson);
}

void main() {
  test('Benchmark: JSON encoding performance', () async {
    const int count = 500; // maxVisits from source code
    final visits = List.generate(
      count,
      (index) => UserVisit(
        spotId: 'spot_$index',
        visitedAt: DateTime.now().subtract(Duration(minutes: index)),
        rating: index % 5 + 1,
      ),
    );

    // Baseline: Main thread encoding
    final stopwatch = Stopwatch()..start();
    final json = jsonEncode(visits.map((v) => v.toJson()).toList());
    stopwatch.stop();
    // ignore: avoid_print
    print('Baseline (Main Thread): ${stopwatch.elapsedMicroseconds} µs');

    // Optimization: Compute
    final stopwatchCompute = Stopwatch()..start();
    final visitsJson = visits.map((v) => v.toJson()).toList();
    final jsonCompute = await compute(_encodeVisits, visitsJson);
    stopwatchCompute.stop();
    // ignore: avoid_print
    print('Optimization (Compute): ${stopwatchCompute.elapsedMicroseconds} µs');

    expect(json, equals(jsonCompute));
  });
}
