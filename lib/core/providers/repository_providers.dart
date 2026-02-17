import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/data_sources/spot_local_data_source.dart';
import 'package:vantage419/core/repositories/spot_repository.dart';
import 'package:vantage419/core/repositories/spot_repository_impl.dart';
import 'package:vantage419/core/services/analytics_service.dart';
import 'package:vantage419/core/services/performance_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Core provider for SharedPreferences (Overridden in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main with ProviderScope');
});

/// S3.2.1: Data Source Provider
final spotLocalDataSourceProvider = Provider<SpotLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final performance = ref.watch(performanceProvider);
  return SpotLocalDataSource(prefs, performance);
});

/// S3.2.1: Repository Provider (Single Source of Truth)
final spotRepositoryProvider = Provider<SpotRepository>((ref) {
  final dataSource = ref.watch(spotLocalDataSourceProvider);
  return SpotRepositoryImpl(dataSource);
});

/// Analytics service — swap to Firebase-backed implementation later
final analyticsProvider = Provider<AnalyticsService>((ref) {
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    return AnalyticsService(FirebaseAnalytics.instance);
  }
  return AnalyticsService();
});

/// Performance service — swap to Firebase-backed implementation later
final performanceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});
