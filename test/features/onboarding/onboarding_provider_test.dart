import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/features/onboarding/onboarding_provider.dart';

void main() {
  group('OnboardingProvider', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('shows onboarding on fresh install', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(showOnboardingProvider), isTrue);
    });

    test('hides onboarding after completion', () async {
      final prefs = await SharedPreferences.getInstance();
      await completeOnboarding(prefs);

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(showOnboardingProvider), isFalse);
    });
  });
}
