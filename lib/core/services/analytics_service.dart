import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics abstraction using Firebase Analytics.
/// Logs events to debug console and sends them to Firebase.
class AnalyticsService {
  final FirebaseAnalytics? _analytics;

  /// Creates an [AnalyticsService].
  ///
  /// If [analytics] is provided, events will be sent to Firebase.
  /// Otherwise, events are only logged to the debug console (useful for testing).
  AnalyticsService([this._analytics]);

  /// Log a named event with optional parameters.
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: $name ${params ?? ''}');
    }
    await _analytics?.logEvent(name: name, parameters: params);
  }

  /// Track screen views for funnel analysis.
  Future<void> logScreenView(String screenName) async {
    if (kDebugMode) {
      debugPrint('📊 Screen: $screenName');
    }
    await _analytics?.logScreenView(screenName: screenName);
  }

  /// Log errors to analytics (Crashlytics).
  void logError(dynamic error, StackTrace? stackTrace, {bool fatal = false}) {
    if (kDebugMode) {
      debugPrint('🔴 Analytics Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack: $stackTrace');
      }
    }
    // Swap: FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: fatal);
  }

  Future<void> logSpinStart(String mode) async {
    await logEvent('spin_start', {'mode': mode});
  }

  Future<void> logSpinComplete(String spotId, String spotName) async {
    await logEvent('spin_complete', {'spot_id': spotId, 'spot_name': spotName});
  }

  Future<void> logModeChange(String mode) async {
    await logEvent('mode_change', {'mode': mode});
  }
}
