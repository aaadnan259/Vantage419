import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/theme/vantage_theme.dart';
import 'package:vantage419/features/profile/gamification_provider.dart';
import 'package:vantage419/features/profile/profile_sheet.dart';

void main() {
  group('ProfileSheet', () {
    const testStreak = 5;
    const testStats = DiscoveryStats(
      totalSpots: 10,
      discoveredCount: 4,
      categoryProgress: {
        SpotCategory.dining: CategoryProgress(discovered: 2, total: 5), // 40%
        SpotCategory.nightlife: CategoryProgress(
          discovered: 2,
          total: 2,
        ), // 100%
      },
    );

    testWidgets('renders streak and discovery stats correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gamificationProvider.overrideWith(
              () => FakeGamificationNotifier(testStreak),
            ),
            discoveryStatsProvider.overrideWithValue(testStats),
          ],
          child: MaterialApp(
            theme: VantageTheme.dark,
            home: const Material(child: ProfileSheet()),
          ),
        ),
      );

      // Verify Streak Card
      expect(find.text('Spin Streak'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('5 days'), findsOneWidget);

      // Verify Discovery Card
      expect(find.text('Discovered'), findsOneWidget);
      expect(find.text('4/10'), findsOneWidget);
      expect(find.text('40% explored'), findsOneWidget);
    });

    testWidgets('renders category progress bars', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gamificationProvider.overrideWith(
              () => FakeGamificationNotifier(0),
            ),
            discoveryStatsProvider.overrideWithValue(testStats),
          ],
          child: MaterialApp(
            theme: VantageTheme.dark,
            home: const Material(child: ProfileSheet()),
          ),
        ),
      );

      // Verify Categories
      expect(find.text('Category Progress'), findsOneWidget);

      // Dining (40%)
      expect(find.text('Dining'), findsOneWidget);
      expect(find.text('2/5'), findsOneWidget);

      // Nightlife (100% + Checkmark)
      expect(find.text('Nightlife'), findsOneWidget);
      // "2/2" text might be present or not depending on implementation of completed check
      // In my implementation:
      // if (isComplete) Icon(Icons.check_circle_rounded...)
      // Text('${progress.discovered}/${progress.total}')
      // So yes, "2/2" should still be there.
      expect(find.text('2/2'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}

class FakeGamificationNotifier extends GamificationNotifier {
  final int initialStreak;
  FakeGamificationNotifier(this.initialStreak);

  @override
  GamificationState build() {
    return GamificationState(streak: initialStreak);
  }
}
