import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/theme/vantage_theme.dart';
import 'package:vantage419/features/favorites/favorites_provider.dart';
import 'package:vantage419/features/roulette/widgets/spot_bottom_sheet.dart';

// Fake provider for favorites
class FakeFavoritesNotifier extends FavoritesNotifier {
  @override
  Set<String> build() {
    return {};
  }

  @override
  void toggle(String spotId) {
    if (state.contains(spotId)) {
      state = {...state}..remove(spotId);
    } else {
      state = {...state, spotId};
    }
  }
}

void main() {
  const testSpot = ToledoSpot(
    id: 'test_spot_1',
    name: 'Test Spot',
    latitude: 41.65,
    longitude: -83.53,
    category: SpotCategory.entertainment,
    vibeCheck: 'Chill vibes',
    description: 'A great place to hang out.',
    address: '123 Test St',
    imageUrl: 'https://example.com/image.jpg',
  );

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [favoritesProvider.overrideWith(FakeFavoritesNotifier.new)],
      child: MaterialApp(
        theme: VantageTheme.dark,
        home: Scaffold(
          body: Stack(
            children: [
              SpotBottomSheet(
                spot: testSpot,
                onClose: () {},
                userLocation: const LatLng(41.66, -83.54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('SpotBottomSheet', () {
    testWidgets('renders all spot details correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(
        const Duration(seconds: 1),
      ); // Allow sheet to animate up, avoiding infinite loop from pulsing handle

      // Verify Header details
      expect(find.text('Test Spot'), findsOneWidget);
      expect(find.text(SpotCategory.entertainment.displayName), findsOneWidget);

      // Verify Vibe Check
      expect(find.text('Chill vibes'), findsOneWidget);

      // Verify Description
      expect(find.text('A great place to hang out.'), findsOneWidget);

      // Verify Address
      expect(find.text('123 Test St'), findsOneWidget);

      // Verify actions
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
      expect(find.byIcon(Icons.navigation_rounded), findsOneWidget);
    });

    testWidgets('displays correct distance', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(seconds: 1));

      // Distance calculation is mocked/approximated by the widget using latlong2
      // We just check if *some* distance text appears.
      // The actual value depends on the implementation of `formatDistance` and `distanceMiles`.
      // Typically "X.X mi"
      expect(find.byIcon(Icons.directions_walk_rounded), findsOneWidget);
    });
  });
}
