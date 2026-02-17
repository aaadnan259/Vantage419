import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics abstraction — swap to Firebase Analytics when ready.
/// For now, logs events to debug console so we can verify event flow.
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService([FirebaseAnalytics? analytics])
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Log a named event with optional parameters.
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    debugPrint('📊 Analytics: $name ${params ?? ''}');
    await _analytics.logEvent(name: name, parameters: params);
  }

  /// Track screen views for funnel analysis.
  Future<void> logScreenView(String screenName) async {
    debugPrint('📊 Screen: $screenName');
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logSpinStart(String mode) async {
    await logEvent('spin_start', {'mode': mode});
  }

  Future<void> logSpinComplete(String spotId, String spotName) async {
    await logEvent(
      'spin_complete',
      {'spot_id': spotId, 'spot_name': spotName},
    );
  }

  Future<void> logModeChange(String mode) async {
    await logEvent('mode_change', {'mode': mode});
  }
}
