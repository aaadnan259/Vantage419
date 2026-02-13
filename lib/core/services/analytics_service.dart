import 'package:flutter/foundation.dart';

/// Analytics abstraction — swap to Firebase Analytics when ready.
/// For now, logs events to debug console so we can verify event flow.
class AnalyticsService {
  /// Log a named event with optional parameters.
  void logEvent(String name, [Map<String, Object>? params]) {
    debugPrint('📊 Analytics: $name ${params ?? ''}');
    // Swap: FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }

  /// Track screen views for funnel analysis.
  void logScreenView(String screenName) {
    debugPrint('📊 Screen: $screenName');
    // Swap: FirebaseAnalytics.instance.setCurrentScreen(screenName: screenName);
  }

  void logSpinStart(String mode) {
    logEvent('spin_start', {'mode': mode});
  }

  void logSpinComplete(String spotId, String spotName) {
    logEvent('spin_complete', {'spot_id': spotId, 'spot_name': spotName});
  }

  void logModeChange(String mode) {
    logEvent('mode_change', {'mode': mode});
  }
}
