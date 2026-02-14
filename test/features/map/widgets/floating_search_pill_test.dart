import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/theme/vantage_theme.dart';
import 'package:vantage419/features/map/widgets/floating_search_pill.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/features/profile/gamification_provider.dart';

void main() {
  group('FloatingSearchPill', () {
    Widget buildTestWidget({required VoidCallback onTapDice}) {
      return ProviderScope(
        overrides: [
          gamificationProvider.overrideWith(() => FakeGamificationNotifier(0)),
        ],
        child: MaterialApp(
          theme: VantageTheme.dark,
          home: Scaffold(
            body: Center(child: FloatingSearchPill(onTapDice: onTapDice)),
          ),
        ),
      );
    }

    testWidgets('renders spin button with dice icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(onTapDice: () {}));

      expect(find.byIcon(Icons.casino_rounded), findsOneWidget);
      expect(find.text('Spin'), findsOneWidget);
    });

    testWidgets('triggers callback on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(onTapDice: () => tapped = true));

      await tester.tap(find.text('Spin'));
      expect(tapped, isTrue);
    });

    testWidgets('does NOT show search-related UI', (tester) async {
      await tester.pumpWidget(buildTestWidget(onTapDice: () {}));

      // Search was removed in Sprint 2.1
      expect(find.byIcon(Icons.search_rounded), findsNothing);
      expect(find.text('Where to?'), findsNothing);
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
