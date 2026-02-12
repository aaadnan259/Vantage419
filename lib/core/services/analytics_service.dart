import 'package:flutter/foundation.dart';

/// Analytics abstraction — swap to Firebase Analytics when ready.
/// For now, logs events to debug console so we can verify event flow.
class AnalyticsService {
  /// Log a named event with optional parameters.
  void logEvent(String name, [Map<String, Object>? params]) {
    debugPrint('📊 Analytics: $name ${params ?? ''}');
    // TODO: FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }

  /// Track screen views for funnel analysis.
  void logScreenView(String screenName) {
    debugPrint('📊 Screen: $screenName');
    // TODO: FirebaseAnalytics.instance.setCurrentScreen(screenName: screenName);
  }
}
