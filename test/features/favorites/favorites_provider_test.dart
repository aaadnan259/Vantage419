import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/features/favorites/favorites_provider.dart';

void main() {
  group('FavoritesNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    test('starts empty', () {
      final favorites = container.read(favoritesProvider);
      expect(favorites, isEmpty);
    });

    test('toggle adds a spot', () {
      container.read(favoritesProvider.notifier).toggle('spot-1');
      expect(container.read(favoritesProvider), contains('spot-1'));
    });

    test('toggle removes an already-favorited spot', () {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('spot-1');
      expect(container.read(favoritesProvider), contains('spot-1'));

      notifier.toggle('spot-1');
      expect(container.read(favoritesProvider), isNot(contains('spot-1')));
    });

    test('isFavorited reflects state', () {
      final notifier = container.read(favoritesProvider.notifier);
      expect(notifier.isFavorited('spot-2'), isFalse);

      notifier.toggle('spot-2');
      expect(notifier.isFavorited('spot-2'), isTrue);
    });

    test('multiple items can be favorited', () {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('spot-1');
      notifier.toggle('spot-2');
      notifier.toggle('spot-3');

      final favorites = container.read(favoritesProvider);
      expect(favorites.length, 3);
      expect(favorites, containsAll(['spot-1', 'spot-2', 'spot-3']));
    });

    test('persists to SharedPreferences', () async {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('spot-persist');

      // Allow async persist to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Create new container with same prefs to verify persistence
      final prefs = await SharedPreferences.getInstance();
      final container2 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container2.dispose);

      final restored = container2.read(favoritesProvider);
      expect(restored, contains('spot-persist'));
    });
  });
}
