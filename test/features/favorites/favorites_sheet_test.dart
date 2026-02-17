import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/core.dart';
import 'package:vantage419/core/theme/palette.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/features/favorites/favorites_sheet.dart';
import 'package:vantage419/features/favorites/favorites_provider.dart';

class MockFavoritesNotifier extends FavoritesNotifier {
  MockFavoritesNotifier(this.initialValue);
  final Set<String> initialValue;

  @override
  Set<String> build() {
    // We can't easily override _persist because it's private in the base class.
    // However, since we are overriding build(), the initial state will be correct.
    // The base toggle() method will call _persist(), which will try to use
    // sharedPreferencesProvider. We should ensure that provider is also overridden
    // or handled to avoid errors, even if we don't check its result.
    return initialValue;
  }
}

void main() {
  const spot1 = ToledoSpot(
    id: 'spot-1',
    name: 'Test Spot 1',
    latitude: 41.65,
    longitude: -83.53,
    category: SpotCategory.dining,
    vibeCheck: 'Chill',
    description: 'A nice place to eat.',
  );

  const spot2 = ToledoSpot(
    id: 'spot-2',
    name: 'Test Spot 2',
    latitude: 41.66,
    longitude: -83.54,
    category: SpotCategory.recreation,
    vibeCheck: 'Active',
    description: 'A fun place to play.',
  );

  final allSpots = [spot1, spot2];

  Widget buildTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData(
          extensions: const [
            VantagePalette.light,
          ],
        ),
        home: Scaffold(
          body: FavoritesSheet(allSpots: allSpots),
        ),
      ),
    );
  }

  group('FavoritesSheet', () {
    testWidgets('shows empty state when no favorites exist',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          favoritesProvider.overrideWith(() => MockFavoritesNotifier({})),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('No favorites yet'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('shows list of favorites when favorites exist',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          favoritesProvider.overrideWith(() => MockFavoritesNotifier({'spot-1'})),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      // Verify header count
      expect(find.text('1'), findsOneWidget);

      // Verify list content
      expect(find.text('Test Spot 1'), findsOneWidget);
      expect(find.text('Dining'), findsOneWidget);

      // Verify other spot is not shown
      expect(find.text('Test Spot 2'), findsNothing);
    });

    testWidgets('tapping favorite icon removes item from list',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          favoritesProvider.overrideWith(() => MockFavoritesNotifier({'spot-1'})),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Test Spot 1'), findsOneWidget);

      // Tap the favorite icon
      // We need to find the specific icon button in the list tile
      final listTileFinder = find.widgetWithText(ListTile, 'Test Spot 1');
      final favoriteButtonFinder = find.descendant(
        of: listTileFinder,
        matching: find.byType(IconButton),
      );

      await tester.tap(favoriteButtonFinder);
      await tester.pumpAndSettle();

      // Verify item is removed and empty state is shown
      expect(find.text('Test Spot 1'), findsNothing);
      expect(find.text('No favorites yet'), findsOneWidget);
    });
  });
}
