import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service to get current time. Mockable for tests.
class ClockService {
  /// Returns the current time.
  DateTime now() => DateTime.now();
}

/// Provider for [ClockService].
final clockServiceProvider = Provider<ClockService>((ref) {
  return ClockService();
});
