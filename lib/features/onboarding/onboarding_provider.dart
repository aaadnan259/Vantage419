import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/providers/repository_providers.dart';

const _onboardingKey = 'onboarding_completed';

/// Whether the user has completed onboarding.
/// Returns `true` on first install, `false` after onboarding is done.
final showOnboardingProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return !(prefs.getBool(_onboardingKey) ?? false);
});

/// Marks onboarding as completed in SharedPreferences.
Future<void> completeOnboarding(SharedPreferences prefs) async {
  await prefs.setBool(_onboardingKey, true);
}
