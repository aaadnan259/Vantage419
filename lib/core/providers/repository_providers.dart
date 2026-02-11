import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data_sources/spot_local_data_source.dart';
import '../repositories/spot_repository.dart';
import '../repositories/spot_repository_impl.dart';

/// Core provider for SharedPreferences (Overridden in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main with ProviderScope');
});

/// S3.2.1: Data Source Provider
final spotLocalDataSourceProvider = Provider<SpotLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SpotLocalDataSource(prefs);
});

/// S3.2.1: Repository Provider (Single Source of Truth)
final spotRepositoryProvider = Provider<SpotRepository>((ref) {
  final dataSource = ref.watch(spotLocalDataSourceProvider);
  return SpotRepositoryImpl(dataSource);
});
